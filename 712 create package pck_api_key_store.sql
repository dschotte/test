CREATE OR REPLACE PACKAGE pck_api_key_store IS

        --
        -- Package: PCK_API_KEY_STORE
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          29/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for key store api
        --

        PROCEDURE put_key_store(p_data_ctr VARCHAR2, p_module_nm VARCHAR2, p_path VARCHAR2, p_key_store_type VARCHAR2, p_data BLOB, p_cert_start_dt TIMESTAMP, p_cert_end_dt TIMESTAMP, p_cert_subject VARCHAR2);

        FUNCTION get_key_store(p_data_ctr VARCHAR2, p_module_nm VARCHAR2, p_path VARCHAR2) RETURN BLOB;

END pck_api_key_store;
/

BEGIN syn_mgr.create_synonym('pck_api_key_store'); END;
/
GRANT EXECUTE ON pck_api_key_store TO cds_online, cds_batch
/

CREATE OR REPLACE PACKAGE BODY pck_api_key_store IS

        PROCEDURE put_key_store(p_data_ctr VARCHAR2, p_module_nm VARCHAR2, p_path VARCHAR2, p_key_store_type VARCHAR2, p_data BLOB, p_cert_start_dt TIMESTAMP, p_cert_end_dt TIMESTAMP, p_cert_subject VARCHAR2) IS
        BEGIN
                UPDATE key_store SET loaded_dt = SYSTIMESTAMP
                        ,data_ctr = p_data_ctr
                        ,module_nm = p_module_nm
                        ,path = p_path
                        ,key_store_tp = p_key_store_type
                        ,data = p_data
                        ,cert_start_dt = p_cert_start_dt
                        ,cert_end_dt = p_cert_end_dt
                        ,cert_subject = p_cert_subject
                WHERE data_ctr = p_data_ctr AND module_nm = p_module_nm AND path = p_path;
                
                IF SQL%ROWCOUNT = 0 THEN
                        INSERT INTO key_store (loaded_dt, data_ctr, module_nm, path, key_store_tp, data, cert_start_dt, cert_end_dt, cert_subject)
                        VALUES (SYSTIMESTAMP, p_data_ctr, p_module_nm, p_path, p_key_store_type, p_data, p_cert_start_dt, p_cert_end_dt, p_cert_subject);
                END IF;
        END;
     
        FUNCTION get_key_store(p_data_ctr VARCHAR2, p_module_nm VARCHAR2, p_path VARCHAR2) RETURN BLOB IS
                v_key_store BLOB;
        BEGIN
                SELECT JSON_OBJECT('dataCtr' VALUE data_ctr
                        ,'moduleNm' VALUE module_nm
                        ,'path' VALUE path
                        ,'keyStoreTp' VALUE key_store_tp
                        ,'data' VALUE pck_utl_base64.blob_to_base64(data) RETURNING BLOB
                        ) INTO v_key_store
                FROM key_store WHERE data_ctr = p_data_ctr AND module_nm = p_module_nm AND path = p_path;

                RETURN v_key_store;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL; 
        END;

END pck_api_key_store;
/
