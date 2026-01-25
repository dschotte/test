--
-- Table: BUS_COMM_STAT_DEF
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------
-- 1.0          24/01/2025      Initial version
--
-- Remarks:
-- 1. reference data
--

CREATE TABLE bus_comm_stat_def
(stat_cd                VARCHAR2(20)    NOT NULL
,stat_descr             VARCHAR2(60)    NOT NULL
,seq                    NUMBER(1)       NOT NULL
,effective              VARCHAR2(1)     DEFAULT 'N' NOT NULL
,cust_comm_stat_cd      VARCHAR2(20)
,CONSTRAINT bus_comm_stat_def_pk PRIMARY KEY (stat_cd) USING INDEX TABLESPACE cds_idx
,CONSTRAINT bus_comm_stat_def_effective_check CHECK (effective IN ('Y','N'))
)
TABLESPACE cds_data
/

BEGIN syn_mgr.create_synonym('bus_comm_stat_def'); END;
/
GRANT SELECT ON bus_comm_stat_def TO cds_online
/

COMMENT ON TABLE bus_comm_stat_def IS 'Business communication status definition'
/
COMMENT ON COLUMN bus_comm_stat_def.stat_cd IS 'Status code'
/
COMMENT ON COLUMN bus_comm_stat_def.stat_descr IS 'Status description'
/
COMMENT ON COLUMN bus_comm_stat_def.seq IS 'Sequence (to determine the final status)'
/
COMMENT ON COLUMN bus_comm_stat_def.effective IS 'Is status effective? (Y/N)'
/
COMMENT ON COLUMN bus_comm_stat_def.cust_comm_stat_cd IS 'Customer communication status code'
/
