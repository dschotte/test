CREATE OR REPLACE PACKAGE pck_bus_comm_hist AS

        --
        -- Table: PCK_BUS_COMM_HIST
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_hist table
        --

        PROCEDURE add_bus_comm_hist(p_bus_comm_hist BUS_COMM_HIST_OBJ);

        FUNCTION  get_cust(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN ID_OBJ;

        FUNCTION  get_cust_mood(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN CD_OBJ;

        FUNCTION  get_cust_order(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN ID_OBJ;

        FUNCTION  get_stat(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN STAT_OBJ;

END pck_bus_comm_hist;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_hist AS

        PROCEDURE add_bus_comm_hist(p_bus_comm_hist BUS_COMM_HIST_OBJ) IS
        BEGIN
                INSERT INTO bus_comm_hist (
                        creation_dt,
                        tx_id,
                        tx_type,
                        tx_dt,
                        tx_app_id,
                        bus_comm_id,
                        start_dt,
                        end_dt,
                        cust_id,
                        cust_id_scope,
                        cust_id_ctx,
                        cust_lookup_ind,
                        cust_orig_id,
                        acct_id,
                        acct_id_scope,
                        acct_id_ctx,
                        subm_app_id,
                        cust_mood_cd,
                        subm_org_id,
                        subm_org_id_scope,
                        subm_org_id_ctx,
                        cust_order_id,
                        cust_order_id_scope,
                        cust_order_id_ctx,
                        lang_cd,
                        bus_comm_nm,
                        bus_comm_descr,
                        stat_cd,
                        stat_start_dt,
                        dir_cd,
                        ch_class_cd,
                        bus_comm_branding,
                        bus_comm_type,
                        campaign_id,
                        campaign_nm,
                        svc_nm,
                        subm_org_nm,
                        tpl_id,
                        tpl_nm,
                        tpl_descr
                ) SELECT
                        p_bus_comm_hist.creation_dt,
                        p_bus_comm_hist.tx_id,
                        p_bus_comm_hist.tx_type,
                        p_bus_comm_hist.tx_dt,
                        p_bus_comm_hist.tx_app_id,
                        p_bus_comm_hist.bus_comm_id,
                        p_bus_comm_hist.start_dt,
                        p_bus_comm_hist.end_dt,
                        p_bus_comm_hist.cust_id,
                        p_bus_comm_hist.cust_id_scope,
                        p_bus_comm_hist.cust_id_ctx,
                        p_bus_comm_hist.cust_lookup_ind,
                        p_bus_comm_hist.cust_orig_id,
                        p_bus_comm_hist.acct_id,
                        p_bus_comm_hist.acct_id_scope,
                        p_bus_comm_hist.acct_id_ctx,
                        p_bus_comm_hist.subm_app_id,
                        p_bus_comm_hist.cust_mood_cd,
                        p_bus_comm_hist.subm_org_id,
                        p_bus_comm_hist.subm_org_id_scope,
                        p_bus_comm_hist.subm_org_id_ctx,
                        p_bus_comm_hist.cust_order_id,
                        p_bus_comm_hist.cust_order_id_scope,
                        p_bus_comm_hist.cust_order_id_ctx,
                        p_bus_comm_hist.lang_cd,
                        p_bus_comm_hist.bus_comm_nm,
                        p_bus_comm_hist.bus_comm_descr,
                        p_bus_comm_hist.stat_cd,
                        p_bus_comm_hist.stat_start_dt,
                        p_bus_comm_hist.dir_cd,
                        p_bus_comm_hist.ch_class_cd,
                        p_bus_comm_hist.bus_comm_branding,
                        p_bus_comm_hist.bus_comm_type,
                        p_bus_comm_hist.campaign_id,
                        p_bus_comm_hist.campaign_nm,
                        p_bus_comm_hist.svc_nm,
                        p_bus_comm_hist.subm_org_nm,
                        p_bus_comm_hist.tpl_id,
                        p_bus_comm_hist.tpl_nm,
                        p_bus_comm_hist.tpl_descr
                FROM DUAL;
         END;

        FUNCTION get_cust(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN ID_OBJ IS
                v_cust ID_OBJ := ID_OBJ;
        BEGIN
                SELECT
                        cust_id,
                        cust_id_scope,
                        cust_id_ctx
                INTO
                        v_cust.id,
                        v_cust.id_scope,
                        v_cust.id_ctx
                FROM bus_comm_hist
                        WHERE bus_comm_id = p_bus_comm_hist.bus_comm_id
                        AND cust_id IS NOT NULL
                        ORDER BY tx_type DESC, tx_dt DESC FETCH FIRST ROW ONLY;
                RETURN v_cust;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

        FUNCTION get_cust_mood(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN CD_OBJ IS
                v_cust_mood CD_OBJ := CD_OBJ;
        BEGIN
                SELECT
                        cust_mood_cd
                INTO
                        v_cust_mood.cd
                FROM bus_comm_hist
                        WHERE bus_comm_id = p_bus_comm_hist.bus_comm_id
                        AND cust_mood_cd IS NOT NULL
                        ORDER BY tx_type DESC, tx_dt DESC FETCH FIRST ROW ONLY;
                RETURN v_cust_mood;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

        FUNCTION get_cust_order(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN ID_OBJ IS
                v_cust_order ID_OBJ := ID_OBJ;
        BEGIN
                SELECT
                        cust_order_id,
                        cust_order_id_scope,
                        cust_order_id_ctx
                INTO
                        v_cust_order.id,
                        v_cust_order.id_scope,
                        v_cust_order.id_ctx
                FROM bus_comm_hist
                        WHERE bus_comm_id = p_bus_comm_hist.bus_comm_id
                        AND cust_order_id IS NOT NULL
                        ORDER BY tx_type DESC, tx_dt DESC FETCH FIRST ROW ONLY;
                RETURN v_cust_order;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

        FUNCTION get_stat(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN STAT_OBJ IS
                v_stat STAT_OBJ := STAT_OBJ;
        BEGIN
                SELECT
                        h.stat_cd,
                        h.stat_start_dt
                INTO
                        v_stat.stat_cd,
                        v_stat.stat_start_dt
                FROM bus_comm_hist h
                        JOIN bus_comm_stat_def s ON h.stat_cd = s.stat_cd
                        WHERE h.bus_comm_id = p_bus_comm_hist.bus_comm_id
                        AND h.stat_cd IS NOT NULL
                        AND s.effective = 'Y'
                        ORDER BY h.tx_type DESC, s.seq DESC, NVL(h.stat_start_dt, h.tx_dt) DESC FETCH FIRST ROW ONLY;
                RETURN v_stat;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

END pck_bus_comm_hist;
/
