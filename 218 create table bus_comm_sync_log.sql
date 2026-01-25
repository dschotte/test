--
-- Table: BUS_COMM_SYNC_LOG
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------------------------
-- 1.0          22/01/2024      Initial version
--
-- Remarks:
-- 1. business communication synchronizer log
--

CREATE TABLE bus_comm_sync_log
(creation_dt            TIMESTAMP       NOT NULL
,api_op                 VARCHAR2(10)    NOT NULL
,reader_app_id          VARCHAR2(20)
,bus_comm_ids_json      BLOB
,since_mod_dt           TIMESTAMP
,before_mod_dt          TIMESTAMP
,CONSTRAINT bus_comm_sync_log_bus_comm_id_check CHECK (bus_comm_ids_json IS JSON) DISABLE
)
TABLESPACE cds_data
PARTITION BY RANGE(creation_dt)
INTERVAL(NUMTOYMINTERVAL(1, 'month')) (PARTITION bus_comm_sync_log_000000 VALUES LESS THAN (TO_DATE('01-01-1970','dd-mm-yyyy')))
ENABLE ROW MOVEMENT
/

BEGIN
syn_mgr.create_synonym('bus_comm_sync_log');
END;
/
GRANT SELECT ON bus_comm_sync_log TO cds_online
/
