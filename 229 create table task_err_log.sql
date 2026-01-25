--
-- Table: TASK_ERR_LOG
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          24/01/2024      Initial version
--
-- Remarks:
-- 1. task error log table
--

CREATE TABLE task_err_log
(creation_dt    TIMESTAMP       NOT NULL
,module_nm      VARCHAR2(32)    NOT NULL
,task_nm        VARCHAR2(32)    NOT NULL
,err_msg        VARCHAR2(2048)
)
PARTITION BY RANGE(creation_dt)
INTERVAL(NUMTOYMINTERVAL(1, 'month')) (PARTITION task_err_log_000000 VALUES LESS THAN (TO_DATE('01-01-1970','dd-mm-yyyy')))
ENABLE ROW MOVEMENT
TABLESPACE cds_data
/

BEGIN syn_mgr.create_synonym('task_err_log'); END;
/
GRANT SELECT ON task_err_log TO cds_online
/
