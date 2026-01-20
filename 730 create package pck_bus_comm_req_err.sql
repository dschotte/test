CREATE OR REPLACE PACKAGE pck_bus_comm_req_err AS

        --
        -- Package: PCK_BUS_COMM_REQ_ERR
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          11/04/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_req_err table
        --

        FUNCTION add_err(p_req_xml CLOB, p_req_xml_ver VARCHAR2, p_req_from_api VARCHAR2, p_pub_dt IN TIMESTAMP, p_bus_comm_tx_json BLOB, p_err_cd NUMBER, p_err_msg VARCHAR2) RETURN NUMBER;

        FUNCTION alert_needed(p_since_dt TIMESTAMP) RETURN BOOLEAN;

        PROCEDURE clean;

        PROCEDURE retry_msg_pat(p_err_msg_pat VARCHAR2);

        PROCEDURE retry_arc;

END pck_bus_comm_req_err;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_req_err AS

        FUNCTION add_err(p_req_xml CLOB, p_req_xml_ver VARCHAR2, p_req_from_api VARCHAR2, p_pub_dt IN TIMESTAMP, p_bus_comm_tx_json BLOB, p_err_cd NUMBER, p_err_msg VARCHAR2) RETURN NUMBER IS
                v_req_log_id NUMBER;
        BEGIN
                INSERT INTO bus_comm_req_err (creation_dt,
                        req_xml,
                        req_xml_ver,
                        req_from_api,
                        pub_dt,
                        bus_comm_tx_json,
                        req_log_id,
                        err_cd,
                        err_msg)
                VALUES (SYSTIMESTAMP,
                        SUBSTR(p_req_xml, 1, 32767),
                        p_req_xml_ver,
                        p_req_from_api,
                        p_pub_dt,
                        p_bus_comm_tx_json,
                        bus_comm_req_err_seq.NEXTVAL,
                        p_err_cd,
                        SUBSTR(p_err_msg, 1, 2048)) RETURNING req_log_id INTO v_req_log_id;
                RETURN v_req_log_id;
        END;

        FUNCTION alert_needed(p_since_dt TIMESTAMP) RETURN BOOLEAN IS
                v_req_log_id bus_comm_req_err.req_log_id%TYPE;
        BEGIN
                SELECT req_log_id INTO v_req_log_id
                        FROM bus_comm_req_err
                        WHERE err_msg NOT LIKE '%ORA-00001: unique constraint (CDS_SCHEMA.BUS_COMM_HIST_PK) violated%'
                        AND err_msg NOT LIKE '%ORA-00001: unique constraint (CDS_SCHEMA.BUS_COMM_HIST_TX_C) violated%'
                        AND creation_dt >= p_since_dt
                        FETCH FIRST ROW ONLY;
                RETURN TRUE;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN FALSE;
        END;

        --
        -- manual clean
        --

        PROCEDURE clean IS
        BEGIN
                DELETE FROM bus_comm_req_err
                WHERE err_msg LIKE '%ORA-00001: unique constraint (CDS_SCHEMA.BUS_COMM_HIST_PK) violated%'
                OR err_msg LIKE '%ORA-00001: unique constraint (CDS_SCHEMA.BUS_COMM_HIST_TX_C) violated%';
        END;

        --
        -- manual retry
        --

        PROCEDURE retry_msg_pat(p_err_msg_pat VARCHAR2) IS
                CURSOR c_req_log_id IS
                        SELECT JSON_ARRAY(req_log_id) AS json_array
                        FROM bus_comm_req_err
                        WHERE err_msg LIKE p_err_msg_pat
                        ORDER BY req_log_id;
                v_url VARCHAR2(4000);
                v_response VARCHAR2(4000);
        BEGIN
                v_url := pck_param.param_val('CDS_EVENT', 'BUS_COMM_REQ_RETRY_URL');
                FOR r_req_log_id IN c_req_log_id LOOP
                        v_response := pck_ora_http.post_json(v_url, r_req_log_id.json_array);
                END LOOP;
                DBMS_OUTPUT.PUT_LINE(v_response);
        END; 

        PROCEDURE retry_arc IS
                CURSOR c_req_err IS
                        SELECT XMLTYPE(req_xml) AS req_xml, req_xml_ver, req_from_api, pub_dt, bus_comm_tx_json, req_log_id
                        FROM bus_comm_req_err_det
                        WHERE tx_app_id = 'ARC' AND req_xml LIKE '%>Request<%' AND err_msg = 'ITEM_TYPE'
                        ORDER BY req_log_id;
        BEGIN
                FOR r_req_err IN c_req_err LOOP
                        pck_api_bus_comm_req.process_req(r_req_err.req_xml, r_req_err.req_xml_ver, r_req_err.req_from_api, r_req_err.pub_dt, r_req_err.bus_comm_tx_json);
                        DELETE FROM bus_comm_req_err WHERE req_log_id = r_req_err.req_log_id;
                END LOOP;
        END; 

END pck_bus_comm_req_err;
/
