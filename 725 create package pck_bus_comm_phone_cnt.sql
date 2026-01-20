CREATE OR REPLACE PACKAGE pck_bus_comm_phone_cnt AS

        --
        -- Table: PCK_BUS_COMM_PHONE_CNT
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_phone_cnt table
        --

        PROCEDURE add_cnts(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_bus_comm_tx_json BLOB);

END pck_bus_comm_phone_cnt;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_phone_cnt AS

        PROCEDURE add_cnts(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_bus_comm_tx_json BLOB) IS
        BEGIN
                INSERT INTO bus_comm_phone_cnt (
                        creation_dt,
                        tx_id,
                        tx_type,
                        tx_dt,
                        tx_app_id,
                        bus_comm_id,
                        start_dt,
                        subm_app_id,
                        ch_class_cd,
                        role_row,
                        role_type,
                        ctry_pfx,
                        natl_num               
                ) SELECT  
                        p_bus_comm_hist.creation_dt AS creation_dt,
                        p_bus_comm_hist.tx_id,
                        p_bus_comm_hist.tx_type,
                        p_bus_comm_hist.tx_dt,
                        p_bus_comm_hist.tx_app_id,
                        p_bus_comm_hist.bus_comm_id,
                        p_bus_comm_hist.start_dt,
                        p_bus_comm_hist.subm_app_id,
                        p_bus_comm_hist.ch_class_cd,
                        role_row,
                        role_type,
                        ctry_pfx,
                        natl_num
                FROM JSON_TABLE(p_bus_comm_tx_json, '$.bus_comm.phone_cnt[*]' ERROR ON ERROR NULL ON EMPTY COLUMNS (
                        role_row        FOR ORDINALITY,
                        role_type       PATH '$.role_type',
                        ctry_pfx        PATH '$.ctry_pfx',
                        natl_num        PATH '$.natl_num'
                        )
                );
        END;

END pck_bus_comm_phone_cnt;
/
