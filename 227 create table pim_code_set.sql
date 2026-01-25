--
-- Table: PIM_CODE_SET
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------
-- 1.0          27/01/2025      Initial version
--
-- Remarks:
-- 1. loaded reference data
--

CREATE TABLE pim_code_set
(set_nm         VARCHAR2(80)    NOT NULL
,set_id         VARCHAR2(36)
,set_id_scope   VARCHAR2(3)
,set_id_ctx     VARCHAR2(10)
,CONSTRAINT pim_code_set_pk PRIMARY KEY (set_nm) USING INDEX TABLESPACE cds_idx
)
TABLESPACE cds_data
/

BEGIN syn_mgr.create_synonym('pim_code_set'); END;
/
GRANT SELECT ON pim_code_set TO cds_online
/

COMMENT ON TABLE pim_code_set IS 'PIM code set'
/
COMMENT ON COLUMN pim_code_set.set_nm IS 'Set name'
/
COMMENT ON COLUMN pim_code_set.set_id IS 'Set ID'
/
COMMENT ON COLUMN pim_code_set.set_id_scope IS 'Set ID scope'
/
COMMENT ON COLUMN pim_code_set.set_id_ctx IS 'Set ID context'
/
