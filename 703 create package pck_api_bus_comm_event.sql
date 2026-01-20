CREATE OR REPLACE PACKAGE pck_api_bus_comm_event IS

        --
        -- Package: PCK_API_BUS_COMM_EVENT
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          13/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods bus_comm_event table
        --

        PROCEDURE ack_events(p_bus_comm_events_json BLOB);

        FUNCTION pull_events RETURN SYS_REFCURSOR;

END pck_api_bus_comm_event;
/

BEGIN syn_mgr.create_synonym('pck_api_bus_comm_event'); END;
/
GRANT EXECUTE ON pck_api_bus_comm_event TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_bus_comm_event IS

        FUNCTION get_tx_id_table RETURN UUID_TABLE_OBJ IS
                CURSOR c_tx_id IS
                        SELECT /*+ FIRST_ROWS_100 */ tx_id
                        FROM bus_comm_event
                        WHERE DECODE(stat_cd, 'N', 'N') = 'N' -- use functional index
                        FOR UPDATE SKIP LOCKED; 
                v_tx_id_table UUID_TABLE_OBJ;  
        BEGIN
                v_tx_id_table := UUID_TABLE_OBJ();
                
                OPEN c_tx_id;
                        FETCH c_tx_id BULK COLLECT INTO v_tx_id_table LIMIT 100; -- tx id in any new event record that is not locked by a concurrent session
                CLOSE c_tx_id;
                
                RETURN v_tx_id_table;
        END;

        --

        PROCEDURE ack_events(p_bus_comm_events_json BLOB) IS
                STAT_PUBLISHED CONSTANT CHAR(1) := 'P';
                STAT_SKIPPED CONSTANT CHAR(1) := 'S';
        BEGIN
                MERGE INTO bus_comm_event t USING ( SELECT
                                HEXTORAW(tx_id) AS tx_id,
                                published,
                                bus_comm_event_req_json
                        FROM JSON_TABLE ( p_bus_comm_events_json, '$[*]' COLUMNS (
                                tx_id                   VARCHAR2(32)    PATH '$.tx_id',
                                published               VARCHAR2(1)     PATH '$.published',
                                bus_comm_event_req_json CLOB            PATH '$.bus_comm_event_req_json')
                        )
                        FETCH FIRST 100 ROWS ONLY
                ) s
                ON (t.tx_id = s.tx_id) WHEN MATCHED THEN UPDATE SET 
                        t.stat_cd = DECODE(s.published, 'Y', STAT_PUBLISHED, STAT_SKIPPED),
                        t.stat_mod_dt = SYSTIMESTAMP,
                        t.bus_comm_event_req_json = DECODE(s.published, 'Y', s.bus_comm_event_req_json)
                ;
        END;

        FUNCTION pull_events RETURN SYS_REFCURSOR IS
                c_events SYS_REFCURSOR;
                v_tx_id_table UUID_TABLE_OBJ; 
        BEGIN
                v_tx_id_table := get_tx_id_table;
                
                OPEN c_events FOR SELECT /*+ CARDINALITY (t, 100) */ JSON_OBJECT('creation_dt' VALUE e.creation_dt,
                        'tx_id' VALUE RAWTOHEX(e.tx_id),
                        'event_type' VALUE e.event_type,
                        'bus_comm_json' VALUE e.bus_comm_json,
                        'published' VALUE 'N' RETURNING BLOB) AS root_obj
                FROM bus_comm_event e INNER JOIN TABLE(v_tx_id_table) t ON e.tx_id = t.COLUMN_VALUE;
                
                RETURN c_events;
        END;

END pck_api_bus_comm_event;
/
