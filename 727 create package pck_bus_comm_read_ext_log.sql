CREATE OR REPLACE PACKAGE pck_bus_comm_read_ext_log IS

        --
        -- Package: PCK_BUS_COMM_READ_EXT_LOG
        --
        -- Version      Date            Comments
        -- -------      ----------      ------------------------------------------------------------------------------------------------------------------------
        -- 1.0          22/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_read_ext_log table
        --

        PROCEDURE clean;

        PROCEDURE log_find(p_reader_app_id VARCHAR2, p_offset_num NUMBER, p_next_num NUMBER, p_sorting_dir VARCHAR2, p_ctry_pfx VARCHAR2, p_natl_num VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_dir_cd VARCHAR2, p_subm_app_id VARCHAR2, p_ch_class_cd VARCHAR2);

END pck_bus_comm_read_ext_log;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_read_ext_log IS

        PROCEDURE clean
        IS
                CURSOR c_partition IS
                        SELECT partition_name, high_value
                        FROM user_tab_partitions WHERE table_name = 'BUS_COMM_READ_EXT_LOG' AND partition_name != 'BUS_COMM_READ_EXT_LOG_000000'
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
                                v_ddl := 'ALTER TABLE bus_comm_read_ext_log DROP PARTITION ' || r_partition.partition_name || ' UPDATE INDEXES';
                                DBMS_OUTPUT.PUT_LINE(v_ddl);
                                EXECUTE IMMEDIATE v_ddl;
                        END IF;
                END LOOP;
        END;
       
        PROCEDURE log_find(p_reader_app_id VARCHAR2, p_offset_num NUMBER, p_next_num NUMBER, p_sorting_dir VARCHAR2, p_ctry_pfx VARCHAR2, p_natl_num VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_dir_cd VARCHAR2, p_subm_app_id VARCHAR2, p_ch_class_cd VARCHAR2) IS
                API_FIND CONSTANT VARCHAR2(4) := 'FIND';
                PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
                INSERT INTO bus_comm_read_ext_log (creation_dt,
                        api_op,
                        reader_app_id,
                        offset_num,
                        next_num,
                        sorting_dir,
                        ctry_pfx,
                        natl_num,
                        since_start_dt,
                        before_start_dt,
                        dir_cd,
                        subm_app_id,
                        ch_class_cd
                ) VALUES (SYSTIMESTAMP,
                        API_FIND,
                        SUBSTR(p_reader_app_id, 1, 20),
                        p_offset_num,
                        p_next_num,
                        SUBSTR(p_sorting_dir, 1, 4),
                        SUBSTR(p_ctry_pfx, 1, 5),
                        SUBSTR(p_natl_num, 1, 16),
                        p_since_start_dt,
                        p_before_start_dt,
                        SUBSTR(p_dir_cd, 1, 20),
                        SUBSTR(p_subm_app_id, 1, 20),
                        SUBSTR(p_ch_class_cd, 1, 20)
                );
                COMMIT;
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;
        
END pck_bus_comm_read_ext_log;
/
