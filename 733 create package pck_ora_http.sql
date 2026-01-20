CREATE OR REPLACE PACKAGE pck_ora_http IS

        --
        -- Package: PCK_ORA_HTTP
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          01/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods to use oracle http
        --

        FUNCTION post_json(p_url VARCHAR2, p_json VARCHAR2) RETURN VARCHAR2;

END pck_ora_http;
/

CREATE OR REPLACE PACKAGE BODY pck_ora_http IS

        FUNCTION get_response(v_req IN OUT NOCOPY UTL_HTTP.REQ) RETURN VARCHAR2 IS
                v_resp UTL_HTTP.RESP;
                v_response VARCHAR2(32767);
                v_buffer VARCHAR2(1024);
        BEGIN
                BEGIN
                        v_resp := UTL_HTTP.GET_RESPONSE(v_req);        
                        LOOP
                                UTL_HTTP.READ_TEXT(v_resp, v_buffer, NULL);
                                v_response := v_response || v_buffer;
                        END LOOP;
                EXCEPTION WHEN UTL_HTTP.END_OF_BODY THEN
                        UTL_HTTP.END_RESPONSE(v_resp);
                END;
                
                RETURN v_response;
        END;
        
        --

        FUNCTION post_json(p_url VARCHAR2, p_json VARCHAR2) RETURN VARCHAR2 IS
                v_req UTL_HTTP.REQ;
                v_response VARCHAR2(32767);
        BEGIN
                v_req := UTL_HTTP.BEGIN_REQUEST(p_url, 'POST');
                UTL_HTTP.SET_HEADER(v_req, 'Content-Type', 'application/json');
                UTL_HTTP.SET_HEADER(v_req, 'Content-Length', LENGTH(p_json));
                UTL_HTTP.WRITE_TEXT(v_req, p_json);

                v_response := get_response(v_req);
                UTL_HTTP.END_REQUEST(v_req);
                
                RETURN v_response;
        END;

END pck_ora_http;
/
