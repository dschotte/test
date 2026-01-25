--
-- Table: BUS_COMM_FEED_LOG
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          12/01/2026      Initial version
--
-- Remarks:
-- 1. Operational log (applications feeding data)
--

CREATE TABLE bus_comm_feed_log
(feeder_app_id  VARCHAR2(20)    NOT NULL
,feed_dt        TIMESTAMP       NOT NULL
,CONSTRAINT bus_comm_feed_log_pk PRIMARY KEY (feeder_app_id) USING INDEX TABLESPACE cds_idx
)
TABLESPACE cds_data
/

COMMENT ON TABLE  bus_comm_feed_log IS 'Operational log (applications feeding data)'
/
COMMENT ON COLUMN bus_comm_feed_log.feed_dt IS 'Date-time of last data feed'
/

BEGIN syn_mgr.create_synonym('bus_comm_feed_log'); END;
/
GRANT SELECT ON bus_comm_feed_log TO cds_online
/
