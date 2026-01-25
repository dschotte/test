--
-- Table: BUS_COMM_READ_EXT_LOG
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          14/01/2026      Initial version
--
-- Remarks:
-- 1. Operational log (reads through extended business communication API calls)
--

CREATE TABLE bus_comm_read_ext_log
(creation_dt            TIMESTAMP       NOT NULL
,api_op                 VARCHAR2(10)    NOT NULL
,reader_app_id          VARCHAR2(20)
,offset_num             NUMBER(4)
,next_num               NUMBER(3)
,sorting_dir            VARCHAR2(4)
,ctry_pfx               VARCHAR2(5)
,natl_num               VARCHAR2(16)
,since_start_dt         TIMESTAMP
,before_start_dt        TIMESTAMP
,dir_cd                 VARCHAR2(20)
,subm_app_id            VARCHAR2(20)
,ch_class_cd            VARCHAR2(20)
)
TABLESPACE cds_data
PARTITION BY RANGE(creation_dt)
INTERVAL(NUMTOYMINTERVAL(1, 'month')) (PARTITION bus_comm_read_ext_log_000000 VALUES LESS THAN (TO_DATE('01-01-1970','dd-mm-yyyy')))
ENABLE ROW MOVEMENT
/

COMMENT ON TABLE  bus_comm_read_ext_log IS 'Operational log (reads through extended business communication API calls)'
/
COMMENT ON COLUMN bus_comm_read_ext_log.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm_read_ext_log.api_op IS 'API operation (FIND)'
/
COMMENT ON COLUMN bus_comm_read_ext_log.reader_app_id IS 'Application ID of the reader (CDS_BAM if not given)'
/
COMMENT ON COLUMN bus_comm_read_ext_log.offset_num IS 'Skip N rows in search result'
/
COMMENT ON COLUMN bus_comm_read_ext_log.next_num IS 'Return next N rows of search result'
/
COMMENT ON COLUMN bus_comm_read_ext_log.sorting_dir IS 'Sorting direction of rows in search result (ASC,DESC)'
/
COMMENT ON COLUMN bus_comm_read_ext_log.ctry_pfx IS 'Search criterion (FIND) on country prefix of phone number of sender or receiver'
/
COMMENT ON COLUMN bus_comm_read_ext_log.natl_num IS 'Search criterion (FIND) on national number part of phone number of sender or receiver'
/
COMMENT ON COLUMN bus_comm_read_ext_log.since_start_dt IS 'Search criterion (FIND) on business communication start date-time interval'
/
COMMENT ON COLUMN bus_comm_read_ext_log.before_start_dt IS 'Search criterion (FIND) on business communication start date-time interval'
/
COMMENT ON COLUMN bus_comm_read_ext_log.dir_cd IS 'Search criterion (FIND) on business business direction code (PIM code)'
/
COMMENT ON COLUMN bus_comm_read_ext_log.subm_app_id IS 'Search criterion (FIND) on application ID of the communication submitter'
/
COMMENT ON COLUMN bus_comm_read_ext_log.ch_class_cd IS 'Search criterion (FIND) on business communication channel classification code (PIM code)'
/

BEGIN
syn_mgr.create_synonym('bus_comm_read_ext_log');
END;
/
GRANT SELECT ON bus_comm_read_ext_log TO cds_online
/
