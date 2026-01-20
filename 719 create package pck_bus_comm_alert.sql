CREATE OR REPLACE PACKAGE pck_bus_comm_alert IS

        --
        -- Package: PCK_BUS_COMM_ALERT
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          31/01/2025      Initial version
        --
        -- Remarks:
        -- 1. business communication alerts
        --

        PROCEDURE send;

END pck_bus_comm_alert;
/

CREATE OR REPLACE PACKAGE BODY pck_bus_comm_alert IS

        --
        -- procedure scheduled as job BUS_COMM_ALERT_SEND; runs hourly during office hours
        --

        PROCEDURE send
        IS
                v_since_dt TIMESTAMP := SYSTIMESTAMP - 1/24; -- 1 hour ago

                C_CDS_EVENT CONSTANT VARCHAR2(9) := 'CDS_EVENT';
                C_CDS CONSTANT VARCHAR2(3) := 'CDS';
                C_PUBLISH_ENABLED CONSTANT VARCHAR2(15) := 'PUBLISH_ENABLED';
                C_ALERT_FROM CONSTANT VARCHAR2(24) := 'id076829m12@proximus.com'; -- AS-DMA
                C_ALERT_SUBJECT CONSTANT VARCHAR2(28) := 'Business communication alert';
                v_tx_id RAW(16);
                v_alert_int_descr VARCHAR2(15) := '1 hour to ' || TO_CHAR(SYSTIMESTAMP, 'HH24:MI');
                v_alert_to param.par_val%TYPE := pck_param.alert_to;
                v_html VARCHAR2(4000);
                v_alert_needed BOOLEAN := FALSE;
        BEGIN
                v_tx_id := pck_bus_comm_hist.first_tx_uuid(v_since_dt);

                v_html := '<html><head><style>table {width:100%;} table,th,td {border:1px solid black;}</style></head><body><table><tr><th>Module</th></th><th>Problem</th><th>Alert interval</th><th>Check needed? (Y/N)</th></tr>';
                IF v_tx_id IS NOT NULL THEN
                        IF pck_param.is_yes(C_CDS_EVENT, C_PUBLISH_ENABLED, v_since_dt) AND NOT pck_bus_comm_event.published(v_tx_id) THEN
                                v_alert_needed := TRUE;
                                v_html := v_html || '<tr><td>' || C_CDS_EVENT || '</td><td>Publish process delay</td><td>' || v_alert_int_descr || '</td><td style="color:red">Y</td></tr>';
                        END IF;
                END IF;
                IF pck_utl_err.alert_needed(v_since_dt) THEN
                        v_alert_needed := TRUE;
                        v_html := v_html || '<tr><td>' || C_CDS || '</td><td>Process error</td><td>' || v_alert_int_descr || '</td><td style="color:orange">Y</td></tr>';
                END IF;
                v_html := v_html || '</table></body></html>';

                IF v_alert_needed THEN
                        pck_ora_smtp.send_mail(C_ALERT_FROM, v_alert_to, NULL, NULL, C_ALERT_SUBJECT, v_html);
                END IF;

                DBMS_OUTPUT.PUT_LINE(SYS.DIUTIL.BOOL_TO_INT(v_alert_needed) || ' sent');
        END;

END pck_bus_comm_alert;
/
