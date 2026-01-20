CREATE OR REPLACE PACKAGE pck_api_batch AS

        --
        -- Package: PCK_API_BATCH
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------
        -- 1.0          30/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for batch api
        --

        PROCEDURE log_run(p_batch_nm VARCHAR2, p_batch_msg VARCHAR2 DEFAULT NULL);

END pck_api_batch;
/

BEGIN syn_mgr.create_synonym('pck_api_batch'); END;
/
GRANT EXECUTE ON pck_api_batch TO cds_batch
/

CREATE OR REPLACE PACKAGE BODY pck_api_batch AS

        PROCEDURE log_run(p_batch_nm VARCHAR2, p_batch_msg VARCHAR2 DEFAULT NULL) IS
                v_last_run_dt TIMESTAMP := SYSTIMESTAMP;
                PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
                UPDATE batch_run SET last_run_dt = v_last_run_dt, batch_msg = p_batch_msg WHERE batch_nm = p_batch_nm;

                IF SQL%ROWCOUNT = 0 THEN
                        INSERT INTO batch_run (batch_nm, last_run_dt, batch_msg) VALUES (p_batch_nm, v_last_run_dt, p_batch_msg);
                END IF;

                COMMIT;
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;

END pck_api_batch;
/
