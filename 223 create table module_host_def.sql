--
-- Table: MODULE_HOST_DEF
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          25/01/2025      Initial version
--
-- Remarks:
-- 1. reference data
--

CREATE TABLE module_host_def
(module_nm      VARCHAR2(32)    NOT NULL
,host_nm        VARCHAR2(60)    NOT NULL
,host_url       VARCHAR2(40)
,module_url     VARCHAR2(50)
,host_type      VARCHAR2(2)     NOT NULL
,host_descr     VARCHAR2(30)    NOT NULL
,data_ctr       VARCHAR2(10)
,CONSTRAINT module_host_def_module_nm CHECK (module_nm IN ('CDS_BAM','CDS_EVENT'))
,CONSTRAINT module_host_def_pk PRIMARY KEY (module_nm, host_nm) USING INDEX TABLESPACE cds_idx
,CONSTRAINT module_host_def_host_type CHECK (host_type IN ('LB','OS'))
)
TABLESPACE cds_data
/

BEGIN syn_mgr.create_synonym('module_host_def'); END;
/
GRANT SELECT ON module_host_def TO cds_online
/

COMMENT ON TABLE module_host_def IS 'Module host definition'
/
COMMENT ON COLUMN module_host_def.module_nm IS 'Module name (CDS_EVENT,CDS_BAM)'
/
COMMENT ON COLUMN module_host_def.host_nm IS 'Host name'
/
COMMENT ON COLUMN module_host_def.host_url IS 'Host URL (for reachability probe)'
/
COMMENT ON COLUMN module_host_def.module_url IS 'Module URL (for health probe)'
/
COMMENT ON COLUMN module_host_def.host_type IS 'Host type (LB=load balancer,OS=OpenShift)'
/
COMMENT ON COLUMN module_host_def.host_descr IS 'Host description'
/
COMMENT ON COLUMN module_host_def.data_ctr IS 'Data center'
/
