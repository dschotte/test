CREATE OR REPLACE PACKAGE pck_bus_comm_json AS

        --
        -- Table: PCK_BUS_COMM_JSON
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          12/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_json view
        --

        FUNCTION get_json(p_bus_comm_id RAW) RETURN BLOB;

END pck_bus_comm_json;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_json AS

        FUNCTION get_json(p_bus_comm_id RAW) RETURN BLOB IS
                v_json BLOB;
        BEGIN
                SELECT bus_comm_json INTO v_json
                        FROM bus_comm_json
                        WHERE bus_comm_id = p_bus_comm_id;
                RETURN v_json;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

END pck_bus_comm_json;
/
