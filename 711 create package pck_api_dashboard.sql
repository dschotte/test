CREATE OR REPLACE PACKAGE pck_api_dashboard IS

        --
        -- Package: PCK_API_DASHBOARD
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          08/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for dashboard api
        --

        FUNCTION list_module_hosts RETURN SYS_REFCURSOR;

        FUNCTION list_feeders RETURN SYS_REFCURSOR;

        FUNCTION list_jobs RETURN SYS_REFCURSOR;

        FUNCTION list_batches RETURN SYS_REFCURSOR;
        
        FUNCTION list_tablespaces RETURN SYS_REFCURSOR;

        FUNCTION list_key_stores RETURN SYS_REFCURSOR;

        FUNCTION list_tasks(p_alert_interval VARCHAR2) RETURN SYS_REFCURSOR;
 
END pck_api_dashboard;
/

BEGIN syn_mgr.create_synonym('pck_api_dashboard'); END;
/
GRANT EXECUTE ON pck_api_dashboard TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_dashboard IS

        FUNCTION list_module_hosts RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
                C_NO CONSTANT VARCHAR2(1) := 'N';      
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT('moduleNm' VALUE module_nm
                                                  ,'hostNm' VALUE host_nm
                                                  ,'hostUrl' VALUE host_url
                                                  ,'moduleUrl' VALUE REPLACE(module_url, '<HOST_URL>', host_url)
                                                  ,'hostTp' VALUE host_type
                                                  ,'hostDescr' VALUE host_descr || NVL2(data_ctr, ' @' || data_ctr, NULL)
                                                  ,'redundant' VALUE redundant RETURNING BLOB
                                                  ) AS root_obj               
                FROM ( SELECT module_nm,
                              host_nm,
                              REPLACE(host_url, '<HOST_NM>', host_nm) AS host_url,
                              REPLACE(module_url, '<HOST_NM>', host_nm) AS module_url,
                              host_type,
                              host_descr,
                              data_ctr,
                              C_NO as redundant
                       FROM module_host_def
                     )
                ORDER BY module_nm, redundant, host_type, host_descr, data_ctr;
                --
                RETURN c_list;
        END;

        FUNCTION list_feeders RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT('appId' VALUE d.feeder_app_id
                                                  ,'txCreDt' VALUE l.feed_dt
                                                  ,'active' VALUE d.app_active
                                                  ,'txDelay' VALUE pck_utl_timestamp.diff(l.feed_dt, SYSTIMESTAMP, 'HOUR')
                                                  ,'delayThreshold' VALUE NVL(d.max_hrs_delay, 0) RETURNING BLOB
                                                  ) AS root_obj
                FROM bus_comm_feeder_def d LEFT JOIN bus_comm_feed_log l ON d.feeder_app_id = l.feeder_app_id
                ORDER BY d.feeder_app_id;
                --
                RETURN c_list;
        END;

        FUNCTION list_jobs RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
                C_ORACLE CONSTANT VARCHAR2(6) := 'ORACLE';      
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT('jobNm' VALUE job_nm
                                                  ,'jobDescr' VALUE job_descr
                                                  ,'jobEnv' VALUE job_env
                                                  ,'enabled' VALUE enabled
                                                  ,'runDt' VALUE run_dt
                                                  ,'output' VALUE output
                                                  ,'succeeded' VALUE succeeded RETURNING BLOB
                                                  ) AS root_obj
                FROM ( SELECT j.job_name AS job_nm,
                              j.comments AS job_descr,
                              C_ORACLE AS job_env,
                              DECODE(j.enabled, 'TRUE', 'Y', 'N') AS enabled,
                              CAST(r.actual_start_date AS TIMESTAMP) AS run_dt,
                              r.output AS output,
                              DECODE(r.status, 'SUCCEEDED', 'Y', 'N') AS succeeded
                       FROM user_scheduler_jobs j LEFT JOIN (
                              SELECT job_name, MAX(actual_start_date) AS actual_start_date,
                              MAX(status) KEEP (DENSE_RANK LAST ORDER BY actual_start_date) AS status,
                              MAX(output) KEEP (DENSE_RANK LAST ORDER BY actual_start_date) AS output
                              FROM user_scheduler_job_run_details
                              GROUP BY job_name
                       ) r ON j.job_name = r.job_name
                       WHERE j.job_name NOT LIKE 'MV_RF$J%'
                       ORDER BY 1
                );
                --
                RETURN c_list;
        END;

        FUNCTION list_batches RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
                C_UNIX CONSTANT VARCHAR2(4) := 'UNIX';   
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT('batchNm' VALUE batch_nm
                                                  ,'batchDescr' VALUE batch_descr
                                                  ,'batchEnv' VALUE batch_env
                                                  ,'enabled' VALUE enabled
                                                  ,'runDt' VALUE run_dt
                                                  ,'batchMsg' VALUE batch_msg
                                                  ,'succeeded' VALUE succeeded RETURNING BLOB
                                                  ) AS root_obj
                FROM ( SELECT batch_nm,
                              batch_descr,
                              C_UNIX AS batch_env,
                              enabled,
                              run_dt,
                              batch_msg,
                              CASE WHEN run_dt > SYSDATE - 1 THEN 'Y' ELSE 'N' END AS succeeded
                       FROM ( SELECT d.batch_nm,
                              d.batch_descr,
                              d.scheduled AS enabled,
                              r.last_run_dt AS run_dt,
                              r.batch_msg
                              FROM batch_def d LEFT JOIN batch_run r ON d.batch_nm = r.batch_nm
                       )
                       ORDER BY 1
                );
                --
                RETURN c_list;
        END;

        FUNCTION list_tablespaces RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
        BEGIN
                OPEN c_list FOR SELECT root_obj
                FROM ora_tablespace
                ORDER BY JSON_VALUE(root_obj, '$.tablespaceNm' RETURNING VARCHAR2(8) ERROR ON ERROR);
                --
                RETURN c_list;
        END;

        FUNCTION list_key_stores RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT('loadedDt' VALUE loaded_dt
                                                  ,'dataCtr' VALUE data_ctr
                                                  ,'moduleNm' VALUE module_nm
                                                  ,'path' VALUE path
                                                  ,'certStartDt' VALUE cert_start_dt 
                                                  ,'certEndDt' VALUE cert_end_dt 
                                                  ,'certSubject' VALUE cert_subject RETURNING BLOB
                                                  ) AS root_obj
                FROM key_store
                WHERE data_ctr <> 'localhost'
                ORDER BY module_nm, path, data_ctr;
                --
                RETURN c_list;
        END;

        FUNCTION list_tasks(p_alert_interval VARCHAR2) RETURN SYS_REFCURSOR IS
        BEGIN
                RETURN pck_task.list_tasks(p_alert_interval);
        END;

END pck_api_dashboard;
/
