--
-- Table: CUST_LOOKUP_LOAD
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          27/01/2025      Initial version
--
-- Remarks:
-- 1. customer lookup table
--

CREATE TABLE cust_lookup_load
(ctry_pfx	VARCHAR2(5)  	NOT NULL
,natl_nr	VARCHAR2(16) 	NOT NULL
,cust_id	VARCHAR2(9)  	NOT NULL
,cust_id_scope	VARCAHR2(3)
,cust_id_ctx	VARCHAR2(10)
,acct_id	VARCHAR2(25)
,load_dt	TIMESTAMP
)
TABLESPACE CDS_DATA
/

CREATE INDEX cust_lookup_load_natl_num_idx ON cust_lookup (natl_nr)
TABLESPACE cds_idx
/

CREATE INDEX cust_lookup_load_acct_id_idx ON cust_lookup (acct_id)
TABLESPACE cds_idx
/
