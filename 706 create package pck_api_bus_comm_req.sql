CREATE OR REPLACE PACKAGE pck_api_bus_comm_req AS

        --
        -- Table: PCK_API_BUS_COMM_REQ
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. api methods for business communication requests
        --

        PROCEDURE process_req(p_req_xml XMLTYPE, p_req_xml_ver VARCHAR2, p_req_from_api VARCHAR2, p_pub_dt TIMESTAMP, p_bus_comm_tx_json BLOB);

END pck_api_bus_comm_req;
/

BEGIN syn_mgr.create_synonym('pck_api_bus_comm_req'); END;
/
GRANT EXECUTE ON pck_api_bus_comm_req TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_bus_comm_req AS
      
        PROCEDURE process_req(p_req_xml XMLTYPE, p_req_xml_ver VARCHAR2, p_req_from_api VARCHAR2, p_pub_dt TIMESTAMP, p_bus_comm_tx_json BLOB) IS
                v_bus_comm_hist BUS_COMM_HIST_OBJ;
                v_cust ID_OBJ;
                v_event_type VARCHAR2(1);
                v_req_log_id NUMBER;
                NO_BUS_COMM EXCEPTION;
                PRAGMA EXCEPTION_INIT(NO_BUS_COMM, -2291);
                TX_CREATE CONSTANT CHAR(1) := 'C';
                TX_UPDATE CONSTANT CHAR(1) := 'U';
        BEGIN
                SAVEPOINT BEFORE_PROCESSING;

                v_bus_comm_hist := pck_utl_bus_comm_tx.get_bus_comm_hist(p_bus_comm_tx_json);
                pck_bus_comm_feed_log.log_feed(v_bus_comm_hist);

                IF v_bus_comm_hist.tx_type = TX_CREATE AND v_bus_comm_hist.cust_id IS NULL THEN
                        v_cust := pck_cust_lookup.get_cust(pck_utl_bus_comm_tx.get_cust_phone(p_bus_comm_tx_json), v_bus_comm_hist.acct_id);
                        pck_utl_bus_comm_hist.set_cust(v_bus_comm_hist, v_cust);
                END IF;

                BEGIN
                        pck_bus_comm_hist.add_bus_comm_hist(v_bus_comm_hist);
                        v_event_type := TX_UPDATE;
                        pck_bus_comm.set_bus_comm(v_bus_comm_hist);
                EXCEPTION WHEN NO_BUS_COMM THEN
                        pck_bus_comm.add_bus_comm(v_bus_comm_hist);
                        v_event_type := TX_CREATE;
                        pck_bus_comm_hist.add_bus_comm_hist(v_bus_comm_hist);
                END;

                IF v_bus_comm_hist.tx_type = TX_CREATE THEN
                        pck_bus_comm_email_cnt.add_cnts(v_bus_comm_hist, p_bus_comm_tx_json);
                        pck_bus_comm_post_cnt.add_cnts(v_bus_comm_hist, p_bus_comm_tx_json);
                        pck_bus_comm_phone_cnt.add_cnts(v_bus_comm_hist, p_bus_comm_tx_json);
                END IF;

                pck_bus_comm_item.add_items(v_bus_comm_hist, p_bus_comm_tx_json);
                pck_bus_comm.set_cust(v_bus_comm_hist);
                pck_bus_comm.set_cust_mood(v_bus_comm_hist);
                pck_bus_comm.set_cust_order(v_bus_comm_hist);
                pck_bus_comm.set_stat(v_bus_comm_hist);

                pck_bus_comm_event.add_event(v_bus_comm_hist, v_event_type, pck_bus_comm_json.get_json(v_bus_comm_hist.bus_comm_id));
                pck_bus_comm_req.add_req(v_bus_comm_hist, p_req_xml, p_req_xml_ver, p_req_from_api, p_pub_dt, p_bus_comm_tx_json);
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK TO BEFORE_PROCESSING;

                IF NOT pck_utl_err.is_app_err(SQLCODE) THEN
                        RAISE;
                END IF;

                v_req_log_id := pck_bus_comm_req_err.add_err(p_req_xml.GETCLOBVAL, p_req_xml_ver, p_req_from_api, p_pub_dt, p_bus_comm_tx_json, SQLCODE, SQLERRM);
        END;

END pck_api_bus_comm_req;
/
