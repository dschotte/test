--
-- Table: BUS_COMM_ITEM_DEF
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------
-- 1.0          13/01/2026      Initial version
--
-- Remarks:
-- 1. Functional defintion of business communication items
--

CREATE TABLE bus_comm_item_def
(item_type      VARCHAR2(40)    NOT NULL
,seq            NUMBER(1)       NOT NULL
,main_item      VARCHAR2(1)     DEFAULT 'N' NOT NULL
,CONSTRAINT bus_comm_item_def_pk PRIMARY KEY (item_type) USING INDEX TABLESPACE cds_idx
,CONSTRAINT bus_comm_item_def_main_item_check CHECK (main_item IN ('Y','N'))
)
TABLESPACE cds_data
/

COMMENT ON TABLE  bus_comm_item_def IS 'Functional defintion of business communication items'
/
COMMENT ON COLUMN bus_comm_item_def.seq IS 'Sequence number'
/
COMMENT ON COLUMN bus_comm_item_def.main_item IS 'Is main item? (Y/N)'
/

BEGIN syn_mgr.create_synonym('bus_comm_item_def'); END;
/
GRANT SELECT ON bus_comm_item_def TO cds_online
/
