CREATE OR REPLACE PACKAGE pck_bus_comm_alert IS

        --
        -- Package: PCK_BUS_COMM_ALERT
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------------------------
        -- 1.0          07/02/2025      Initial version
        --
        -- Remarks:
        -- 1. business communication alert
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
                C_MAIL_FROM CONSTANT VARCHAR2(24) := 'id076829m12@proximus.com'; -- AS-DMA
                C_MAIL_SUBJECT CONSTANT VARCHAR2(28) := 'Business communication alert';
                v_mail_to param.param_val%TYPE := pck_param.alert_to;
                v_html VARCHAR2(4000);
                v_alert_int_descr VARCHAR2(15) := '1 hour to ' || TO_CHAR(SYSTIMESTAMP, 'HH24:MI');
                v_alert_needed BOOLEAN := FALSE;
        BEGIN
                v_html := '<html><head><style>table {width:100%;} table,th,td {border:1px solid black;}</style></head><body><table><tr><th>Module</th></th><th>Problem</th><th>Alert interval</th><th>Check needed? (Y/N)</th></tr>';
                IF pck_bus_comm_req_err.alert_needed(v_since_dt) THEN
                        v_alert_needed := TRUE;
                        v_html := v_html || '<tr><td>' || C_CDS_EVENT || '</td><td>Request error</td><td>' || v_alert_int_descr || '</td><td style="color:orange; font-weight: bold;">Y</td></tr>';
                END IF;
                v_html := v_html || '</table></body></html>';
                IF v_alert_needed THEN
                        pck_ora_smtp.send_mail(C_MAIL_FROM, v_mail_to, NULL, NULL, C_MAIL_SUBJECT, v_html);
                END IF;
                DBMS_OUTPUT.PUT_LINE(SYS.DIUTIL.BOOL_TO_INT(v_alert_needed) || ' sent');
        END;

END pck_bus_comm_alert;
/
