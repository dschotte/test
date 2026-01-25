--
-- Table: BUS_COMM_ITEM
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          13/01/2026      Initial version
--
-- Remarks:
-- 1. Business communication items
--

CREATE TABLE bus_comm_item 
(creation_dt            TIMESTAMP       NOT NULL
,mod_dt                 TIMESTAMP
,tx_id                  RAW(16)         NOT NULL
,tx_type                VARCHAR2(1)     NOT NULL
,tx_dt                  TIMESTAMP       NOT NULL
,tx_app_id              VARCHAR2(15)    NOT NULL
,bus_comm_id            RAW(16)         NOT NULL
,item_row               NUMBER(2)       NOT NULL
,item_id                RAW(16)         NOT NULL
,item_type              VARCHAR2(40)    NOT NULL
,item_nm                VARCHAR2(70)
,item_descr             VARCHAR2(65)
,cmt                    VARCHAR2(1500)
,start_dt               TIMESTAMP
,end_dt                 TIMESTAMP
,stat_cd                VARCHAR2(20)
,att_id                 VARCHAR2(75)
,att_id_scope           VARCHAR2(3)
,att_id_ctx             VARCHAR2(15)
,lnk                    VARCHAR2(2048)
,handler_emp_id         VARCHAR2(8)
,handler_emp_id_scope   VARCHAR2(3)
,handler_emp_id_ctx     VARCHAR2(15)
,subm_emp_id            VARCHAR2(8)
,subm_emp_id_scope      VARCHAR2(3)
,subm_emp_id_ctx        VARCHAR2(15)
,handler_ext_id         VARCHAR2(60)
,handler_ext_id_scope   VARCHAR2(3)
,handler_ext_id_ctx     VARCHAR2(15)
,comm_id                VARCHAR2(20)
,comm_id_scope          VARCHAR2(3)
,comm_id_ctx            VARCHAR2(15)
,case_id                VARCHAR2(25)
,case_id_scope          VARCHAR2(3)
,case_id_ctx            VARCHAR2(15)
,wo_id                  VARCHAR2(45)
,wo_id_scope            VARCHAR2(3)
,wo_id_ctx              VARCHAR2(15)
,inc_id                 VARCHAR2(30)
,inc_id_scope           VARCHAR2(3)
,inc_id_ctx             VARCHAR2(15)
,lead_id                VARCHAR2(20)
,lead_id_scope          VARCHAR2(3)
,lead_id_ctx            VARCHAR2(15)
,req_id                 VARCHAR2(50)
,req_id_scope           VARCHAR2(3)
,req_id_ctx             VARCHAR2(15)
,cnt_domain_cd          VARCHAR2(20)
,prd_fam_cd             VARCHAR2(20)
,cnt_reason_cd          VARCHAR2(20)
,cnt_reason_descr       VARCHAR2(220)
,cnt_reason_en          VARCHAR2(220)
,cnt_reason_fr          VARCHAR2(220)
,cnt_reason_nl          VARCHAR2(220)
,cntnt                  VARCHAR2(2080)
,ext_ctx_nm             VARCHAR2(25)
,ext_device_descr       VARCHAR2(70)
,ext_imei               VARCHAR2(40)
,ext_process_nm         VARCHAR2(45)
,ext_ticket_id          VARCHAR2(20)
,loc_addr               VARCHAR2(245)
,sales_ch_nm            VARCHAR2(55)
,sales_ch_addr          VARCHAR2(70)
,bet_tx_id              VARCHAR2(40)
,CONSTRAINT bus_comm_item_tx_type_check CHECK (tx_type IN ('C', 'U'))
,CONSTRAINT bus_comm_item_pk PRIMARY KEY (tx_id, item_row) USING INDEX TABLESPACE cds_idx
,CONSTRAINT bus_comm_item_bus_comm_id_fk FOREIGN KEY (bus_comm_id) REFERENCES bus_comm (bus_comm_id)
)
TABLESPACE cds_data
/

