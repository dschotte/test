CREATE OR REPLACE PACKAGE pck_task IS

        --
        -- Package: PCK_TASK
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          08/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on task... tables
        --
        
        FUNCTION list_tasks(p_alert_int VARCHAR2) RETURN SYS_REFCURSOR;

        PROCEDURE clean_err_log;
               
END pck_task;
/

CREATE OR REPLACE PACKAGE BODY pck_task IS

        FUNCTION list_tasks(p_alert_int VARCHAR2) RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
                v_fetched_dt TIMESTAMP := SYSTIMESTAMP;
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT('moduleNm' VALUE module_nm
                                                  ,'taskNm' VALUE task_nm
                                                  ,'taskDescr' VALUE task_descr
                                                  ,'errThreshold' VALUE err_threshold
                                                  ,'errTotal' VALUE err_total
                                                  ,'errStat' VALUE CASE WHEN err_threshold < err_total THEN 'red' ELSE 'green' END
                                                  ,'alertInterval' VALUE alert_int
                                                  ,'alertIntervalNm' VALUE DECODE(alert_int, 'D', 'day', 'H', 'hour', 'interval')
                                                  ,'enabled' VALUE enabled
                                                  ,'runDt' VALUE last_run_dt
                                                  ,'runcheckNeeded' VALUE CASE WHEN enabled = 'Y' AND last_run_dt < v_fetched_dt - DECODE(p_alert_int, 'D', 1, 'H', 1/24) THEN 'Y' ELSE 'N' END
                                                  ,'fetchedDt' VALUE v_fetched_dt RETURNING BLOB
                                                  ) AS root_obj
                FROM (  SELECT  t.module_nm,
                                t.task_nm,
                                t.task_descr,
                                pck_param.pod_total(t.module_nm) * t.max_err AS err_threshold,
                                NVL(e.err_total, 0) AS err_total,
                                t.alert_int,
                                NVL2(t.enabling_param_nm, pck_param.param_val(t.module_nm, t.enabling_param_nm), 'Y') AS enabled,
                                r.last_run_dt
                        FROM task_def t LEFT JOIN (
                                SELECT module_nm, task_nm, COUNT(*) AS err_total
                                FROM task_err_log
                                WHERE creation_dt > v_fetched_dt - DECODE(p_alert_int, 'D', 1, 'H', 1/24)
                                GROUP BY module_nm, task_nm
                        ) e ON t.module_nm = e.module_nm AND t.task_nm = e.task_nm
                        LEFT JOIN task_run r ON t.module_nm = r.module_nm AND t.task_nm = r.task_nm
                        WHERE t.alert_int = p_alert_int
                );

                RETURN c_list;
        END;

        --
        -- manual clean
        --
        PROCEDURE clean_err_log IS
                CURSOR c_partition IS
                        SELECT partition_name, high_value
                        FROM user_tab_partitions WHERE table_name = 'TASK_ERR_LOG' AND partition_name != 'TASK_ERR_LOG_000000'
                        ORDER BY partition_name;
                v_ddl VARCHAR2(100);
                v_high_date DATE;
                v_month VARCHAR2(8);
        BEGIN
                --
                -- drop monthly partitions, except the last two
                --
                FOR r_partition IN c_partition LOOP
                        v_high_date := TO_DATE(SUBSTR(r_partition.high_value, 12, 10), 'YYYY-MM-DD'); -- TIMESTAMP' YYYY-MM-DD 00:00:00'
                        IF v_high_date < ADD_MONTHS(SYSDATE, -1) THEN
                                v_month := TO_CHAR(v_high_date - 1, 'YYYY-MON');
                                DBMS_OUTPUT.PUT_LINE(v_month);
                                v_ddl := 'ALTER TABLE task_err_log DROP PARTITION ' || r_partition.partition_name || ' UPDATE INDEXES';
                                DBMS_OUTPUT.PUT_LINE(v_ddl);
                                EXECUTE IMMEDIATE v_ddl;
                        END IF;
                END LOOP;
        END;

END pck_task;
/
