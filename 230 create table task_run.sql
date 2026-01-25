--
-- Table: TASK_RUN
--
-- Version	Date		Comments
-- -------	----------	--------------------------------------------------------------------------------------------
-- 1.0		24/01/2025	Initial version
--
-- Remarks:
-- 1. task run
--

CREATE TABLE task_run
(module_nm	VARCHAR2(32)	NOT NULL
,task_nm	VARCHAR2(32)	NOT NULL
,last_run_dt	TIMESTAMP
,CONSTRAINT task_run_pk PRIMARY KEY (module_nm, task_nm) USING INDEX TABLESPACE cds_idx
)
TABLESPACE cds_data
/

BEGIN syn_mgr.create_synonym('task_run'); END;
/
GRANT SELECT ON task_run TO cds_online
/
