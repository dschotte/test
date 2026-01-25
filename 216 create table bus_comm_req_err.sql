--
-- Table: BUS_COMM_REQ_ERR
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------------------------
-- 1.0          01/02/2025      Initial version
--
-- Remarks:
-- 1. business communication request error
--

CREATE TABLE bus_comm_req_err
(creation_dt            TIMESTAMP       NOT NULL
,req_xml                CLOB
,req_xml_ver            VARCHAR2(2)
,req_from_api           VARCHAR2(1)     DEFAULT 'N' NOT NULL
,pub_dt                 TIMESTAMP
,bus_comm_tx_json       BLOB
,req_log_id            	NUMBER(10)      NOT NULL
,err_cd                 NUMBER(5)
,err_msg                VARCHAR2(2048)
,CONSTRAINT bus_comm_req_err_req_xml_ver_check CHECK (req_xml_ver = 'V2')
,CONSTRAINT bus_comm_req_err_req_from_api_check CHECK (req_from_api IN ('Y','N'))
,CONSTRAINT bus_comm_req_err_bus_comm_tx_json_check CHECK (bus_comm_tx_json IS JSON) DISABLE
,CONSTRAINT bus_comm_req_err_pk PRIMARY KEY (req_log_id) USING INDEX TABLESPACE cds_idx
)
TABLESPACE cds_data
LOB (req_xml) STORE AS SECUREFILE (ENABLE STORAGE IN ROW COMPRESS MEDIUM NOCACHE)
LOB (bus_comm_tx_json) STORE AS SECUREFILE (ENABLE STORAGE IN ROW COMPRESS MEDIUM NOCACHE)
/

BEGIN syn_mgr.create_synonym('bus_comm_req_err'); END;
/
GRANT SELECT ON bus_comm_req_err TO cds_online
/
