--
-- Table: BUS_COMM_TMP
--
-- Version      Date            Comments
-- -------      ----------      --------------------------------------------------------------------------------------------
-- 1.0          23/01/2025      Initial version
--
-- Remarks:
-- 1. business communication temporary table
--

CREATE GLOBAL TEMPORARY TABLE bus_comm_tmp ( bus_comm_id RAW(16) )
ON COMMIT DELETE ROWS
/
