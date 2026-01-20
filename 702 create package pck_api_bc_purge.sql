CREATE OR REPLACE PACKAGE pck_api_bc_purge AS

        --
        -- Package: PCK_API_BC_PURGE
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------
        -- 1.0          10/10/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for business communications purge api
        --
       
        FUNCTION purge RETURN NUMBER;
        
        FUNCTION purge(p_bus_comm_id RAW) RETURN NUMBER;

END pck_api_bc_purge;
/

BEGIN syn_mgr.create_synonym('pck_api_bc_purge'); END;
/
GRANT EXECUTE ON pck_api_bc_purge TO cds_batch
/

CREATE OR REPLACE PACKAGE BODY pck_api_bc_purge AS

        PROCEDURE delete_bus_comm IS
        BEGIN
                DELETE FROM bus_comm_item WHERE bus_comm_id IN (SELECT bus_comm_id FROM bus_comm_tmp);
                DELETE FROM bus_comm_phone_cnt WHERE bus_comm_id IN (SELECT bus_comm_id FROM bus_comm_tmp);
                DELETE FROM bus_comm_post_cnt WHERE bus_comm_id IN (SELECT bus_comm_id FROM bus_comm_tmp);
                DELETE FROM bus_comm_email_cnt WHERE bus_comm_id IN (SELECT bus_comm_id FROM bus_comm_tmp);
                DELETE FROM bus_comm_hist WHERE bus_comm_id IN (SELECT bus_comm_id FROM bus_comm_tmp);

                DELETE FROM bus_comm_event WHERE bus_comm_id IN (SELECT bus_comm_id FROM bus_comm_tmp);

                DELETE FROM bus_comm_req WHERE bus_comm_id IN (SELECT bus_comm_id FROM bus_comm_tmp);
                DELETE FROM bus_comm WHERE bus_comm_id IN (SELECT bus_comm_id FROM bus_comm_tmp);
        END;

        PROCEDURE purge_old(p_before_ret_dt TIMESTAMP, v_purge_num OUT NUMBER) IS
        BEGIN
                IF p_before_ret_dt > SYSTIMESTAMP THEN
                        RAISE_APPLICATION_ERROR(-20001, 'retention date-time must be in the past');
                END IF;

                INSERT INTO bus_comm_tmp (bus_comm_id)
                        SELECT bus_comm_id
                        FROM bus_comm
                        WHERE ret_dt < p_before_ret_dt
                        AND ROWNUM <= pck_param.bus_comm_purge_max;
                delete_bus_comm;
                SELECT COUNT(*) INTO v_purge_num FROM bus_comm_tmp;
        END;

        --
        -- function scheduled as batch; runs daily during nighttime, i.e. 2 AM
        --

        FUNCTION purge RETURN NUMBER IS
                v_purge_num NUMBER;
        BEGIN
                purge_old(SYSTIMESTAMP, v_purge_num);
                RETURN v_purge_num;
        END;

        --
        -- manual purge
        --
        
        FUNCTION purge(p_bus_comm_id RAW) RETURN NUMBER IS
        BEGIN
                INSERT INTO bus_comm_tmp (bus_comm_id)
                        SELECT p_bus_comm_id
                        FROM DUAL;          
                delete_bus_comm;
                RETURN 1;
        END;

END pck_api_bc_purge;
/
