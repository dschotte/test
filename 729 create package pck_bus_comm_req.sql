CREATE OR REPLACE PACKAGE pck_bus_comm_req AS

        --
        -- Package: PCK_BUS_COMM_REQ
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_req table
        --

        PROCEDURE add_req(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_req_xml XMLTYPE, p_req_xml_ver VARCHAR2, p_req_from_api VARCHAR2, p_pub_dt TIMESTAMP, p_bus_comm_tx_json BLOB);

END pck_bus_comm_req;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_req AS

        PROCEDURE add_req(p_bus_comm_hist BUS_COMM_HIST_OBJ, p_req_xml XMLTYPE, p_req_xml_ver VARCHAR2, p_req_from_api VARCHAR2, p_pub_dt TIMESTAMP, p_bus_comm_tx_json BLOB) IS
        BEGIN
                INSERT INTO bus_comm_req (creation_dt,
                        tx_id,
                        tx_type,
                        tx_dt,
                        tx_app_id,
                        bus_comm_id,
                        req_xml,
                        req_xml_ver,
                        req_from_api,
                        pub_dt,
                        bus_comm_tx_json)
                VALUES (p_bus_comm_hist.creation_dt,
                        p_bus_comm_hist.tx_id,
                        p_bus_comm_hist.tx_type,
                        p_bus_comm_hist.tx_dt,
                        p_bus_comm_hist.tx_app_id,
                        p_bus_comm_hist.bus_comm_id,
                        p_req_xml,
                        p_req_xml_ver,
                        p_req_from_api,
                        p_pub_dt,
                        p_bus_comm_tx_json);
        END;

END pck_bus_comm_req;
/
