CREATE OR REPLACE PACKAGE pck_bus_comm AS

        --
        -- Table: PCK_BUS_COMM
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          05/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm table
        --

        PROCEDURE add_bus_comm(p_bus_comm_hist BUS_COMM_HIST_OBJ);

        PROCEDURE set_bus_comm(p_bus_comm_hist BUS_COMM_HIST_OBJ);

        PROCEDURE set_cust(p_bus_comm_hist BUS_COMM_HIST_OBJ);

        PROCEDURE set_cust_mood(p_bus_comm_hist BUS_COMM_HIST_OBJ);

        PROCEDURE set_cust_order(p_bus_comm_hist BUS_COMM_HIST_OBJ);
        
        PROCEDURE set_stat(p_bus_comm_hist BUS_COMM_HIST_OBJ);

END pck_bus_comm;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm AS

        PROCEDURE add_bus_comm(p_bus_comm_hist BUS_COMM_HIST_OBJ) IS
                TX_CREATE CONSTANT CHAR(1) := 'C';
                v_ret_cd VARCHAR2(4000) := pck_utl_bus_comm_ret_cd.get_ret_cd(p_bus_comm_hist);
                BUS_COMM EXCEPTION;
                PRAGMA EXCEPTION_INIT(BUS_COMM, -1);
        BEGIN
                IF p_bus_comm_hist.tx_type = TX_CREATE THEN
                        INSERT INTO bus_comm (
                                creation_dt,
                                mod_dt,
                                ret_cd,
                                bus_comm_id,
                                start_dt )
                        VALUES (p_bus_comm_hist.creation_dt,
                                p_bus_comm_hist.creation_dt,
                                v_ret_cd,
                                p_bus_comm_hist.bus_comm_id,
                                p_bus_comm_hist.start_dt);
                ELSE
                        INSERT INTO bus_comm (
                                creation_dt,
                                mod_dt,
                                ret_cd,
                                bus_comm_id )
                        VALUES (p_bus_comm_hist.creation_dt,
                                p_bus_comm_hist.creation_dt,
                                v_ret_cd,
                                p_bus_comm_hist.bus_comm_id);
                END IF;
        EXCEPTION WHEN BUS_COMM THEN
                set_bus_comm(p_bus_comm_hist);
        END;

        PROCEDURE set_bus_comm(p_bus_comm_hist BUS_COMM_HIST_OBJ) IS
                TX_CREATE CONSTANT CHAR(1) := 'C';
                v_ret_cd VARCHAR2(4000) := pck_utl_bus_comm_ret_cd.get_ret_cd(p_bus_comm_hist);
        BEGIN
                IF p_bus_comm_hist.tx_type = TX_CREATE THEN
                        UPDATE bus_comm SET
                                mod_dt = p_bus_comm_hist.creation_dt,
                                ret_cd = v_ret_cd,
                                start_dt = p_bus_comm_hist.start_dt
                        WHERE bus_comm_id = p_bus_comm_hist.bus_comm_id;
                ELSE
                        UPDATE bus_comm SET
                                mod_dt = p_bus_comm_hist.creation_dt
                        WHERE bus_comm_id = p_bus_comm_hist.bus_comm_id;
                END IF;
        END;
        
        PROCEDURE set_cust(p_bus_comm_hist BUS_COMM_HIST_OBJ) IS
                v_cust ID_OBJ;
        BEGIN
                IF p_bus_comm_hist.cust_id IS NOT NULL THEN
                        v_cust := pck_bus_comm_hist.get_cust(p_bus_comm_hist);
                        UPDATE bus_comm SET
                                cust_id = v_cust.id,
                                cust_id_scope = v_cust.id_scope,
                                cust_id_ctx = v_cust.id_ctx
                        WHERE bus_comm_id = p_bus_comm_hist.bus_comm_id;
                END IF;
        END;

        PROCEDURE set_cust_mood(p_bus_comm_hist BUS_COMM_HIST_OBJ) IS
                v_cust_mood CD_OBJ;
        BEGIN
                IF p_bus_comm_hist.cust_mood_cd IS NOT NULL THEN
                        v_cust_mood := pck_bus_comm_hist.get_cust_mood(p_bus_comm_hist);
                        UPDATE bus_comm SET
                                cust_mood_cd = v_cust_mood.cd
                        WHERE bus_comm_id = p_bus_comm_hist.bus_comm_id;
                END IF;
        END;

        PROCEDURE set_cust_order(p_bus_comm_hist BUS_COMM_HIST_OBJ) IS
                v_cust_order ID_OBJ;
        BEGIN
                IF p_bus_comm_hist.cust_order_id IS NOT NULL THEN
                        v_cust_order := pck_bus_comm_hist.get_cust_order(p_bus_comm_hist);
                        UPDATE bus_comm SET
                                cust_order_id = v_cust_order.id,
                                cust_order_id_scope = v_cust_order.id_scope,
                                cust_order_id_ctx = v_cust_order.id_ctx
                        WHERE bus_comm_id = p_bus_comm_hist.bus_comm_id;
                END IF;
        END;
        
        PROCEDURE set_stat(p_bus_comm_hist BUS_COMM_HIST_OBJ) IS
                v_stat STAT_OBJ;
        BEGIN
                IF p_bus_comm_hist.stat_cd IS NOT NULL THEN
                        v_stat := pck_bus_comm_hist.get_stat(p_bus_comm_hist);
                        UPDATE bus_comm SET
                                stat_cd = v_stat.stat_cd,
                                stat_start_dt = v_stat.stat_start_dt
                        WHERE bus_comm_id = p_bus_comm_hist.bus_comm_id;
                END IF;
        END;

END pck_bus_comm;
/
