--
-- Table: BUS_COMM_FEEDER_DEF
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------
-- 1.0          12/01/2025      Initial version
--
-- Remarks:
-- 1. Technical defintion of applications feeding data
--

CREATE TABLE bus_comm_feeder_def
(feeder_app_id  VARCHAR2(20)    NOT NULL
,app_active     VARCHAR2(1)     DEFAULT 'N' NOT NULL
,max_hrs_delay  NUMBER(5)
,CONSTRAINT bus_comm_feeder_def_pk PRIMARY KEY (feeder_app_id) USING INDEX TABLESPACE cds_idx
)
TABLESPACE cds_data
/

COMMENT ON TABLE  bus_comm_feeder_def IS 'Technical defintion of applications feeding data'
/
COMMENT ON COLUMN bus_comm_feeder_def.feeder_app_id IS 'Application ID of the feeder'
/
COMMENT ON COLUMN bus_comm_feeder_def.app_active IS 'Is the application active (Y/N)?'
/
COMMENT ON COLUMN bus_comm_feeder_def.max_hrs_delay IS 'Maximum hours of normal feeding delay'
/

BEGIN syn_mgr.create_synonym('bus_comm_feeder_def'); END;
/
GRANT SELECT ON bus_comm_feeder_def TO cds_online
/