COMMENT ON TABLE  bus_comm_item IS 'Business communication items'
/
COMMENT ON COLUMN bus_comm_item.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm_item.mod_dt IS 'Date-time of record modification'
/
COMMENT ON COLUMN bus_comm_item.tx_id IS 'Transaction ID (UUID)'
/
COMMENT ON COLUMN bus_comm_item.tx_type IS 'Transaction type (C=creation/U=update)'
/
COMMENT ON COLUMN bus_comm_item.tx_dt IS 'Transaction date-time'
/
COMMENT ON COLUMN bus_comm_item.tx_app_id IS 'Application ID of the transaction creator'
/
COMMENT ON COLUMN bus_comm_item.bus_comm_id IS 'Business communication ID (UUID)'
/
COMMENT ON COLUMN bus_comm_item.item_row IS 'Item row number'
/
COMMENT ON COLUMN bus_comm_item.item_id IS 'Item ID (UUID)'
/
COMMENT ON COLUMN bus_comm_item.item_type IS 'Item type (PIM type)'
/
COMMENT ON COLUMN bus_comm_item.item_nm IS 'Item name'
/
COMMENT ON COLUMN bus_comm_item.item_descr IS 'Item description'
/
COMMENT ON COLUMN bus_comm_item.cmt IS 'Comment'
/
COMMENT ON COLUMN bus_comm_item.start_dt IS 'Item start date-time'
/
COMMENT ON COLUMN bus_comm_item.end_dt IS 'Item end date-time'
/
COMMENT ON COLUMN bus_comm_item.stat_cd IS 'Item status code (PIM code)'
/
COMMENT ON COLUMN bus_comm_item.att_id IS 'Attachment ID'
/
COMMENT ON COLUMN bus_comm_item.att_id_scope IS 'Attachment ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.att_id_ctx IS 'Attachment ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.lnk IS 'Webpage visit (URL) by customer'
/
COMMENT ON COLUMN bus_comm_item.handler_emp_id IS 'Employee (personnel) ID of communication handler'
/
COMMENT ON COLUMN bus_comm_item.handler_emp_id_scope IS 'Employeed ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.handler_emp_id_ctx IS 'Employee ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.subm_emp_id IS 'Employee (personnel) ID of business communication submitter'
/
COMMENT ON COLUMN bus_comm_item.subm_emp_id_scope IS 'Employeed ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.subm_emp_id_ctx IS 'Employee ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.handler_ext_id IS 'External (sales agent) ID of communication handler'
/
COMMENT ON COLUMN bus_comm_item.handler_ext_id_scope IS 'External ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.handler_ext_id_ctx IS 'External ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.comm_id IS 'Communication ID'
/
COMMENT ON COLUMN bus_comm_item.comm_id_scope IS 'Communication ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.comm_id_ctx IS 'Communication ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.case_id IS 'Case ID'
/
COMMENT ON COLUMN bus_comm_item.case_id_scope IS 'Case ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.case_id_ctx IS 'Case ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.wo_id IS 'Workorder ID'
/
COMMENT ON COLUMN bus_comm_item.wo_id_scope IS 'Workoder ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.wo_id_ctx IS 'Workorder ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.inc_id IS 'Incident ID'
/
COMMENT ON COLUMN bus_comm_item.inc_id_scope IS 'Incident ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.inc_id_ctx IS 'Incident ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.lead_id IS 'Lead ID'
/
COMMENT ON COLUMN bus_comm_item.lead_id_scope IS 'Lead ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.lead_id_ctx IS 'Lead ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.req_id IS 'Request ID'
/
COMMENT ON COLUMN bus_comm_item.req_id_scope IS 'Request ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_item.req_id_ctx IS 'Request ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_item.cnt_domain_cd IS 'Contact domain code (PIM code)'
/
COMMENT ON COLUMN bus_comm_item.prd_fam_cd IS 'Product family code'
/
COMMENT ON COLUMN bus_comm_item.cnt_reason_cd IS 'Contact reason code (PIM code, or CR999999 in case of IVR call selection by customer)'
/
COMMENT ON COLUMN bus_comm_item.cnt_reason_descr IS 'Contact reason description'
/
COMMENT ON COLUMN bus_comm_item.cnt_reason_en IS 'Contact reason description (English)'
/
COMMENT ON COLUMN bus_comm_item.cnt_reason_fr IS 'Contact reason description (Français)'
/
COMMENT ON COLUMN bus_comm_item.cnt_reason_nl IS 'Contact reason description (Nederlands)'
/
COMMENT ON COLUMN bus_comm_item.cntnt IS 'Content (e.g., SMS to or from customer)'
/
COMMENT ON COLUMN bus_comm_item.ext_ctx_nm IS 'External context name'
/
COMMENT ON COLUMN bus_comm_item.ext_device_descr IS 'External device description'
/
COMMENT ON COLUMN bus_comm_item.ext_imei IS 'External IMEI (=International Mobile Equipment Identity) number'
/
COMMENT ON COLUMN bus_comm_item.ext_process_nm IS 'External process name'
/
COMMENT ON COLUMN bus_comm_item.ext_ticket_id IS 'External ticket ID'
/
COMMENT ON COLUMN bus_comm_item.loc_addr IS 'Location address (e.g., installation address at customer)'
/
COMMENT ON COLUMN bus_comm_item.sales_ch_nm IS 'Sales channel name (e.g., shop name)'
/
COMMENT ON COLUMN bus_comm_item.sales_ch_addr IS 'Sales channel address'
/
COMMENT ON COLUMN bus_comm_item.bet_tx_id IS 'BET (=Billing Explanation Tool) transaction id'
/

CREATE INDEX bus_comm_item_bus_comm_id_fk ON bus_comm_item (bus_comm_id)
TABLESPACE cds_idx
/

CREATE INDEX bus_comm_item_ext_ticket_id ON bus_comm_item (ext_ticket_id)
TABLESPACE cds_idx
/

CREATE INDEX bus_comm_item_req_id ON bus_comm_item (req_id)
TABLESPACE cds_idx
/