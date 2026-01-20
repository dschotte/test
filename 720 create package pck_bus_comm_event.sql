CREATE OR REPLACE PACKAGE pck_bus_comm_event IS

        --
        -- Package: PCK_BUS_COMM_EVENT
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_event table
        --

        PROCEDURE add_event(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_event_type VARCHAR2, p_bus_comm_json BLOB);
        
        PROCEDURE clean;

END pck_bus_comm_event;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_event IS
        
        PROCEDURE add_event(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_event_type VARCHAR2, p_bus_comm_json BLOB) IS
                STAT_NEW CONSTANT CHAR(1) := 'N';
        BEGIN
                INSERT INTO bus_comm_event (
                        creation_dt,
                        tx_id,
                        tx_type,
                        tx_dt,
                        tx_app_id,
                        bus_comm_id,
                        event_type,
                        bus_comm_json,
                        stat_cd)
                VALUES (p_bus_comm_hist.creation_dt,
                        p_bus_comm_hist.tx_id,
                        p_bus_comm_hist.tx_type,
                        p_bus_comm_hist.tx_dt,
                        p_bus_comm_hist.tx_app_id,
                        p_bus_comm_hist.bus_comm_id,
                        p_event_type,
                        p_bus_comm_json,
                        STAT_NEW);
        END;

        --
        -- procedure scheduled as job BUS_COMM_EVENT_CLEAN; runs daily after midnight
        --

        PROCEDURE clean IS
                CURSOR c_partition(p_table_name VARCHAR2) IS
                        SELECT partition_name, high_value
                        FROM user_tab_partitions WHERE table_name = p_table_name AND partition_name != 'BUS_COMM_EVENT_00000000'
                        ORDER BY partition_name;
                v_ddl VARCHAR2(4000);
                v_high_date DATE;
                v_day VARCHAR2(11);
                SCHEMA_NAME CONSTANT VARCHAR2(10) := 'CDS_SCHEMA';
                TABLE_NAME CONSTANT VARCHAR2(14) := 'BUS_COMM_EVENT';
                v_partition_dropped BOOLEAN;
                no_global_index_cleaned EXCEPTION;
                PRAGMA EXCEPTION_INIT(no_global_index_cleaned, -20000);
        BEGIN
                --
                -- drop daily partitions, except of the last 14 days
                --
                FOR r_partition IN c_partition(TABLE_NAME) LOOP
                        v_high_date := TO_DATE(SUBSTR(r_partition.high_value, 12, 10), 'YYYY-MM-DD'); -- TIMESTAMP' YYYY-MM-DD 00:00:00'
                        IF v_high_date < SYSDATE - 13 THEN
                                v_day := TO_CHAR(v_high_date - 1, 'Mon DD YYYY');
                                v_ddl := 'ALTER TABLE ' || TABLE_NAME || ' DROP PARTITION ' || r_partition.partition_name || ' UPDATE INDEXES'; -- asynchronous global index maintenance
                                EXECUTE IMMEDIATE v_ddl;
                                v_partition_dropped := TRUE;
                        END IF;
                END LOOP;
                --
                -- it is recommended to gather statistics on the table and cleanup global indexes after dropping partitions
                --
                IF v_partition_dropped THEN
                        DBMS_STATS.GATHER_TABLE_STATS(ownname => SCHEMA_NAME
                                ,tabname => TABLE_NAME
                                ,estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE
                                ,granularity => 'AUTO'
                                ,cascade => DBMS_STATS.AUTO_CASCADE
                                );
                        DBMS_OUTPUT.PUT_LINE(v_day || ' cleaned');
                        BEGIN
                                DBMS_PART.CLEANUP_GIDX(SCHEMA_NAME, TABLE_NAME);
                        EXCEPTION WHEN no_global_index_cleaned THEN
                                NULL;
                        END;
                ELSE
                        DBMS_OUTPUT.PUT_LINE('Clean');
                END IF;
        END;

END pck_bus_comm_event;
/
