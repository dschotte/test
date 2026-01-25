--
-- Table: BUS_COMM_EMAIL_CNT
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          12/01/2026      Initial version
--
-- Remarks:
-- 1. Business communication email contacts
--

CREATE TABLE bus_comm_email_cnt 
(creation_dt            TIMESTAMP WITH LOCAL TIME ZONE  NOT NULL
,tx_id                  RAW(16)                         NOT NULL
,tx_type                VARCHAR2(1)                     NOT NULL
,tx_dt                  TIMESTAMP WITH LOCAL TIME ZONE  NOT NULL
,tx_app_id              VARCHAR2(20)                    NOT NULL
,bus_comm_id            RAW(16)                         NOT NULL
,start_dt		TIMESTAMP			NOT NULL
,role_row               NUMBER(2)                       NOT NULL
,role_type              VARCHAR2(20)                    NOT NULL
,email_addr             VARCHAR2(110)
,CONSTRAINT bus_comm_email_cnt_tx_type_check CHECK (tx_type = 'C')
,CONSTRAINT bus_comm_email_cnt_pk PRIMARY KEY (tx_id, role_row) USING INDEX TABLESPACE cds_idx
,CONSTRAINT bus_comm_email_cnt_bus_comm_id_fk FOREIGN KEY (bus_comm_id) REFERENCES bus_comm (bus_comm_id)
)
TABLESPACE cds_data
/

COMMENT ON TABLE  bus_comm_email_cnt IS 'Business communication email contacts'
/
COMMENT ON COLUMN bus_comm_email_cnt.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm_email_cnt.tx_id IS 'Transaction ID (UUID)'
/
COMMENT ON COLUMN bus_comm_email_cnt.tx_type IS 'Transaction type (C=creation/U=update)'
/
COMMENT ON COLUMN bus_comm_email_cnt.tx_dt IS 'Transaction date-time'
/
COMMENT ON COLUMN bus_comm_email_cnt.tx_app_id IS 'Application ID of the transaction creator'
/
COMMENT ON COLUMN bus_comm_email_cnt.bus_comm_id IS 'Business communication ID (UUID)'
/
COMMENT ON COLUMN bus_comm_email_cnt.start_dt IS 'Business communication start date-time'
/
COMMENT ON COLUMN bus_comm_email_cnt.role_row IS 'Role row number'
/
COMMENT ON COLUMN bus_comm_email_cnt.role_type IS 'Role type (SENT_FROM,SENT_TO,SENT_TO_BCC,SENT_TO_CC)'
/
COMMENT ON COLUMN bus_comm_email_cnt.email_addr IS 'Email address of sender or receiver'
/

CREATE INDEX bus_comm_email_cnt_bus_comm_id_fk ON bus_comm_email_cnt (bus_comm_id)
TABLESPACE cds_idx
/
