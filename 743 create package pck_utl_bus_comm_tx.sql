CREATE OR REPLACE PACKAGE pck_utl_bus_comm_tx AS

        --
        -- Table: PCK_UTL_BUS_COMM_TX
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. utility methods
        --

        FUNCTION get_bus_comm_hist(p_bus_comm_tx_json BLOB) RETURN BUS_COMM_HIST_OBJ;
        
        FUNCTION get_cust_phone(p_bus_comm_tx_json BLOB) RETURN PHONE_OBJ;

END pck_utl_bus_comm_tx;
/

CREATE OR REPLACE PACKAGE BODY pck_utl_bus_comm_tx AS

        FUNCTION get_bus_comm_hist(p_bus_comm_tx_json BLOB) RETURN BUS_COMM_HIST_OBJ IS
                v_bus_comm_hist BUS_COMM_HIST_OBJ := BUS_COMM_HIST_OBJ();
        BEGIN
                SELECT
                        SYSTIMESTAMP AS creation_dt,
                        HEXTORAW(tx_id) AS tx_id,
                        tx_type,
                        tx_dt,
                        tx_app_id,
                        HEXTORAW(bus_comm_id) AS bus_comm_id,
                        start_dt,
                        end_dt,
                        cust_id,
                        cust_id_scope,
                        cust_id_ctx,
                        NULL AS cust_lookup_ind,
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
                INTO
                        v_bus_comm_hist.creation_dt,
                        v_bus_comm_hist.tx_id,
                        v_bus_comm_hist.tx_type,
                        v_bus_comm_hist.tx_dt,
                        v_bus_comm_hist.tx_app_id,
                        v_bus_comm_hist.bus_comm_id,
                        v_bus_comm_hist.start_dt,
                        v_bus_comm_hist.end_dt,
                        v_bus_comm_hist.cust_id,
                        v_bus_comm_hist.cust_id_scope,
                        v_bus_comm_hist.cust_id_ctx,
                        v_bus_comm_hist.cust_lookup_ind,
                        v_bus_comm_hist.cust_orig_id,
                        v_bus_comm_hist.acct_id,
                        v_bus_comm_hist.acct_id_scope,
                        v_bus_comm_hist.acct_id_ctx,
                        v_bus_comm_hist.subm_app_id,
                        v_bus_comm_hist.cust_mood_cd,
                        v_bus_comm_hist.subm_org_id,
                        v_bus_comm_hist.subm_org_id_scope,
                        v_bus_comm_hist.subm_org_id_ctx,
                        v_bus_comm_hist.cust_order_id,
                        v_bus_comm_hist.cust_order_id_scope,
                        v_bus_comm_hist.cust_order_id_ctx,
                        v_bus_comm_hist.lang_cd,
                        v_bus_comm_hist.bus_comm_nm,
                        v_bus_comm_hist.bus_comm_descr,
                        v_bus_comm_hist.stat_cd,
                        v_bus_comm_hist.stat_start_dt,
                        v_bus_comm_hist.dir_cd,
                        v_bus_comm_hist.ch_class_cd,
                        v_bus_comm_hist.bus_comm_branding,
                        v_bus_comm_hist.bus_comm_type,
                        v_bus_comm_hist.campaign_id,
                        v_bus_comm_hist.campaign_nm,
                        v_bus_comm_hist.svc_nm,
                        v_bus_comm_hist.subm_org_nm,
                        v_bus_comm_hist.tpl_id,
                        v_bus_comm_hist.tpl_nm,
                        v_bus_comm_hist.tpl_descr
                FROM JSON_TABLE(p_bus_comm_tx_json, '$' ERROR ON ERROR NULL ON EMPTY COLUMNS (
                        tx_id                                   PATH '$.tx_id',
                        tx_type                                 PATH '$.tx_type',
                        tx_dt                   TIMESTAMP       PATH '$.tx_dt',
                        tx_app_id                               PATH '$.tx_app_id',
                        bus_comm_id                             PATH '$.bus_comm.bus_comm_id',
                        start_dt                TIMESTAMP       PATH '$.bus_comm.dur.start_dt',
                        end_dt                  TIMESTAMP       PATH '$.bus_comm.dur.end_dt',
                        cust_id                                 PATH '$.bus_comm.cust_id.id',
                        cust_id_scope                           PATH '$.bus_comm.cust_id.id_scope',
                        cust_id_ctx                             PATH '$.bus_comm.cust_id.id_ctx',
                        cust_orig_id                            PATH '$.bus_comm.cust_orig_id',
                        acct_id                                 PATH '$.bus_comm.acct_id.id',
                        acct_id_scope                           PATH '$.bus_comm.acct_id.id_scope',
                        acct_id_ctx                             PATH '$.bus_comm.acct_id.id_ctx',
                        subm_app_id                             PATH '$.bus_comm.subm_app_id',
                        cust_mood_cd                            PATH '$.bus_comm.cust_mood_cd',
                        subm_org_id                             PATH '$.bus_comm.subm_org_id.id',
                        subm_org_id_scope                       PATH '$.bus_comm.subm_org_id.id_scope',
                        subm_org_id_ctx                         PATH '$.bus_comm.subm_org_id.id_ctx',
                        cust_order_id                           PATH '$.bus_comm.cust_order_id.id',
                        cust_order_id_scope                     PATH '$.bus_comm.cust_order_id.id_scope',
                        cust_order_id_ctx                       PATH '$.bus_comm.cust_order_id.id_ctx',
                        lang_cd                                 PATH '$.bus_comm.lang_cd',
                        bus_comm_nm                             PATH '$.bus_comm.bus_comm_nm',
                        bus_comm_descr                          PATH '$.bus_comm.bus_comm_descr',
                        stat_cd                                 PATH '$.bus_comm.stat.stat_cd',
                        stat_start_dt           TIMESTAMP       PATH '$.bus_comm.stat.dur.start_dt',
                        dir_cd                                  PATH '$.bus_comm.dir_cd',
                        ch_class_cd                             PATH '$.bus_comm.ch_class_cd',
                        bus_comm_branding                       PATH '$.bus_comm.bus_comm_branding',
                        bus_comm_type                           PATH '$.bus_comm.bus_comm_type',
                        campaign_id                             PATH '$.bus_comm.campaign_id',
                        campaign_nm                             PATH '$.bus_comm.campaign_nm',
                        svc_nm                                  PATH '$.bus_comm.svc_nm',
                        subm_org_nm                             PATH '$.bus_comm.subm_org_nm',
                        tpl_id                                  PATH '$.bus_comm.tpl_id',
                        tpl_nm                                  PATH '$.bus_comm.tpl_nm',
                        tpl_descr                               PATH '$.bus_comm.tpl_descr'
                        )
                );
                RETURN v_bus_comm_hist;
        END;

        FUNCTION get_cust_phone(p_bus_comm_tx_json BLOB) RETURN PHONE_OBJ IS
                v_phone PHONE_OBJ := PHONE_OBJ;
                DIR_OUTBOUND CONSTANT VARCHAR2(8) := 'BCDIR002';
                DIR_INBOUND CONSTANT VARCHAR2(8) := 'BCDIR001';
         BEGIN
                SELECT
                        ctry_pfx,
                        natl_num
                INTO
                        v_phone.ctry_pfx,
                        v_phone.natl_num
                FROM JSON_TABLE(p_bus_comm_tx_json, '$.bus_comm' ERROR ON ERROR NULL ON EMPTY COLUMNS ( dir_cd PATH '$.dir_cd', NESTED PATH '$.phone_cnt[*]' COLUMNS (
                        role_type                               PATH '$.role_type',
                        ctry_pfx                                PATH '$.ctry_pfx',
                        natl_num                                PATH '$.natl_num'
                        ) )
                )
                WHERE role_type = DECODE(dir_cd, DIR_OUTBOUND, 'SENT_TO', DIR_INBOUND, 'SENT_FROM') FETCH FIRST ROW ONLY;
                RETURN v_phone;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

END pck_utl_bus_comm_tx;
/
