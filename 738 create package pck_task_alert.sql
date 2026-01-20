CREATE OR REPLACE PACKAGE pck_task_alert IS

        --
        -- Package: PCK_TASK_ALERT
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          06/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for task alerts
        --

        PROCEDURE send_daily;

        PROCEDURE send_hourly;

END pck_task_alert;
/

CREATE OR REPLACE PACKAGE BODY pck_task_alert IS

        PROCEDURE send(p_alert_int VARCHAR2)
        IS
                c_task SYS_REFCURSOR;
                v_root_obj BLOB;
                v_module_nm VARCHAR2(99);
                v_task_nm VARCHAR2(99);
                v_err_threshold NUMBER;
                v_err_total NUMBER;
                v_err_stat VARCHAR2(99);
                v_alert_int_nm VARCHAR2(99);
                v_run_dt TIMESTAMP;
                v_runcheck_needed VARCHAR2(1);
                v_fetched_dt TIMESTAMP;

                C_YES CONSTANT VARCHAR2(1) := 'Y';
                C_BLACK CONSTANT VARCHAR2(5) := 'black';
                C_RED CONSTANT VARCHAR2(3) := 'red';
                C_ALERT_FROM CONSTANT VARCHAR2(24) := 'id076829m12@proximus.com'; -- AS-DMA
                C_ALERT_SUBJECT CONSTANT VARCHAR2(10) := 'Task alert';
                v_color VARCHAR2(99);
                v_alert_to param.param_val%TYPE := pck_param.alert_to;
                v_html VARCHAR2(4000);
                v_alert_needed BOOLEAN := FALSE;
        BEGIN
                c_task := pck_task.list_tasks(p_alert_int);
                v_html := '<html><head><style>table {width:100%;} table,th,td {border:1px solid black;}</style></head><body><table><tr><th>Module</th><th>Task</th></th><th>#Errors tolerated</th><th>#Errors</th><th>Status (errors)</th><th>Alert interval</th><th>Last run at</th><th>Runcheck needed? (Y/N)</th></tr>';
                LOOP
                        FETCH c_task INTO v_root_obj;
                        EXIT WHEN c_task%NOTFOUND;

                        SELECT  JSON_VALUE(v_root_obj, '$.moduleNm' RETURNING VARCHAR2(99)),
                                JSON_VALUE(v_root_obj, '$.taskNm' RETURNING VARCHAR2(99)),
                                JSON_VALUE(v_root_obj, '$.errThreshold' RETURNING NUMBER),
                                JSON_VALUE(v_root_obj, '$.errTotal' RETURNING NUMBER),
                                JSON_VALUE(v_root_obj, '$.errStat' RETURNING VARCHAR2(99)),
                                JSON_VALUE(v_root_obj, '$.alertIntervalNm' RETURNING VARCHAR2(99)),
                                JSON_VALUE(v_root_obj, '$.runDt' RETURNING TIMESTAMP),
                                JSON_VALUE(v_root_obj, '$.runcheckNeeded' RETURNING VARCHAR2(1)),
                                JSON_VALUE(v_root_obj, '$.fetchedDt' RETURNING TIMESTAMP)
                        INTO
                                v_module_nm,
                                v_task_nm,
                                v_err_threshold,
                                v_err_total,
                                v_err_stat,
                                v_alert_int_nm,
                                v_run_dt,
                                v_runcheck_needed,
                                v_fetched_dt
                        FROM DUAL;

                        IF v_err_stat = C_RED OR v_runcheck_needed = C_YES THEN
                                v_alert_needed := TRUE;
                        END IF;
                        IF v_runcheck_needed = C_YES THEN
                                v_color := C_RED;
                        ELSE
                                v_color := C_BLACK;
                        END IF;

                        v_html := v_html || '<tr><td>' || v_module_nm || '</td><td>' || v_task_nm || '</td><td>' || v_err_threshold || '</td><td>' || v_err_total || '</td><td style="background-color:' || v_err_stat || '"></td><td>1 ' || v_alert_int_nm || ' to ' || TO_CHAR(v_fetched_dt, 'HH24:MI') || '</td><td>' || TO_CHAR(v_run_dt, 'Dy DD/MM/YYYY HH24:MI') || '</td><td style="color:' || v_color || '">' || v_runcheck_needed || '</td></tr>';
                END LOOP;
                v_html := v_html || '</table></body></html>';
                CLOSE c_task;

                IF v_alert_needed THEN
                        pck_ora_smtp.send_mail(C_ALERT_FROM, v_alert_to, NULL, NULL, C_ALERT_SUBJECT, v_html);
                END IF;

                DBMS_OUTPUT.PUT_LINE(SYS.DIUTIL.BOOL_TO_INT(v_alert_needed) || ' sent');
        END;

        --
        -- procedure scheduled as job TASK_ALERT_SEND_DAILY; runs daily at 09.30 AM
        --

        PROCEDURE send_daily IS
        BEGIN
                send('D');
        END;

        --
        -- procedure scheduled as job TASK_ALERT_SEND_HOURLY; runs hourly during office hours
        --

        PROCEDURE send_hourly IS
        BEGIN
                send('H');
        END;

END pck_task_alert;
/
