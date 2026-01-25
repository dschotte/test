--
-- Table: KEY_STORE
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          27/01/2025      Initial version
--
-- Remarks:
-- 1. used key stores
--

CREATE TABLE key_store
(loaded_dt      TIMESTAMP       NOT NULL
,data_ctr       VARCHAR2(10)    NOT NULL
,module_nm      VARCHAR2(30)    NOT NULL
,path           VARCHAR2(40)    NOT NULL
,key_store_tp   VARCHAR2(10)    NOT NULL
,data           BLOB
,cert_start_dt  TIMESTAMP
,cert_end_dt    TIMESTAMP
,cert_subject   VARCHAR2(150)
,CONSTRAINT key_store_pk PRIMARY KEY (data_ctr, module_nm, path) USING INDEX TABLESPACE cds_idx
,CONSTRAINT key_store_data_ctr_check CHECK (data_ctr IN ('Carli', 'Mechelen', 'localhost'))
,CONSTRAINT key_store_module_nm_check CHECK (module_nm IN ('CDS_BAM','CDS_EVENT','TEST'))
,CONSTRAINT key_store_path_check CHECK (path IN ('/deployments/data/keystore/client', '/deployments/data/keystore/server', '/deployments/data/truststore'))
)
TABLESPACE cds_data
/

BEGIN syn_mgr.create_synonym('key_store'); END;
/
GRANT SELECT ON key_store TO cds_online
/

COMMENT ON TABLE key_store IS 'Used key store'
/
COMMENT ON COLUMN key_store.loaded_dt IS 'Date and time of when the key store was loaded'
/
COMMENT ON COLUMN key_store.data_ctr IS 'Data center where the module runs (Carli,Mechelen,localhost)'
/
COMMENT ON COLUMN key_store.module_nm IS 'Name of the module that loaded the key store (CDS_EVENT,CDS_BAM,TEST)'
/
COMMENT ON COLUMN key_store.path IS 'Path with which the key store is associated (/deployments/data/keystore/client,/deployments/data/keystore/server,/deployments/data/truststore)'
/
COMMENT ON COLUMN key_store.key_store_tp IS 'Type of key store, e.g. JKS'
/
COMMENT ON COLUMN key_store.data IS 'Serialized key store data'
/
COMMENT ON COLUMN key_store.cert_start_dt IS 'Start date and time of the certificate''s validity period'
/
COMMENT ON COLUMN key_store.cert_end_dt IS 'End date and time of the certificate''s validity period'
/
COMMENT ON COLUMN key_store.cert_subject IS 'Subject from the certificate'
/
