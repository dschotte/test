CREATE OR REPLACE PACKAGE pck_bus_comm_read_log IS

        --
        -- Package: PCK_BUS_COMM_READ_LOG
        --
        -- Version      Date            Comments
        -- -------      ----------      ------------------------------------------------------------------------------------------------------------------------
        -- 1.0          22/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_read_log table
        --

        PROCEDURE clean;

        PROCEDURE log_find(p_reader_app_id VARCHAR2, p_req_id VARCHAR2, p_req_id_ctx VARCHAR2, p_cust_order_id VARCHAR2, p_cust_order_id_ctx VARCHAR2, p_cust_id VARCHAR2, p_cust_id_ctx VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_jo_only VARCHAR2, p_trade_in_only VARCHAR2);

        PROCEDURE log_get(p_reader_app_id VARCHAR2, p_bus_comm_id RAW);

END pck_bus_comm_read_log;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_read_log IS

        PROCEDURE clean
        IS
                CURSOR c_partition IS
                        SELECT partition_name, high_value
                        FROM user_tab_partitions WHERE table_name = 'BUS_COMM_READ_LOG' AND partition_name != 'BUS_COMM_READ_LOG_000000'
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
                                v_ddl := 'ALTER TABLE bus_comm_read_log DROP PARTITION ' || r_partition.partition_name || ' UPDATE INDEXES';
                                DBMS_OUTPUT.PUT_LINE(v_ddl);
                                EXECUTE IMMEDIATE v_ddl;
                        END IF;
                END LOOP;
        END;
       
        PROCEDURE log_find(p_reader_app_id VARCHAR2, p_req_id VARCHAR2, p_req_id_ctx VARCHAR2, p_cust_order_id VARCHAR2, p_cust_order_id_ctx VARCHAR2, p_cust_id VARCHAR2, p_cust_id_ctx VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_jo_only VARCHAR2, p_trade_in_only VARCHAR2) IS
                API_FIND CONSTANT CHAR(4) := 'FIND';
                PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
                INSERT INTO bus_comm_read_log (creation_dt,
                        api_op,
                        reader_app_id,
                        req_id,
                        req_id_ctx,
                        cust_order_id,
                        cust_order_id_ctx,
                        cust_id,
                        cust_id_ctx,
                        since_start_dt,
                        before_start_dt,
                        jo_only,
                        trade_in_only
                ) VALUES (SYSTIMESTAMP,
                        API_FIND,
                        SUBSTR(p_reader_app_id, 1, 20),
                        SUBSTR(p_req_id, 1, 40),
                        SUBSTR(p_req_id_ctx, 1, 20),
                        SUBSTR(p_cust_order_id, 1, 40),
                        SUBSTR(p_cust_order_id_ctx, 1, 20),
                        SUBSTR(p_cust_id, 1, 20),
                        SUBSTR(p_cust_id_ctx, 1, 20),
                        p_since_start_dt,
                        p_before_start_dt,
                        SUBSTR(p_jo_only, 1, 1),
                        SUBSTR(p_trade_in_only, 1, 1)
                );
                COMMIT;
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;

        PROCEDURE log_get(p_reader_app_id VARCHAR2, p_bus_comm_id RAW) IS
                API_GET CONSTANT CHAR(3) := 'GET';
                PRAGMA AUTONOMOUS_TRANSACTION;
        BEGIN
                INSERT INTO bus_comm_read_log (creation_dt,
                        api_op,
                        reader_app_id,
                        bus_comm_id
                ) VALUES (SYSTIMESTAMP,
                        API_GET,
                        SUBSTR(p_reader_app_id, 1, 20),
                        p_bus_comm_id
                );
                COMMIT;
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK;
                RAISE;
        END;        
       
END pck_bus_comm_read_log;
/
