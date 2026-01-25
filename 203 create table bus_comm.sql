--
-- Table: BUS_COMM
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          12/01/2026      Initial version
--
-- Remarks:
-- 1. Business communications
--

CREATE TABLE bus_comm
(creation_dt            TIMESTAMP       NOT NULL
,mod_dt                 TIMESTAMP       NOT NULL
,ret_cd                 VARCHAR2(2)     NOT NULL
,ret_dt                 TIMESTAMP       GENERATED ALWAYS AS (DECODE(ret_cd, 'JO', ADD_MONTHS(GREATEST(creation_dt, NVL(start_dt, creation_dt)), 36), ADD_MONTHS(GREATEST(creation_dt, NVL(start_dt, creation_dt)), 13))) NOT NULL
,bus_comm_id            RAW(16)         NOT NULL
,start_dt               TIMESTAMP
,cust_id                VARCHAR2(9)
,cust_id_scope          VARCHAR2(3)
,cust_id_ctx            VARCHAR2(15)
,cust_mood_cd           VARCHAR2(20)
,cust_order_id          VARCHAR2(30)
,cust_order_id_scope    VARCHAR2(3)
,cust_order_id_ctx      VARCHAR2(20)
,stat_cd                VARCHAR2(20)
,stat_start_dt          TIMESTAMP
,CONSTRAINT bus_comm_pk PRIMARY KEY (bus_comm_id)
,CONSTRAINT bus_comm_ret_cd_check CHECK (ret_cd IN ('DF','JO'))
)
TABLESPACE cds_data
/

COMMENT ON TABLE  bus_comm IS 'Business communications'
/
COMMENT ON COLUMN bus_comm.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm.mod_dt IS 'Date-time of record modification'
/
COMMENT ON COLUMN bus_comm.ret_cd IS 'Business communication retention code (DF=default/JO=joint offer)'
/
COMMENT ON COLUMN bus_comm.ret_dt IS 'Date-time of business communication retention'
/
COMMENT ON COLUMN bus_comm.bus_comm_id IS 'Business communication ID (UUID)'
/
COMMENT ON COLUMN bus_comm.start_dt IS 'Business communication start date-time'
/
COMMENT ON COLUMN bus_comm.cust_id IS 'Customer ID'
/
COMMENT ON COLUMN bus_comm.cust_id_scope IS 'Customer ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm.cust_id_ctx IS 'Customer ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm.cust_order_id IS 'Customer order ID'
/
COMMENT ON COLUMN bus_comm.cust_order_id_scope IS 'Customer order ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm.cust_order_id_ctx IS 'Customer order ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm.stat_cd IS 'Business communication status code (PIM code)'
/
COMMENT ON COLUMN bus_comm.stat_start_dt IS 'Business communication status start date-time'
/

CREATE INDEX bus_comm_mod_idx ON bus_comm (mod_dt, bus_comm_id)
TABLESPACE cds_idx
/

CREATE INDEX bus_comm_ret_dt_idx ON bus_comm (ret_dt)
TABLESPACE cds_idx
/

CREATE INDEX bus_comm_cust_idx ON bus_comm (cust_id, start_dt, ret_cd)
TABLESPACE cds_idx
/

CREATE INDEX bus_comm_cust_order_idx ON bus_comm (cust_order_id, start_dt, ret_cd)
TABLESPACE cds_idx
/
