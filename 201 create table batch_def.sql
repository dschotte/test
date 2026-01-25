--
-- Table: BATCH_DEF
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------
-- 1.0          12/01/2026      Initial version
--
-- Remarks:
-- 1. Technical defintion of runnable batches
--

CREATE TABLE batch_def
(batch_nm       VARCHAR2(32)    NOT NULL
,batch_descr    VARCHAR2(60)    NOT NULL
,scheduled      VARCHAR2(1)     DEFAULT 'N' NOT NULL
,CONSTRAINT batch_def_pk PRIMARY KEY (batch_nm) USING INDEX TABLESPACE cds_idx
,CONSTRAINT batch_def_scheduled_check CHECK (scheduled IN ('Y','N'))
)
TABLESPACE cds_data
/

COMMENT ON TABLE  batch_def IS 'Technical defintion of runnable batches'
/
COMMENT ON COLUMN batch_def.batch_nm IS 'Name of the batch'
/
COMMENT ON COLUMN batch_def.batch_descr IS 'Batch description'
/
COMMENT ON COLUMN batch_def.scheduled IS 'Is the batch scheduled? (Y/N)'
/

BEGIN syn_mgr.create_synonym('batch_def'); END;
/
GRANT SELECT ON batch_def TO cds_online
/
