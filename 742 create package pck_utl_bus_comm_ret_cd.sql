CREATE OR REPLACE PACKAGE pck_utl_bus_comm_ret_cd IS

        --
        -- Package: PCK_UTL_BUS_COMM_RET_CD
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          25/01/2025      Initial version
        --
        -- Remarks:
        -- 1. utilty methods for business communication retention code
        --
        
        FUNCTION get_ret_cd(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN VARCHAR2;

END pck_utl_bus_comm_ret_cd;
/

CREATE OR REPLACE PACKAGE BODY pck_utl_bus_comm_ret_cd IS

        FUNCTION get_ret_cd(p_bus_comm_hist BUS_COMM_HIST_OBJ) RETURN VARCHAR2 IS
                TX_CREATE CONSTANT VARCHAR2(1) := 'C';
                v_ret_cd VARCHAR2(2);
                v_tpl_id VARCHAR2(4000) := UPPER(TRIM(p_bus_comm_hist.tpl_id));
        BEGIN
                IF p_bus_comm_hist.tx_type = TX_CREATE THEN
                        IF p_bus_comm_hist.tx_app_id = 'OCT' THEN
                                IF p_bus_comm_hist.subm_app_id = 'DOF' AND v_tpl_id = 'WEBSHOPORDERCONFIRMATION_JO' THEN
                                        v_ret_cd := 'JO';
                                ELSIF p_bus_comm_hist.subm_app_id = 'MCH' AND v_tpl_id IN ('WEBSHOPORDERCONFIRMATION_JO', 'WEBSHOPORDERCONFIRMATIONMIL_JO') THEN
                                        v_ret_cd := 'JO';
                                ELSIF p_bus_comm_hist.subm_app_id = 'MCOM' AND v_tpl_id = 'LOA_CONTRACTS_CONFIRM' THEN
                                        v_ret_cd := 'JO';
                                END IF;
                        ELSIF p_bus_comm_hist.tx_app_id = 'CDCX' THEN
                                IF p_bus_comm_hist.subm_app_id IN ('DOF', 'MCH') AND v_tpl_id = 'ORD_WEBCONFJO' THEN
                                        v_ret_cd := 'JO';
                                END IF;
                        END IF;
                END IF;

                RETURN NVL(v_ret_cd, 'DF');
        END;

END pck_utl_bus_comm_ret_cd;
/
