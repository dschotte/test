CREATE OR REPLACE PACKAGE pck_api_tx_export AS

        --
        -- Package: PCK_API_TX_EXPORT
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          29/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for transaction export api
        --

        FUNCTION get_dummy_tx(p_dt IN TIMESTAMP, p_tx_type IN VARCHAR2) RETURN BLOB;

        FUNCTION find_tx(p_date IN DATE) RETURN SYS_REFCURSOR;

END pck_api_tx_export;
/

BEGIN syn_mgr.create_synonym('pck_api_tx_export'); END;
/
GRANT EXECUTE ON pck_api_tx_export TO cds_batch
/

CREATE OR REPLACE PACKAGE BODY pck_api_tx_export AS

        FUNCTION req_xml(p_since_dt IN DATE, p_before_dt IN DATE) RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT ('creDt' VALUE h.creation_dt
                        ,'reqXml' VALUE REPLACE(REPLACE(REPLACE(REPLACE(XMLSERIALIZE(CONTENT r.req_xml AS CLOB NO INDENT), '>undefined<', '><'), '>null<', '><'), '|', ':'), '¡', NULL)
                        ,'txTp' VALUE h.tx_type RETURNING BLOB
                        ) AS root_obj
                FROM bus_comm_hist h
                INNER JOIN bus_comm_req r ON h.tx_id = r.tx_id
                WHERE h.creation_dt >= p_since_dt AND h.creation_dt < p_before_dt
                AND REGEXP_LIKE(NVL(h.cust_orig_id, '0'), '^[0-9]+$')
                AND (h.tx_app_id IN ('ARC', 'CVM', 'DOF') OR EXISTS (SELECT 1 FROM bus_comm_item i WHERE i.bus_comm_id = h.bus_comm_id AND i.tx_id = h.tx_id AND i.item_type = 'Request'))
                ORDER BY h.creation_dt;
                --
                RETURN c_list;
        END;
       
        --
        
        FUNCTION get_dummy_tx(p_dt IN TIMESTAMP, p_tx_type IN VARCHAR2) RETURN BLOB IS
                v_root_obj BLOB;
                TX_CREATE CONSTANT VARCHAR2(1) := 'C';
                TX_UPDATE CONSTANT VARCHAR2(1) := 'U';
        BEGIN
                IF p_tx_type = TX_CREATE THEN
                        SELECT JSON_OBJECT ('creDt' VALUE p_dt
                                ,'reqXml' VALUE '<RequestDataCreateBusinessCommunication xmlns="http://api.web.bc/capability/business/b170/cbu/services/businesscommunication/v2" xmlns:ns2="http://api.web.bc/capability/business/b170/cbu/objects/requestcreatebusinesscommunication/v2"><serviceContext/><serviceData/></RequestDataCreateBusinessCommunication>'
                                ,'txTp' VALUE p_tx_type RETURNING BLOB
                                ) INTO v_root_obj
                        FROM DUAL;
                ELSIF p_tx_type = TX_UPDATE THEN
                        SELECT JSON_OBJECT ('creDt' VALUE p_dt
                                ,'reqXml' VALUE '<RequestDataUpdateBusinessCommunication xmlns="http://api.web.bc/capability/business/b170/cbu/services/businesscommunication/v2" xmlns:ns2="http://api.web.bc/capability/business/b170/cbu/objects/requestupdatebusinesscommunication/v2"><serviceContext/><serviceData/></RequestDataUpdateBusinessCommunication>'
                                ,'txTp' VALUE p_tx_type RETURNING BLOB
                                ) INTO v_root_obj
                        FROM DUAL;
                ELSE
                        RAISE_APPLICATION_ERROR(-20000, 'Invalid transaction type');
                END IF;
                --
                RETURN v_root_obj;
        END;

        FUNCTION find_tx(p_date IN DATE) RETURN SYS_REFCURSOR IS
        BEGIN
                RETURN req_xml(TRUNC(p_date), TRUNC(p_date + 1));
        END;

END pck_api_tx_export;
/
