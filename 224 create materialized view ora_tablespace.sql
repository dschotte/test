--
-- Materialized view: ORA_TABLESPACE
--
-- Version      Date            Comments
-- -------      ----------      ----------------------------------------------------------------------------------------------------
-- 1.0          26/01/2025      Initial version
--
-- Remarks:
-- 1. needed because privileges granted through SELECT_CATALOG_ROLE to CDS_SCHEMA are not recognized within packages executed by CDS_ONLINE
-- 2. materialized view refrehes immediately and next every hour on the hour
--

DROP MATERIALIZED VIEW ora_tablespace
/

CREATE MATERIALIZED VIEW ora_tablespace
TABLESPACE cds_data
REFRESH COMPLETE ON DEMAND START WITH (TRUNC(SYSDATE, 'HH')) NEXT (TRUNC(SYSDATE + 1/24, 'HH'))
DISABLE QUERY REWRITE
AS SELECT JSON_OBJECT('tablespaceNm' VALUE tablespace_name
                     ,'totalMb' VALUE total_mb
                     ,'freeMb' VALUE free_mb
                     ,'usedMb' VALUE used_mb
                     ,'usedPct' VALUE used_pct
                     ,'safe' VALUE CASE WHEN used_pct < 95 THEN 'Y' ELSE 'N' END
                     ,'refreshedDt' VALUE TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD"T"HH24:MI:SS.FF')
                     ,'databaseNm' VALUE REPLACE(ORA_DATABASE_NAME, '.BC', NULL) RETURNING BLOB
                     ) AS root_obj
FROM ( SELECT t.tablespace_name,
              t.mb AS total_mb,
              f.mb AS free_mb,
              t.mb - f.mb AS used_mb,
              ROUND(((t.mb - f.mb) / t.mb) * 100, 0) AS used_pct
       FROM   ( 
              SELECT tablespace_name, ROUND(SUM(bytes) / 1024 / 1024) AS mb
              FROM dba_data_files
              GROUP BY tablespace_name
              ) t, (
              SELECT tablespace_name, ROUND(SUM(bytes) / 1024 / 1024) AS mb
              FROM dba_free_space
              GROUP BY tablespace_name
              ) f
       WHERE t.tablespace_name = f.tablespace_name AND t.tablespace_name IN ('CDS_DATA', 'CDS_IDX')
)
/

BEGIN syn_mgr.create_synonym('ora_tablespace'); END;
/
GRANT SELECT ON ora_tablespace TO cds_online
/
