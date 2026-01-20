CREATE OR REPLACE PACKAGE pck_param IS

        --
        -- Package: PCK_PARAM
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          10/10/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on param table
        --

        FUNCTION param_val(p_module_nm VARCHAR2, p_param_nm VARCHAR2) RETURN VARCHAR2;

        FUNCTION alert_to RETURN VARCHAR2;

        FUNCTION pod_total(p_module_nm VARCHAR2) RETURN NUMBER;
        
        FUNCTION bus_comm_purge_max RETURN NUMBER;

END pck_param;
/

CREATE OR REPLACE PACKAGE BODY pck_param IS

        FUNCTION param_val(p_module_nm VARCHAR2, p_param_nm VARCHAR2) RETURN VARCHAR2 IS
                v_param_val param.param_val%TYPE;
        BEGIN
                SELECT param_val INTO v_param_val
                FROM param
                WHERE module_nm = p_module_nm AND param_nm = p_param_nm;

                RETURN v_param_val;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RETURN NULL;
        END;

        FUNCTION alert_to RETURN VARCHAR2 IS
        BEGIN
                RETURN param_val('CDS', 'ALERT_TO');
        END;

        FUNCTION pod_total(p_module_nm VARCHAR2) RETURN NUMBER IS
        BEGIN
                RETURN TO_NUMBER(NVL(param_val(p_module_nm, 'POD_TOTAL'), 0));
        END;

        FUNCTION bus_comm_purge_max RETURN NUMBER IS
        BEGIN
                RETURN TO_NUMBER(NVL(param_val('CDS', 'BUS_COMM_PURGE_MAX'), 1000));
        END;

END pck_param;
/
