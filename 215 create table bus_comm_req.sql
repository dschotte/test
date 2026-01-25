--
-- Table: BUS_COMM_REQ
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          14/01/2026      Initial version
--
-- Remarks:
-- 1. Operational log (business communication requests)
--

CREATE TABLE bus_comm_req
(creation_dt            TIMESTAMP       NOT NULL
,tx_id                  RAW(16)         NOT NULL
,tx_type                VARCHAR2(1)     NOT NULL
,tx_dt                  TIMESTAMP       NOT NULL
,tx_app_id              VARCHAR2(20)    NOT NULL
,bus_comm_id            RAW(16)         NOT NULL
,req_xml                XMLTYPE
,req_xml_ver            VARCHAR2(2)     NOT NULL
,req_from_api           VARCHAR2(1)     DEFAULT 'N' NOT NULL
,pub_dt                 TIMESTAMP       NOT NULL
,bus_comm_tx_json       BLOB
,CONSTRAINT bus_comm_req_pk PRIMARY KEY (tx_id) USING INDEX TABLESPACE cds_idx
,CONSTRAINT bus_comm_req_tx_type_check CHECK (tx_type IN ('C','U'))
,CONSTRAINT bus_comm_req_bus_comm_id_fk FOREIGN KEY (bus_comm_id) REFERENCES bus_comm (bus_comm_id)
,CONSTRAINT bus_comm_req_req_xml_ver_check CHECK (req_xml_ver = 'V2')
,CONSTRAINT bus_comm_req_from_api_check CHECK (req_from_api IN ('Y','N'))
,CONSTRAINT bus_comm_req_bus_comm_tx_json_check CHECK (bus_comm_tx_json IS JSON) DISABLE
)
TABLESPACE cds_data
XMLTYPE COLUMN req_xml STORE AS SECUREFILE BINARY XML (ENABLE STORAGE IN ROW COMPRESS MEDIUM NOCACHE)
LOB (bus_comm_tx_json) STORE AS SECUREFILE (ENABLE STORAGE IN ROW COMPRESS MEDIUM NOCACHE)
PARTITION BY RANGE(creation_dt)
INTERVAL(NUMTOYMINTERVAL(1, 'MONTH')) (PARTITION bus_comm_req_000000 VALUES LESS THAN (TO_DATE('01-01-1970','dd-mm-yyyy')))
ENABLE ROW MOVEMENT
/

COMMENT ON TABLE  bus_comm_req IS 'Operational log (business communication requests)'
/
COMMENT ON COLUMN bus_comm_req.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm_req.tx_id IS 'Transaction ID (UUID)'
/
COMMENT ON COLUMN bus_comm_req.tx_type IS 'Transaction type (C=creation/U=update)'
/
COMMENT ON COLUMN bus_comm_req.tx_dt IS 'Transaction date-time'
/
COMMENT ON COLUMN bus_comm_req.tx_app_id IS 'Application ID of the transaction creator'
/
COMMENT ON COLUMN bus_comm_req.bus_comm_id IS 'Business communication ID (UUID)'
/
COMMENT ON COLUMN bus_comm_req.req_xml IS 'Business communication request payload (PIM XML)'
/
COMMENT ON COLUMN bus_comm_req.req_xml_ver IS 'PIM version'
/
COMMENT ON COLUMN bus_comm_req.req_from_api IS 'Did request come CRUD API? (Y/N)'
/
COMMENT ON COLUMN bus_comm_req.pub_dt IS 'Date-time of publication of request on internal queue'
/
COMMENT ON COLUMN bus_comm_req.bus_comm_tx_json IS 'Business communication transaction payload (internal JSON)'
/

BEGIN
syn_mgr.create_synonym('bus_comm_req');
END;
/
GRANT SELECT ON bus_comm_req TO cds_online
/

CREATE INDEX bus_comm_req_bus_comm_id_fk ON bus_comm_req (bus_comm_id)
TABLESPACE cds_idx
/
