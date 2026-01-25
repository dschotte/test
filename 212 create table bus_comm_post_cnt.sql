--
-- Table: BUS_COMM_POST_CNT
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          13/01/2026      Initial version
--
-- Remarks:
-- 1. Business communication postal contacts
--

CREATE TABLE bus_comm_post_cnt 
(creation_dt            TIMESTAMP	NOT NULL
,tx_id                  RAW(16)         NOT NULL
,tx_type                VARCHAR2(1)     NOT NULL
,tx_dt                  TIMESTAMP	NOT NULL
,tx_app_id              VARCHAR2(20)    NOT NULL
,bus_comm_id            RAW(16)         NOT NULL
,start_dt               TIMESTAMP       NOT NULL
,role_row               NUMBER(2)       NOT NULL
,role_type              VARCHAR2(20)    NOT NULL
,first_nm               VARCHAR2(75)
,last_nm                VARCHAR2(60)
,geo_id                 VARCHAR2(20)
,geo_id_scope           VARCHAR2(3)
,geo_id_ctx             VARCHAR2(15)
,road_nm                VARCHAR2(85)
,house_num              VARCHAR2(35)
,house_num_sfx          VARCHAR2(30)
,box_num                VARCHAR2(35)
,apt_num                VARCHAR2(20)
,block_num              VARCHAR2(20)
,floor_num              VARCHAR2(40)
,zip_cd                 VARCHAR2(20)
,geo_area_nm            VARCHAR2(55)
,ctry_cd                VARCHAR2(20)
,ctry_nm                VARCHAR2(50)
,CONSTRAINT bus_comm_post_cnt_tx_type_check CHECK (tx_type = 'C')
,CONSTRAINT bus_comm_post_cnt_pk PRIMARY KEY (tx_id, role_row) USING INDEX TABLESPACE cds_idx
,CONSTRAINT bus_comm_post_cnt_bus_comm_id_fk FOREIGN KEY (bus_comm_id) REFERENCES bus_comm (bus_comm_id)
)
TABLESPACE cds_data
/

COMMENT ON TABLE  bus_comm_post_cnt IS 'Business communication postal contacts'
/
COMMENT ON COLUMN bus_comm_post_cnt.creation_dt IS 'Date-time of record creation'
/
COMMENT ON COLUMN bus_comm_post_cnt.tx_id IS 'Transaction ID (UUID)'
/
COMMENT ON COLUMN bus_comm_post_cnt.tx_type IS 'Transaction type (C=creation/U=update)'
/
COMMENT ON COLUMN bus_comm_post_cnt.tx_dt IS 'Transaction date-time'
/
COMMENT ON COLUMN bus_comm_post_cnt.tx_app_id IS 'Application ID of the transaction creator'
/
COMMENT ON COLUMN bus_comm_post_cnt.bus_comm_id IS 'Business communication ID (UUID)'
/
COMMENT ON COLUMN bus_comm_post_cnt.start_dt IS 'Business communication start date-time'
/
COMMENT ON COLUMN bus_comm_post_cnt.role_row IS 'Role row number'
/
COMMENT ON COLUMN bus_comm_post_cnt.role_type IS 'Role type (SENT_TO)'
/
COMMENT ON COLUMN bus_comm_post_cnt.first_nm IS 'First name of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.last_nm IS 'Last name of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.geo_id IS 'Geograhpical ID'
/
COMMENT ON COLUMN bus_comm_post_cnt.geo_id_scope IS 'Geograhpical ID scope (ENT=enterprise)'
/
COMMENT ON COLUMN bus_comm_post_cnt.geo_id_ctx IS 'Geograhpical ID context (master application ID)'
/
COMMENT ON COLUMN bus_comm_post_cnt.road_nm IS 'Road name of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.house_num IS 'House number of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.house_num_sfx IS 'House number suffix of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.box_num IS 'Box number suffix of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.apt_num IS 'Apartment number suffix of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.block_num IS 'Block number suffix of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.floor_num IS 'Floor number suffix of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.zip_cd IS 'ZIP code of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.geo_area_nm IS 'Geographical area name of receiver'
/
COMMENT ON COLUMN bus_comm_post_cnt.ctry_cd IS 'Country code of receiver (ISO3)'
/
COMMENT ON COLUMN bus_comm_post_cnt.ctry_nm IS 'Country name of receiver'
/

CREATE INDEX bus_comm_post_cnt_bus_comm_id_fk ON bus_comm_post_cnt (bus_comm_id)
TABLESPACE cds_idx
/
