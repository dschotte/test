--
-- Table: BATCH_RUN
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------
-- 1.0          12/01/2026      Initial version
--
-- Remarks:
-- 1. Technical log of batch runs
--

CREATE TABLE batch_run
(batch_nm	VARCHAR2(32)	NOT NULL
,last_run_dt	TIMESTAMP
,batch_msg	VARCHAR2(40)
,CONSTRAINT batch_run_pk PRIMARY KEY (batch_nm) USING INDEX TABLESPACE cds_idx
)
TABLESPACE cds_data
/

COMMENT ON TABLE batch_run IS 'Technical log of batch runs'
/
COMMENT ON COLUMN batch_run.batch_nm IS 'Name of the batch'
/
COMMENT ON COLUMN batch_run.last_run_dt IS 'Date-time of the last run'
/
COMMENT ON COLUMN batch_run.batch_msg IS 'Batch message'
/

BEGIN syn_mgr.create_synonym('batch_run'); END;
/
GRANT SELECT ON batch_run TO cds_online
/
