CREATE OR REPLACE PACKAGE pck_api_bus_comm_read IS

        --
        -- Package: PCK_API_BUS_COMM_READ
        --
        -- Version      Date            Comments
        -- -------      ----------      ------------------------------------------------------------------------------------------------------------------------
        -- 1.0          23/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for business communication read api
        --

        FUNCTION find(p_reader_app_id VARCHAR2, p_req_id VARCHAR2, p_req_id_ctx VARCHAR2, p_cust_order_id VARCHAR2, p_cust_order_id_ctx VARCHAR2, p_cust_id VARCHAR2, p_cust_id_ctx VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_jo_only VARCHAR2, p_trade_in_only VARCHAR2) RETURN SYS_REFCURSOR;

        FUNCTION get(p_reader_app_id VARCHAR2, p_bus_comm_id RAW) RETURN BLOB;

END pck_api_bus_comm_read;
/

BEGIN syn_mgr.create_synonym('pck_api_bus_comm_read'); END;
/
GRANT EXECUTE ON pck_api_bus_comm_read TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_bus_comm_read IS

        FUNCTION find(p_req_id VARCHAR2, p_req_id_ctx VARCHAR2, p_cust_order_id VARCHAR2, p_cust_order_id_ctx VARCHAR2, p_cust_id VARCHAR2, p_cust_id_ctx VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_jo_only VARCHAR2, p_trade_in_only VARCHAR2) RETURN SYS_REFCURSOR IS
                C_YES CONSTANT CHAR(1) := 'Y';
                v_sql VARCHAR2(4000) := CHR(32);
                c_cursor SYS_REFCURSOR;
        BEGIN
                v_sql := v_sql || ' WITH bus_comm_id_table AS ( SELECT c.bus_comm_id FROM bus_comm c WHERE 1 = 1 ';

                IF p_req_id IS NOT NULL THEN
                        IF p_req_id_ctx IS NOT NULL THEN
                                v_sql := v_sql || ' AND EXISTS (SELECT 1 FROM bus_comm_item WHERE bus_comm_id = c.bus_comm_id AND req_id = :p_req_id AND req_id_ctx = :p_req_id_ctx) ';
                        ELSE
                                v_sql := v_sql || ' AND EXISTS (SELECT 1 FROM bus_comm_item WHERE bus_comm_id = c.bus_comm_id AND req_id = :p_req_id AND (1=1 OR :p_req_id_ctx IS NULL)) ';
                        END IF;
                ELSE
                        v_sql := v_sql || ' AND (1=1 OR :p_req_id IS NULL) AND (1=1 OR :p_req_id_ctx IS NULL) ';
                END IF;

                IF p_cust_order_id IS NOT NULL THEN
                        IF p_cust_order_id_ctx IS NOT NULL THEN
                                v_sql := v_sql || ' AND c.cust_order_id = :p_cust_order_id AND c.cust_order_id_ctx = :p_cust_order_id_ctx ';
                        ELSE
                                v_sql := v_sql || ' AND c.cust_order_id = :p_cust_order_id AND (1=1 OR :p_cust_order_id_ctx IS NULL) ';
                        END IF;
                ELSE
                        v_sql := v_sql || ' AND (1=1 OR :p_cust_order_id IS NULL) AND (1=1 OR :p_cust_order_id_ctx IS NULL) ';
                END IF;

                IF p_cust_id IS NOT NULL THEN
                        IF p_cust_id_ctx IS NOT NULL THEN
                                v_sql := v_sql || ' AND c.cust_id = :p_cust_id AND c.cust_id_ctx = :p_cust_id_ctx ';
                        ELSE
                                v_sql := v_sql || ' AND c.cust_id = :p_cust_id  AND (1=1 OR :p_cust_id_ctx IS NULL) ';
                        END IF;
                ELSE
                        v_sql := v_sql || ' AND (1=1 OR :p_cust_id IS NULL) AND (1=1 OR :p_cust_id_ctx IS NULL) ';
                END IF;

                v_sql := v_sql || ' AND c.start_dt >= :p_since_start_dt AND c.start_dt < :p_before_start_dt ';

                IF p_jo_only = C_YES THEN
                        v_sql := v_sql || ' AND c.ret_cd = ''JO'' ';
                END IF;

                IF p_trade_in_only = C_YES THEN
                        v_sql := v_sql || ' AND EXISTS (SELECT 1 FROM bus_comm_item WHERE bus_comm_id = c.bus_comm_id AND ext_ticket_id IS NOT NULL) ';
                END IF;

                v_sql := v_sql || ' ORDER BY c.start_dt DESC FETCH FIRST 150 ROWS ONLY ) ';
                v_sql := v_sql || ' SELECT j.bus_comm_id, j.start_dt, j.bus_comm_json AS root_obj FROM bus_comm_json j JOIN bus_comm_id_table t ON j.bus_comm_id = t.bus_comm_id ';
                v_sql := v_sql || ' ORDER BY j.start_dt DESC ';

                OPEN c_cursor FOR v_sql USING p_req_id, p_req_id_ctx, p_cust_order_id, p_cust_order_id_ctx, p_cust_id, p_cust_id_ctx, p_since_start_dt, p_before_start_dt;
                
                RETURN c_cursor;
        END;

        ---

        FUNCTION find(p_reader_app_id VARCHAR2, p_req_id VARCHAR2, p_req_id_ctx VARCHAR2, p_cust_order_id VARCHAR2, p_cust_order_id_ctx VARCHAR2, p_cust_id VARCHAR2, p_cust_id_ctx VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_jo_only VARCHAR2, p_trade_in_only VARCHAR2) RETURN SYS_REFCURSOR IS
                c_cursor SYS_REFCURSOR;
        BEGIN
                pck_bus_comm_read_log.log_find(p_reader_app_id, p_req_id, p_req_id_ctx, p_cust_order_id, p_cust_order_id_ctx, p_cust_id, p_cust_id_ctx, p_since_start_dt, p_before_start_dt, p_jo_only, p_trade_in_only);

                IF p_req_id IS NULL AND p_cust_order_id IS NULL AND p_cust_id IS NULL THEN
                        OPEN c_cursor FOR SELECT NULL AS bus_comm_id, NULL AS start_dt, NULL AS root_obj FROM DUAL WHERE 1 = 0;
                ELSE
                        c_cursor := find(p_req_id, p_req_id_ctx, p_cust_order_id, p_cust_order_id_ctx, p_cust_id, p_cust_id_ctx, p_since_start_dt, p_before_start_dt, p_jo_only, p_trade_in_only);                     
                END IF;

                RETURN c_cursor;
        END;

        FUNCTION get(p_reader_app_id VARCHAR2, p_bus_comm_id RAW) RETURN BLOB IS
        BEGIN
                pck_bus_comm_read_log.log_get(p_reader_app_id, p_bus_comm_id);

                RETURN pck_bus_comm_json.get_json(p_bus_comm_id);
        END;

END pck_api_bus_comm_read;
/
