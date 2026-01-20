CREATE OR REPLACE PACKAGE pck_bus_comm_sync_log IS

        --
        -- Package: PCK_BUS_COMM_SYNC_LOG
        --
        -- Version      Date            Comments
        -- -------      ----------      ------------------------------------------------------------------------------------------------------------------------
        -- 1.0          22/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_sync_log table
        --

        PROCEDURE clean;

        PROCEDURE log_list(p_reader_app_id VARCHAR2, p_bus_comm_ids_json BLOB);
        
        PROCEDURE log_list_mod(p_reader_app_id VARCHAR2, p_since_mod_dt TIMESTAMP, p_before_mod_dt TIMESTAMP);

END pck_bus_comm_sync_log;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_sync_log IS

        PROCEDURE clean
        IS
                CURSOR c_partition IS
                        SELECT partition_name, high_value
                        FROM user_tab_partitions WHERE table_name = 'BUS_COMM_SYNC_LOG' AND partition_name != 'BUS_COMM_SYNC_LOG_000000'
                        ORDER BY partition_name;
                v_ddl VARCHAR2(4000);
                v_high_date DATE;
                v_month VARCHAR2(8);
        BEGIN
                --
                -- drop monthly partitions except the last two; used manually
                --
                FOR r_partition IN c_partition LOOP
                        v_high_date := TO_DATE(SUBSTR(r_partition.high_value, 12, 10), 'YYYY-MM-DD'); -- TIMESTAMP' YYYY-MM-DD 00:00:00'
                        IF v_high_date < ADD_MONTHS(SYSDATE, -1) THEN
                                v_month := TO_CHAR(v_high_date - 1, 'YYYY-MON');
                                DBMS_OUTPUT.PUT_LINE(v_month);
                                v_ddl := 'ALTER TABLE bus_comm_sync_log DROP PARTITION ' || r_partition.partition_name || ' UPDATE INDEXES';
                                DBMS_OUTPUT.PUT_LINE(v_ddl);
                                EXECUTE IMMEDIATE v_ddl;
                        END IF;
                END LOOP;
        END;
       
        PROCEDURE log_list(p_reader_app_id VARCHAR2, p_bus_comm_ids_json BLOB) IS
                API_LIST CONSTANT CHAR(4) := 'LIST';
                PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
                INSERT INTO bus_comm_sync_log (creation_dt,
                        api_op,
                        reader_app_id,
                        bus_comm_ids_json
                ) VALUES (SYSTIMESTAMP,
                        API_LIST,
                        SUBSTR(p_reader_app_id, 1, 20),
                        p_bus_comm_ids_json
                );
                COMMIT;
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;

        PROCEDURE log_list_mod(p_reader_app_id VARCHAR2, p_since_mod_dt TIMESTAMP, p_before_mod_dt TIMESTAMP) IS
                API_LIST_MOD CONSTANT CHAR(8) := 'LIST_MOD';
                PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
                INSERT INTO bus_comm_sync_log (creation_dt,
                        api_op,
                        reader_app_id,
                        since_mod_dt,
                        before_mod_dt
                ) VALUES (SYSTIMESTAMP,
                        API_LIST_MOD,
                        SUBSTR(p_reader_app_id, 1, 20),
                        p_since_mod_dt,
                        p_before_mod_dt
                );
                COMMIT;
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;        
       
END pck_bus_comm_sync_log;
/
