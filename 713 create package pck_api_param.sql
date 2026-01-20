CREATE OR REPLACE PACKAGE pck_api_param AS

        --
        -- Package: PCK_API_PARAM
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------
        -- 1.0          06/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for parameter api
        --

        FUNCTION get_param_val(p_module_nm VARCHAR2, p_param_nm VARCHAR2) RETURN VARCHAR2;

        FUNCTION find_param(p_module_nm VARCHAR2) RETURN SYS_REFCURSOR;

END pck_api_param;
/

BEGIN syn_mgr.create_synonym('pck_api_param'); END;
/
GRANT EXECUTE ON pck_api_param TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_param AS

        FUNCTION get_param_val(p_module_nm VARCHAR2, p_param_nm VARCHAR2) RETURN VARCHAR2 IS
                v_param_val param.param_val%TYPE;
        BEGIN
                SELECT param_val INTO v_param_val
                FROM param
                WHERE module_nm = p_module_nm AND param_nm = p_param_nm;
                
                RETURN v_param_val;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

        FUNCTION find_param(p_module_nm VARCHAR2) RETURN SYS_REFCURSOR IS
                c_cursor SYS_REFCURSOR;
        BEGIN
                OPEN c_cursor FOR SELECT JSON_OBJECT('param_nm' VALUE param_nm, 'param_val' VALUE param_val RETURNING BLOB) AS root_obj
                FROM param
                WHERE module_nm = p_module_nm;

                RETURN c_cursor;
        END;        

END pck_api_param;
/
