CREATE OR REPLACE PACKAGE pck_cust_lookup IS

        --
        -- Package: PCK_CUST_LOOKUP
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------
        -- 1.0          31/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on cust_lookup table
        --

        FUNCTION get_cust(p_phone PHONE_OBJ) RETURN ID_OBJ;

        FUNCTION get_cust(p_acct_id VARCHAR2) RETURN ID_OBJ;

        FUNCTION get_cust(p_phone PHONE_OBJ, p_acct_id VARCHAR2) RETURN ID_OBJ;

END pck_cust_lookup;
/

CREATE OR REPLACE PACKAGE BODY pck_cust_lookup IS

        FUNCTION get_cust(p_phone PHONE_OBJ) RETURN ID_OBJ IS
                v_cust ID_OBJ := ID_OBJ;
        BEGIN
                SELECT
                        cust_id,
                        cust_id_scope,
                        cust_id_ctx
                INTO
                        v_cust.id,
                        v_cust.id_scope,
                        v_cust.id_ctx
                FROM cust_lookup
                        WHERE ctry_pfx = p_phone.ctry_pfx AND natl_nr = p_phone.natl_num
                        GROUP BY cust_id, cust_id_scope, cust_id_ctx
                        HAVING COUNT(*) = 1;
                RETURN v_cust;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

        FUNCTION get_cust(p_acct_id VARCHAR2) RETURN ID_OBJ IS
                v_cust ID_OBJ := ID_OBJ;
        BEGIN
                SELECT
                        cust_id,
                        cust_id_scope,
                        cust_id_ctx
                INTO
                        v_cust.id,
                        v_cust.id_scope,
                        v_cust.id_ctx
                FROM cust_lookup
                        WHERE acct_id = p_acct_id
                        GROUP BY cust_id, cust_id_scope, cust_id_ctx
                        HAVING COUNT(*) = 1;
                RETURN v_cust;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

        FUNCTION get_cust(p_phone PHONE_OBJ, p_acct_id VARCHAR2) RETURN ID_OBJ IS
                v_cust ID_OBJ;
        BEGIN
                v_cust := get_cust(p_phone);
                IF v_cust IS NULL THEN
                        v_cust := get_cust(p_acct_id);
                END IF;
                RETURN v_cust;
        END;

END pck_cust_lookup;
/
