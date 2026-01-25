--
-- Table: PARAM
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------
-- 1.0          07/02/2025      Initial version
--
-- Remarks:
-- 1. parameter table
--

CREATE TABLE param
(module_nm      VARCHAR2(32)    DEFAULT 'CDS' NOT NULL
,param_nm       VARCHAR2(32)    NOT NULL
,param_val      VARCHAR2(4000)
,param_descr    VARCHAR2(160)
,is_local       VARCHAR2(1)     DEFAULT 'N' NOT NULL
,CONSTRAINT param_pk PRIMARY KEY (module_nm, param_nm) USING INDEX TABLESPACE cds_idx
,CONSTRAINT param_module_nm_check CHECK (module_nm IN ('CDS','CDS_EVENT','CDS_BAM'))
,CONSTRAINT param_local_check CHECK (is_local IN ('Y','N'))
)
TABLESPACE cds_data
/

BEGIN syn_mgr.create_synonym('param'); END;
/
GRANT SELECT ON param TO cds_online
/

COMMENT ON TABLE param IS 'Parameter'
/
COMMENT ON COLUMN param.module_nm IS 'Module name (CDS/CDS_EVENT/CDS_BAM)'
/
COMMENT ON COLUMN param.param_nm IS 'Parameter name'
/
COMMENT ON COLUMN param.param_val IS 'Parameter value'
/
COMMENT ON COLUMN param.param_descr IS 'Parameter description'
/
COMMENT ON COLUMN param.is_local IS 'Local parameter, i.e. only in this environment? (Y/N)'
/
