--
-- Table: BUS_COMM_HIST
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          14/01/2026      Initial version
--
-- Remarks:
-- 1. Business communication history (transactions)
--

CREATE TABLE bus_comm_hist
(creation_dt            TIMESTAMP       NOT NULL
,tx_id                  RAW(16)         NOT NULL
,tx_type                VARCHAR2(1)     NOT NULL
,tx_dt                  TIMESTAMP       NOT NULL
,tx_app_id              VARCHAR2(15)    NOT NULL
,bus_comm_id            RAW(16)         NOT NULL
,start_dt               TIMESTAMP
,end_dt                 TIMESTAMP
,cust_id                VARCHAR2(20)
,cust_id_scope          VARCHAR2(3)
,cust_id_ctx            VARCHAR2(10)
,cust_lookup_ind        VARCHAR2(1)
,cust_orig_id           VARCHAR2(20)
,acct_id                VARCHAR2(25)
,acct_id_scope          VARCHAR2(3)
,acct_id_ctx            VARCHAR2(10)
,subm_app_id            VARCHAR2(20)
,cust_mood_cd           VARCHAR2(20)
,subm_org_id            VARCHAR2(20)
,subm_org_id_scope      VARCHAR2(3)
,subm_org_id_ctx        VARCHAR2(10)
,cust_order_id          VARCHAR2(40)
,cust_order_id_scope    VARCHAR2(3)
,cust_order_id_ctx      VARCHAR2(20)
,lang_cd                VARCHAR2(5)
,bus_comm_nm            VARCHAR2(60)
,bus_comm_descr         VARCHAR2(240)
,stat_cd                VARCHAR2(20)
,stat_start_dt          TIMESTAMP
,dir_cd                 VARCHAR2(20)
,ch_class_cd            VARCHAR2(20)
,bus_comm_branding      VARCHAR2(10)
,bus_comm_type          VARCHAR2(20)
,campaign_id            VARCHAR2(60)
,campaign_nm            VARCHAR2(50)
,svc_nm                 VARCHAR2(20)
,subm_org_nm            VARCHAR2(40)
,tpl_id                 VARCHAR2(80)
,tpl_nm                 VARCHAR2(120)
,tpl_descr              VARCHAR2(180)
,CONSTRAINT bus_comm_hist_tx_type_check CHECK (tx_type IN ('C', 'U'))
,CONSTRAINT bus_comm_hist_pk PRIMARY KEY (tx_id)
,CONSTRAINT bus_comm_hist_bus_comm_id_fk FOREIGN KEY (bus_comm_id) REFERENCES bus_comm (bus_comm_id)
,CONSTRAINT bus_comm_hist_cust_lookup_ind_check CHECK (cust_lookup_ind = 'L')
)
TABLESPACE cds_data
/

COMMENT ON TABLE  bus_comm_hist IS 'Business communication history (transactions)'
/
COMMENT ON COLUMN bus_comm_hist.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm_hist.tx_id IS 'Transaction ID (UUID)'
/
COMMENT ON COLUMN bus_comm_hist.tx_type IS 'Transaction type (C=creation/U=update)'
/
COMMENT ON COLUMN bus_comm_hist.tx_dt IS 'Transaction date-time'
/
COMMENT ON COLUMN bus_comm_hist.tx_app_id IS 'Application ID of the transaction creator'
/
COMMENT ON COLUMN bus_comm_hist.bus_comm_id IS 'Business communication ID (UUID)'
/
COMMENT ON COLUMN bus_comm_hist.start_dt IS 'Business communication start date-time'
/
COMMENT ON COLUMN bus_comm_hist.end_dt IS 'Business communication end date-time'
/
COMMENT ON COLUMN bus_comm_hist.cust_id IS 'Customer ID'
/
COMMENT ON COLUMN bus_comm_hist.cust_id_scope IS 'Customer ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_hist.cust_id_ctx IS 'Customer ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_hist.acct_id IS 'Account ID'
/
COMMENT ON COLUMN bus_comm_hist.acct_id_scope IS 'Account ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_hist.acct_id_ctx IS 'Account ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_hist.subm_app_id IS 'Application ID of the communication submitter'
/
COMMENT ON COLUMN bus_comm_hist.cust_mood_cd IS 'Customer mood code (PIM code)'
/
COMMENT ON COLUMN bus_comm_hist.subm_org_id IS 'Organization ID of the communication submitter'
/
COMMENT ON COLUMN bus_comm_hist.subm_org_id_scope IS 'Organization ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_hist.subm_org_id_ctx IS 'Organization ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_hist.cust_order_id IS 'Customer order ID'
/
COMMENT ON COLUMN bus_comm_hist.cust_order_id_scope IS 'Customer order ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_hist.cust_order_id_ctx IS 'Customer order ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_hist.lang_cd IS 'Business communication language code (ISO2)'
/
COMMENT ON COLUMN bus_comm_hist.bus_comm_nm IS 'Business communication name'
/
COMMENT ON COLUMN bus_comm_hist.bus_comm_descr IS 'Business communication description'
/
COMMENT ON COLUMN bus_comm_hist.stat_cd IS 'Business communication status code (PIM code)'
/
COMMENT ON COLUMN bus_comm_hist.stat_start_dt IS 'Business communication status start date-time'
/
COMMENT ON COLUMN bus_comm_hist.dir_cd IS 'Business communication direction code (PIM code)'
/
COMMENT ON COLUMN bus_comm_hist.ch_class_cd IS 'Business communication channel classification code (PIM code)'
/
COMMENT ON COLUMN bus_comm_hist.bus_comm_branding IS 'Business communication branding (PROXIMUS,SCARLET)'
/
COMMENT ON COLUMN bus_comm_hist.bus_comm_type IS 'Business communication type'
/
COMMENT ON COLUMN bus_comm_hist.campaign_id IS 'Campaign ID'
/
COMMENT ON COLUMN bus_comm_hist.campaign_nm IS 'Campaign name'
/
COMMENT ON COLUMN bus_comm_hist.svc_nm IS 'Service name'
/
COMMENT ON COLUMN bus_comm_hist.subm_org_nm IS 'Organization name of the communication submitter'
/
COMMENT ON COLUMN bus_comm_hist.tpl_id IS 'Template ID'
/
COMMENT ON COLUMN bus_comm_hist.tpl_nm IS 'Template name'
/
COMMENT ON COLUMN bus_comm_hist.tpl_descr IS 'Template description'
/

CREATE INDEX bus_comm_hist_bus_comm_id_fk ON bus_comm_hist (bus_comm_id)
TABLESPACE cds_idx
/

CREATE UNIQE INDEX bus_comm_hist_tx_c ON bus_comm_hist (DECODE(tx_tp, 'C', bc_uuid))
TABLESPACE cds_idx
/

CREATE INDEX bus_comm_hist_creation_dt ON bus_comm_hist (creation_dt)
TABLESPACE cds_idx
/