CREATE OR REPLACE PACKAGE pck_bus_comm_email_cnt AS

        --
        -- Table: PCK_BUS_COMM_EMAIL_CNT
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_email_cnt table
        --

        PROCEDURE add_cnts(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_bus_comm_tx_json BLOB);

END pck_bus_comm_email_cnt;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_email_cnt AS

        PROCEDURE add_cnts(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_bus_comm_tx_json BLOB) IS
        BEGIN
                INSERT INTO bus_comm_email_cnt (
                        creation_dt,
                        tx_id,
                        tx_type,
                        tx_dt,
                        tx_app_id,
                        bus_comm_id,
                        start_dt,
                        role_row,
                        role_type,
                        email_addr           
                ) SELECT  
                        p_bus_comm_hist.creation_dt,
                        p_bus_comm_hist.tx_id,
                        p_bus_comm_hist.tx_type,
                        p_bus_comm_hist.tx_dt,
                        p_bus_comm_hist.tx_app_id,
                        p_bus_comm_hist.bus_comm_id,
                        p_bus_comm_hist.start_dt,
                        role_row,
                        role_type,
                        email_addr
                FROM JSON_TABLE(p_bus_comm_tx_json, '$.bus_comm.email_cnt[*]' ERROR ON ERROR NULL ON EMPTY COLUMNS (
                        role_row        FOR ORDINALITY,
                        role_type       PATH '$.role_type',
                        email_addr      PATH '$.email_addr'
                        )
                );
        END;

END pck_bus_comm_email_cnt;
/
