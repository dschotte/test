CREATE OR REPLACE PACKAGE pck_utl_bus_comm_hist AS

        --
        -- Table: PCK_UTL_BUS_COMM_HIST
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. utility methods
        --

        PROCEDURE set_cust(p_bus_comm_hist IN OUT BUS_COMM_HIST_OBJ, p_cust ID_OBJ);

END pck_utl_bus_comm_hist;
/

CREATE OR REPLACE PACKAGE BODY pck_utl_bus_comm_hist AS

        PROCEDURE set_cust(p_bus_comm_hist IN OUT BUS_COMM_HIST_OBJ, p_cust ID_OBJ) IS
                TX_CREATE CONSTANT CHAR(1) := 'C';
                LOOKUP_DONE CONSTANT CHAR(1) := 'L';
        BEGIN
                IF p_bus_comm_hist.tx_type = TX_CREATE AND p_bus_comm_hist.cust_id IS NULL THEN
                        p_bus_comm_hist.cust_id := p_cust.id;
                        p_bus_comm_hist.cust_id_scope := p_cust.id_scope;
                        p_bus_comm_hist.cust_id_ctx := p_cust.id_ctx;
                        p_bus_comm_hist.cust_lookup_ind := LOOKUP_DONE;
                END IF;
        END;

END pck_utl_bus_comm_hist;
/
