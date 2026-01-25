--
-- Table: PIM_CODE
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------
-- 1.0          27/01/2025      Initial version
--
-- Remarks:
-- 1. loaded reference data
--

CREATE TABLE pim_code
(set_nm         VARCHAR2(80)    NOT NULL
,val            VARCHAR2(20)    NOT NULL
,val_descr_en   VARCHAR2(200)
,val_descr_fr   VARCHAR2(200)
,val_descr_nl   VARCHAR2(200)
,load_dt        TIMESTAMP
,CONSTRAINT pim_code_pk PRIMARY KEY (set_nm, val) USING INDEX TABLESPACE cds_idx
,CONSTRAINT pim_code_set_nm_fk FOREIGN KEY (set_nm) REFERENCES pim_code_set (set_nm)
)
TABLESPACE cds_data
/

BEGIN syn_mgr.create_synonym('pim_code'); END;
/
GRANT SELECT ON pim_code TO cds_online
/

COMMENT ON TABLE pim_code IS 'PIM code'
/
COMMENT ON COLUMN pim_code.set_nm IS 'Set name'
/
COMMENT ON COLUMN pim_code.val IS 'Value'
/
COMMENT ON COLUMN pim_code.val_descr_en IS 'Value description (label) in English'
/
COMMENT ON COLUMN pim_code.val_descr_fr IS 'Value description (label) in French'
/
COMMENT ON COLUMN pim_code.val_descr_nl IS 'Value description (label) in Dutch'
/
COMMENT ON COLUMN pim_code.load_dt IS 'Date-time of load'
/
