--
-- Table: BUS_COMM_READ_LOG
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------------------------
-- 1.0          14/01/2026      Initial version
--
-- Remarks:
-- 1. Operational log (reads through business communication API calls)
--

CREATE TABLE bus_comm_read_log
(creation_dt            TIMESTAMP       NOT NULL
,api_op                 VARCHAR2(10)    NOT NULL
,reader_app_id          VARCHAR2(20)
,bus_comm_id            RAW(16)
,req_id                 VARCHAR2(40)
,req_id_ctx             VARCHAR2(20)
,cust_order_id          VARCHAR2(40)
,cust_order_id_ctx      VARCHAR2(20)
,cust_id                VARCHAR2(20)
,cust_id_ctx            VARCHAR2(20)
,since_start_dt         TIMESTAMP
,before_start_dt        TIMESTAMP
,jo_only                VARCHAR2(1)
,trade_in_only          VARCHAR2(1)
)
TABLESPACE cds_data
PARTITION BY RANGE(creation_dt)
INTERVAL(NUMTOYMINTERVAL(1, 'month')) (PARTITION bus_comm_read_log_000000 VALUES LESS THAN (TO_DATE('01-01-1970','dd-mm-yyyy')))
ENABLE ROW MOVEMENT
/

COMMENT ON TABLE  bus_comm_read_log IS 'Operational log (reads through business communication API calls)'
/
COMMENT ON COLUMN bus_comm_read_log.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm_read_log.api_op IS 'API operation (GET,FIND)'
/
COMMENT ON COLUMN bus_comm_read_log.reader_app_id IS 'Application ID of the reader (CDS_BAM if not given)'
/
COMMENT ON COLUMN bus_comm_read_log.bus_comm_id IS 'Search criterion (GET) on business communication ID (UUID)'
/
COMMENT ON COLUMN bus_comm_read_log.req_id IS 'Search criterion (FIND) on request ID'
/
COMMENT ON COLUMN bus_comm_read_log.req_id_ctx IS 'Search criterion (FIND) on request ID context (master application ID) combined with request ID'
/
COMMENT ON COLUMN bus_comm_read_log.cust_order_id IS 'Search criterion (FIND) on customer order ID'
/
COMMENT ON COLUMN bus_comm_read_log.cust_order_id_ctx IS 'Search criterion (FIND) on customer order ID context (master application ID) combined with customer order ID'
/
COMMENT ON COLUMN bus_comm_read_log.cust_id IS 'Search criterion (FIND) on customer ID'
/
COMMENT ON COLUMN bus_comm_read_log.cust_id_ctx IS 'Search criterion (FIND) on customer ID context (master application ID) combined with customer ID'
/
COMMENT ON COLUMN bus_comm_read_log.since_start_dt IS 'Search criterion (FIND) on business communication start date-time interval'
/
COMMENT ON COLUMN bus_comm_read_log.before_start_dt IS 'Search criterion (FIND) on business communication start date-time interval'
/
COMMENT ON COLUMN bus_comm_read_log.jo_only IS 'Search criterion (FIND) on business communication being linked to a joint-offer (Y/N)'
/
COMMENT ON COLUMN bus_comm_read_log.trade_in_only IS 'Search criterion (FIND) on business communication being linked to a trade-in (Y/N)'
/

BEGIN
syn_mgr.create_synonym('bus_comm_read_log');
END;
/
GRANT SELECT ON bus_comm_read_log TO cds_online
/
