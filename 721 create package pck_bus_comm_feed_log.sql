CREATE OR REPLACE PACKAGE pck_bus_comm_feed_log IS

        --
        -- Package: PCK_BUS_COMM_FEED_LOG
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          08/02/2025      Initial version
        --
        -- Remarks:
        -- 1. methods on bus_comm_feed_log table
        --

        PROCEDURE log_feed(p_bus_comm_hist BUS_COMM_HIST_OBJ);

END pck_bus_comm_feed_log;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_feed_log IS     

        PROCEDURE log_feed(p_bus_comm_hist BUS_COMM_HIST_OBJ) IS
                PRAGMA AUTONOMOUS_TRANSACTION;          
        BEGIN
                UPDATE bus_comm_feed_log SET feed_dt = p_bus_comm_hist.creation_dt WHERE feeder_app_id = p_bus_comm_hist.tx_app_id;
                
                IF SQL%ROWCOUNT = 0 THEN
                        INSERT INTO bus_comm_feed_log (feeder_app_id, feed_dt) VALUES (p_bus_comm_hist.tx_app_id, p_bus_comm_hist.creation_dt);
                END IF;  
                
                COMMIT;
        EXCEPTION WHEN OTHERS THEN
                ROLLBACK;
                RAISE;                    
        END;

END pck_bus_comm_feed_log;
/
