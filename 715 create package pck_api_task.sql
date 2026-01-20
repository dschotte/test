CREATE OR REPLACE PACKAGE pck_api_task IS

        --
        -- Package: PCK_API_TASK
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          27/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for task api
        --

        PROCEDURE log_error(p_module_nm VARCHAR2, p_task_nm VARCHAR2, p_error_msg VARCHAR2); -- to be removed

        PROCEDURE log_err(p_module_nm VARCHAR2, p_task_nm VARCHAR2, p_err_msg VARCHAR2);

        PROCEDURE log_run(p_module_nm VARCHAR2, p_task_nm VARCHAR2);
                
END pck_api_task;
/

BEGIN syn_mgr.create_synonym('pck_api_task'); END;
/
GRANT EXECUTE ON pck_api_task TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_task IS

        PROCEDURE log_error(p_module_nm VARCHAR2, p_task_nm VARCHAR2, p_error_msg VARCHAR2) IS
        BEGIN
                log_err(p_module_nm, p_task_nm, p_error_msg);
        END;

        PROCEDURE log_err(p_module_nm VARCHAR2, p_task_nm VARCHAR2, p_err_msg VARCHAR2) IS
                PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
                INSERT INTO task_err_log (creation_dt, module_nm, task_nm, err_msg)
                VALUES (SYSTIMESTAMP, p_module_nm, p_task_nm, SUBSTR(p_err_msg, 1, 2048));
                
                COMMIT;
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK;
                RAISE;                      
        END;

        PROCEDURE log_run(p_module_nm VARCHAR2, p_task_nm VARCHAR2) IS
                PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
                UPDATE task_run SET last_run_dt = SYSTIMESTAMP WHERE module_nm = p_module_nm AND task_nm = p_task_nm;

                IF SQL%ROWCOUNT = 0 THEN
                        INSERT INTO task_run (module_nm, task_nm, last_run_dt) VALUES (p_module_nm, p_task_nm, SYSTIMESTAMP);
                END IF;

                COMMIT;
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK;
                RAISE;                    
        END;

END pck_api_task;
/
