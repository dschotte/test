--
-- Table: TASK_DEF
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          06/02/2025      Initial version
--
-- Remarks:
-- 1. reference data
--

CREATE TABLE task_def
(module_nm              VARCHAR2(32)    NOT NULL
,task_nm                VARCHAR2(32)    NOT NULL
,task_descr             VARCHAR2(60)    NOT NULL
,max_err                NUMBER(2)       NOT NULL
,alert_int              VARCHAR2(1)     NOT NULL
,enabling_param_nm      VARCHAR2(32)
,CONSTRAINT task_def_pk PRIMARY KEY (module_nm, task_nm) USING INDEX TABLESPACE cds_idx
,CONSTRAINT task_def_alert_int_check CHECK (alert_int IN ('D','H'))
,CONSTRAINT task_def_enabling_param_nm_fk FOREIGN KEY (module_nm, enabling_param_nm) REFERENCES param (module_nm, param_nm)
)
TABLESPACE cds_data
/

BEGIN syn_mgr.create_synonym('task_def'); END;
/
GRANT SELECT ON task_def TO cds_online
/

COMMENT ON TABLE task_def IS 'Task definition'
/
COMMENT ON COLUMN task_def.module_nm IS 'Module name'
/
COMMENT ON COLUMN task_def.task_nm IS 'Task name'
/
COMMENT ON COLUMN task_def.task_descr IS 'Task description'
/
COMMENT ON COLUMN task_def.max_err IS 'Maximum errors tolerated per pod during alert interval'
/
COMMENT ON COLUMN task_def.alert_int IS 'Alert interval (D=daily,H=hourly)'
/
COMMENT ON COLUMN task_def.enabling_param_nm IS 'Name of the parameter that enables the module''s task (param)'
/

CREATE INDEX task_def_enabling_param_nm_fk ON task_def (module_nm, enabling_param_nm)
TABLESPACE cds_idx
/
