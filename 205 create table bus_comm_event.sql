--
-- Table: BUS_COMM_EVENT
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          12/01/2026      Initial version
--
-- Remarks:
-- 1. business communication event table
-- 

CREATE TABLE bus_comm_event
(creation_dt                    TIMESTAMP       NOT NULL
,tx_id                          RAW(16)         NOT NULL
,tx_type                        VARCHAR2(1)     NOT NULL
,tx_dt                          TIMESTAMP       NOT NULL
,tx_app_id                      VARCHAR2(20)    NOT NULL
,bus_comm_id                    RAW(16)         NOT NULL
,event_type                     VARCHAR2(1)     NOT NULL
,bus_comm_json                  BLOB
,stat_cd                        VARCHAR2(1)     NOT NULL
,stat_mod_dt                    TIMESTAMP
,bus_comm_event_req_json        CLOB
,CONSTRAINT bus_comm_event_pk PRIMARY KEY (tx_id) USING INDEX TABLESPACE cds_idx
,CONSTRAINT bus_comm_event_tx_type_check CHECK (tx_type IN ('C','U'))
,CONSTRAINT bus_comm_event_event_type_check CHECK (event_type IN ('C','U'))
,CONSTRAINT bus_comm_event_bus_comm_json_check CHECK (bus_comm_json IS JSON) DISABLE
,CONSTRAINT bus_comm_event_stat_cd_check CHECK (stat_cd IN ('N','P','S'))
,CONSTRAINT bus_comm_event_bus_comm_event_req_json_check CHECK (bus_comm_event_req_json IS JSON) DISABLE
)
TABLESPACE cds_data
LOB (bus_comm_json) STORE AS SECUREFILE (ENABLE STORAGE IN ROW COMPRESS MEDIUM NOCACHE)
LOB (bus_comm_event_req_json) STORE AS SECUREFILE (ENABLE STORAGE IN ROW COMPRESS MEDIUM NOCACHE)
PARTITION BY RANGE(creation_dt)
INTERVAL(NUMTODSINTERVAL(1, 'day')) (PARTITION bus_comm_event_00000000 VALUES LESS THAN (TO_DATE('1970-01-01','yyyy-mm-dd')))
ENABLE ROW MOVEMENT
/

COMMENT ON TABLE  bus_comm_event IS 'Business communication events'
/
COMMENT ON COLUMN bus_comm_event.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm_event.tx_id IS 'Transaction ID (UUID)'
/
COMMENT ON COLUMN bus_comm_event.tx_type IS 'Transaction type (C=creation/U=update)'
/
COMMENT ON COLUMN bus_comm_event.tx_dt IS 'Transaction date-time'
/
COMMENT ON COLUMN bus_comm_event.tx_app_id IS 'Application ID of the transaction creator'
/
COMMENT ON COLUMN bus_comm_event.bus_comm_id IS 'Business communication ID (UUID)'
/
COMMENT ON COLUMN bus_comm_event.event_type IS 'Event type (C=creation,U=update)'
/
COMMENT ON COLUMN bus_comm_event.bus_comm_json IS 'Business communication (internal JSON)'
/
COMMENT ON COLUMN bus_comm_event.stat_cd IS 'Event status code (N=new,P=published,S=skipped)'
/
COMMENT ON COLUMN bus_comm_event.stat_mod_dt IS 'Event status modification date-time'
/
COMMENT ON COLUMN bus_comm_event.bus_comm_event_req_json IS 'Event publication request (PIM JSON)'
/

CREATE INDEX bus_comm_event_bus_comm_id_idx ON bus_comm_event (bus_comm_id)
TABLESPACE cds_idx
/

CREATE INDEX bus_comm_event_stat_n ON bus_comm_event (DECODE(stat_cd, 'N', 'N')) -- index new events
TABLESPACE cds_idx
/

BEGIN
DBMS_STATS.SET_TABLE_PREFS(ownname => 'CDS_SCHEMA', tabname => 'BUS_COMM_EVENT', pname => 'INCREMENTAL', pvalue => 'TRUE'); -- use incremental statistics to gather only the necessary statistics for changed partitions
DBMS_STATS.SET_TABLE_PREFS(ownname => 'CDS_SCHEMA', tabname => 'BUS_COMM_EVENT', pname => 'PUBLISH', pvalue  => 'TRUE'); -- publish newly gathered statistics immediately after they are collected
END;
/
