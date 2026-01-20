CREATE OR REPLACE PACKAGE pck_api_bus_comm_req_err AS

        --
        -- Table: PCK_API_BUS_COMM_REQ_ERR
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          13/01/2025      Initial version
        --
        -- Remarks:
        -- 1. api methods for business communication request errors
        --

        FUNCTION add_err(p_req_xml CLOB, p_req_xml_ver VARCHAR2, p_req_from_api VARCHAR2, p_pub_dt TIMESTAMP, p_bus_comm_tx_json BLOB, p_err_cd NUMBER, p_err_msg VARCHAR) RETURN NUMBER;

        FUNCTION get_err_obj(p_req_log_id NUMBER) RETURN BLOB;

        FUNCTION del_err(p_req_log_id NUMBER) RETURN NUMBER;

END pck_api_bus_comm_req_err;
/

BEGIN syn_mgr.create_synonym('pck_api_bus_comm_req_err'); END;
/
GRANT EXECUTE ON pck_api_bus_comm_req_err TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_bus_comm_req_err AS
      
        FUNCTION add_err(p_req_xml CLOB, p_req_xml_ver VARCHAR2, p_req_from_api VARCHAR2, p_pub_dt TIMESTAMP, p_bus_comm_tx_json BLOB, p_err_cd NUMBER, p_err_msg VARCHAR) RETURN NUMBER IS
        BEGIN
                RETURN pck_bus_comm_req_err.add_err(p_req_xml, p_req_xml_ver, p_req_from_api, p_pub_dt, p_bus_comm_tx_json, p_err_cd, p_err_msg);
        END;

        FUNCTION get_err_obj(p_req_log_id NUMBER) RETURN BLOB IS
                v_obj BLOB;
        BEGIN
                SELECT JSON_OBJECT('req_xml' VALUE req_xml, 'req_xml_ver' VALUE req_xml_ver, 'req_from_api' VALUE req_from_api, 'pub_dt' VALUE pub_dt RETURNING BLOB) INTO v_obj
                        FROM bus_comm_req_err
                        WHERE req_log_id = p_req_log_id;
                RETURN v_obj;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

        FUNCTION del_err(p_req_log_id NUMBER) RETURN NUMBER IS
        BEGIN
                DELETE FROM bus_comm_req_err WHERE req_log_id = p_req_log_id;
                RETURN SQL%ROWCOUNT;
        END;

END pck_api_bus_comm_req_err;
/
