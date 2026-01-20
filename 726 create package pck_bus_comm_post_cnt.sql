CREATE OR REPLACE PACKAGE pck_bus_comm_post_cnt AS

        --
        -- Table: PCK_BUS_COMM_POST_CNT
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_post_cnt table
        --

        PROCEDURE add_cnts(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_bus_comm_tx_json BLOB);

END pck_bus_comm_post_cnt;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_post_cnt AS

        PROCEDURE add_cnts(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_bus_comm_tx_json BLOB) IS
        BEGIN
                INSERT INTO bus_comm_post_cnt (
                        creation_dt,
                        tx_id,
                        tx_type,
                        tx_dt,
                        tx_app_id,
                        bus_comm_id,
                        start_dt,
                        role_row,
                        role_type,
                        first_nm,
                        last_nm,
                        geo_id,
                        geo_id_scope,
                        geo_id_ctx,
                        road_nm,
                        house_num,
                        house_num_sfx,
                        box_num,
                        apt_num,
                        block_num,
                        floor_num,
                        zip_cd,
                        geo_area_nm,
                        ctry_cd,
                        ctry_nm            
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
                        first_nm,
                        last_nm,
                        geo_id,
                        geo_id_scope,
                        geo_id_ctx,
                        road_nm,
                        house_num,
                        house_num_sfx,
                        box_num,
                        apt_num,
                        block_num,
                        floor_num,
                        zip_cd,
                        geo_area_nm,
                        ctry_cd,
                        ctry_nm 
                FROM JSON_TABLE(p_bus_comm_tx_json, '$.bus_comm.post_cnt[*]' ERROR ON ERROR NULL ON EMPTY COLUMNS (
                        role_row        FOR ORDINALITY,
                        role_type       PATH '$.role_type',
                        first_nm        PATH '$.first_nm',
                        last_nm         PATH '$.last_nm',
                        geo_id          PATH '$.geo_id.id',
                        geo_id_scope    PATH '$.geo_id.id_scope',
                        geo_id_ctx      PATH '$.geo_id.id_ctx',
                        road_nm         PATH '$.geo_addr.road_nm',
                        house_num       PATH '$.geo_addr.house_num',
                        house_num_sfx   PATH '$.geo_addr.house_num_sfx',
                        box_num         PATH '$.geo_addr.box_num',
                        apt_num         PATH '$.geo_addr.apt_num',
                        block_num       PATH '$.geo_addr.block_num',
                        floor_num       PATH '$.geo_addr.floor_num',
                        zip_cd          PATH '$.geo_addr.zip_cd',
                        geo_area_nm     PATH '$.geo_addr.geo_area_nm',
                        ctry_cd         PATH '$.geo_addr.ctry_cd',
                        ctry_nm         PATH '$.geo_addr.ctry_nm'
                        )
                );
        END;

END pck_bus_comm_post_cnt;
/
