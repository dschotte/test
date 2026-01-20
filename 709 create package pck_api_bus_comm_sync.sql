CREATE OR REPLACE PACKAGE pck_api_bus_comm_sync IS

        --
        -- Package: PCK_API_BUS_COMM_SYNC
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          17/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for business communication synchronization api
        --
        
        FUNCTION list(p_reader_app_id VARCHAR2, p_bus_comm_ids_json BLOB) RETURN SYS_REFCURSOR;
        
        FUNCTION list_mod(p_reader_app_id VARCHAR2, p_since_mod_dt TIMESTAMP, p_before_mod_dt TIMESTAMP) RETURN SYS_REFCURSOR;

END pck_api_bus_comm_sync;
/

BEGIN syn_mgr.create_synonym('pck_api_bus_comm_sync'); END;
/
GRANT EXECUTE ON pck_api_bus_comm_sync TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_bus_comm_sync IS

        FUNCTION list(p_reader_app_id VARCHAR2, p_bus_comm_ids_json BLOB) RETURN SYS_REFCURSOR IS
                c_cursor SYS_REFCURSOR;
        BEGIN
                pck_bus_comm_sync_log.log_list(p_reader_app_id, p_bus_comm_ids_json);

                OPEN c_cursor FOR WITH bus_comm_id_table AS (
                        SELECT DISTINCT HEXTORAW(bus_comm_id) AS bus_comm_id
                        FROM JSON_TABLE(p_bus_comm_ids_json, '$[*]' COLUMNS (bus_comm_id VARCHAR2(32) PATH '$'))
                )
                SELECT j.bus_comm_id, j.start_dt, j.bus_comm_json AS root_obj
                FROM bus_comm_json j JOIN bus_comm_id_table t ON j.bus_comm_id = t.bus_comm_id 
                ORDER BY j.bus_comm_id; 

                RETURN c_cursor;
        END;

        FUNCTION list_mod(p_reader_app_id VARCHAR2, p_since_mod_dt TIMESTAMP, p_before_mod_dt TIMESTAMP) RETURN SYS_REFCURSOR IS
                c_cursor SYS_REFCURSOR;
        BEGIN
                pck_bus_comm_sync_log.log_list_mod(p_reader_app_id, p_since_mod_dt, p_before_mod_dt);

                OPEN c_cursor FOR SELECT mod_dt,
                        bus_comm_id,
                        JSON_OBJECT('mod_dt' VALUE mod_dt, 'bus_comm_id' VALUE bus_comm_id RETURNING BLOB) AS root_obj
                FROM (
                        SELECT /*+ FIRST_ROWS(10000) */ mod_dt, bus_comm_id
                        FROM bus_comm
                        WHERE mod_dt >= p_since_mod_dt AND mod_dt < p_before_mod_dt
                        ORDER BY mod_dt
                )
                WHERE ROWNUM <= 10000;

                RETURN c_cursor;
        END;

END pck_api_bus_comm_sync;
/
