CREATE OR REPLACE PACKAGE pck_api_bus_comm_stat IS

        --
        -- Package: PCK_API_BUS_COMM_STAT
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------
        -- 1.0          24/01/2025      Initial version
        --
        -- Remarks:
        -- 1.methods for business communication status api
        --
        
        FUNCTION find_code RETURN SYS_REFCURSOR;
        
END pck_api_bus_comm_stat;
/

BEGIN syn_mgr.create_synonym('pck_api_bus_comm_stat'); END;
/
GRANT EXECUTE ON pck_api_bus_comm_stat TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_bus_comm_stat IS

        FUNCTION find_code RETURN SYS_REFCURSOR IS
                c_cursor SYS_REFCURSOR;
        BEGIN
                OPEN c_cursor FOR
                        SELECT stat_cd                                                 
                        FROM bus_comm_stat_def
                        ORDER BY stat_cd;
                RETURN c_cursor;
        END;

END pck_api_bus_comm_stat;
/
