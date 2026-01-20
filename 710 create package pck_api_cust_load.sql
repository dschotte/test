CREATE OR REPLACE PACKAGE pck_api_cust_load AS

        --
        -- Package: PCK_API_CUST_LOAD
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          29/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for customer load api
        --

        PROCEDURE prepare;

        PROCEDURE load(p_cust_list BLOB);

        PROCEDURE confirm;

END pck_api_cust_load;
/

BEGIN syn_mgr.create_synonym('pck_api_cust_load'); END;
/
GRANT EXECUTE ON pck_api_cust_load TO cds_batch
/

CREATE OR REPLACE PACKAGE BODY pck_api_cust_load AS

        PROCEDURE prepare IS
        BEGIN
                pck_ora_load_table.truncate('cust_lookup_load');
        END;

        PROCEDURE load(p_cust_list BLOB) IS
                CTRY_PFX_BELGIUM CONSTANT VARCHAR2(2) := '32';
                SCOPE_ENT CONSTANT VARCHAR2(3) := 'ENT';
                CUST_ID_CTX CONSTANT VARCHAR2(4) := 'CDBF';
        BEGIN
                INSERT /*+ APPEND */ INTO cust_lookup_load(ctry_pfx,
                        natl_nr,
                        cust_id,
                        cust_id_scope,
                        cust_id_ctx,
                        acct_id,
                        load_dt)
                SELECT CTRY_PFX_BELGIUM,
                        TO_CHAR(TO_NUMBER(natl_nr)),
                        cust_id,
                        SCOPE_ENT,
                        CUST_ID_CTX,
                        REGEXP_REPLACE(acct_id, '[^0-9]', NULL),
                        SYSTIMESTAMP
                FROM JSON_TABLE(p_cust_list, '$[*]' COLUMNS (natl_nr PATH '$.natlNr',
                        cust_id PATH '$.custId',
                        acct_id PATH '$.acctId')
                );
        END;

        PROCEDURE confirm IS
                v_load NUMBER;
                v_previous_load NUMBER;
        BEGIN
                SELECT COUNT(*) INTO v_load FROM cust_lookup_load;
                SELECT COUNT(*) INTO v_previous_load FROM cust_lookup;
                IF v_load < FLOOR(v_previous_load * 0.80) THEN
                        RAISE_APPLICATION_ERROR(-20000, 'Load may be incomplete');
                END IF;
                pck_ora_load_table.gather_stats('cds_schema', 'cust_lookup_load');
                pck_ora_load_table.swap('cust_lookup_load', 'cust_lookup');
        END;

END pck_api_cust_load;
/
