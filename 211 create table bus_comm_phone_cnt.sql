--
-- Table: BUS_COMM_PHONE_CNT
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          14/01/2026      Initial version
--
-- Remarks:
-- 1. Business communication phone contacts
--

CREATE TABLE bus_comm_phone_cnt 
(creation_dt            TIMESTAMP       NOT NULL
,tx_id                  RAW(16)         NOT NULL
,tx_type                VARCHAR2(1)     NOT NULL
,tx_dt                  TIMESTAMP       NOT NULL
,tx_app_id              VARCHAR2(20)    NOT NULL
,bus_comm_id            RAW(16)         NOT NULL
,start_dt               TIMESTAMP       NOT NULL
,subm_app_id            VARCHAR2(20)
,ch_class_cd            VARCHAR2(20)
,role_row               NUMBER(2)       NOT NULL
,role_type              VARCHAR2(20)    NOT NULL
,ctry_pfx               VARCHAR2(5)
,natl_num               VARCHAR2(16)
,CONSTRAINT bus_comm_phone_cnt_tx_type_check CHECK (tx_type = 'C')
,CONSTRAINT bus_comm_phone_cnt_pk PRIMARY KEY (tx_id, role_row) USING INDEX TABLESPACE cds_idx
,CONSTRAINT bus_comm_phone_cnt_bus_comm_id_fk FOREIGN KEY (bus_comm_id) REFERENCES bus_comm (bus_comm_id)
)
TABLESPACE cds_data
/

COMMENT ON TABLE  bus_comm_phone_cnt IS 'Business communication phone contacts'
/
COMMENT ON COLUMN bus_comm_phone_cnt.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm_phone_cnt.tx_id IS 'Transaction ID (UUID)'
/
COMMENT ON COLUMN bus_comm_phone_cnt.tx_type IS 'Transaction type (C=creation/U=update)'
/
COMMENT ON COLUMN bus_comm_phone_cnt.tx_dt IS 'Transaction date-time'
/
COMMENT ON COLUMN bus_comm_phone_cnt.tx_app_id IS 'Application ID of the transaction creator'
/
COMMENT ON COLUMN bus_comm_phone_cnt.bus_comm_id IS 'Business communication ID (UUID)'
/
COMMENT ON COLUMN bus_comm_phone_cnt.start_dt IS 'Business communication start date-time'
/
COMMENT ON COLUMN bus_comm_phone_cnt.subm_app_id IS 'Application ID of the communication submitter'
/
COMMENT ON COLUMN bus_comm_phone_cnt.ch_class_cd IS 'Business communication channel classification code (PIM code)'
/
COMMENT ON COLUMN bus_comm_phone_cnt.role_row IS 'Role row number'
/
COMMENT ON COLUMN bus_comm_phone_cnt.role_type IS 'Role type (SENT_FROM,SENT_TO)'
/
COMMENT ON COLUMN bus_comm_phone_cnt.ctry_pfx IS 'Country prefix of phone number of sender or receiver'
/
COMMENT ON COLUMN bus_comm_phone_cnt.natl_num IS 'National number part of phone number of sender or receiver'
/


CREATE INDEX bus_comm_phone_cnt_bus_comm_id_fk ON bus_comm_phone_cnt (bus_comm_id)
TABLESPACE cds_idx
/

CREATE INDEX bus_comm_phone_cnt_find ON bus_comm_phone_cnt(ctry_pfx, natl_num, start_dt, role_type, subm_app_id, ch_class_cd, bus_comm_id)
TABLESPACE cds_idx
/
