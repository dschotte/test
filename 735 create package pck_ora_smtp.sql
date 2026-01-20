CREATE OR REPLACE PACKAGE pck_ora_smtp IS

        --
        -- Package: PCK_UTL_SMTP
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          25/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods to use oracle smtp
        --

        PROCEDURE send_mail(p_from VARCHAR2, p_to VARCHAR2, p_cc VARCHAR2 DEFAULT NULL, p_bcc VARCHAR2 DEFAULT NULL, p_subject VARCHAR2, p_msg VARCHAR2);

END pck_ora_smtp;
/

CREATE OR REPLACE PACKAGE BODY pck_ora_smtp IS

        TYPE t_array IS TABLE OF VARCHAR2(4000);
        
        FUNCTION split_list(p_list VARCHAR2, p_delimeter VARCHAR2) RETURN t_array IS
                v_array t_array := t_array();
                v_list VARCHAR2(4000) := p_list;
                v_idx NUMBER;
        BEGIN
                v_array.DELETE;
                
                WHILE v_list IS NOT NULL LOOP
                        v_idx := INSTR(v_list, p_delimeter);
                        v_array.EXTEND;
                        IF v_idx > 0 THEN
                                v_array(v_array.LAST) := SUBSTR(v_list, 1, v_idx - 1);
                                v_list := SUBSTR(v_list, v_idx + 1);
                        ELSE
                                v_array(v_array.LAST) := v_list;
                                v_list := NULL;
                        END IF;
                END LOOP;
                
                RETURN v_array;
        END;

        PROCEDURE process_recipients(p_mail_conn IN OUT UTL_SMTP.CONNECTION, p_list VARCHAR2) IS
                v_array t_array;
                COMMA CONSTANT VARCHAR2(1) := ',';
        BEGIN
                IF TRIM(p_list) IS NOT NULL THEN
                        v_array := split_list(p_list, COMMA);
                        FOR i IN 1 .. v_array.COUNT LOOP
                                UTL_SMTP.RCPT(p_mail_conn, TRIM(v_array(i)));
                        END LOOP;
                END IF;
        END;

        PROCEDURE write_recipients(p_mail_conn IN OUT UTL_SMTP.CONNECTION, p_involvement VARCHAR2, p_list VARCHAR2) IS
                COMMA CONSTANT VARCHAR2(1) := ',';
                SEMICOLON CONSTANT VARCHAR2(1) := ';';
        BEGIN
                IF p_involvement NOT IN ('To', 'CC', 'BCC') THEN
                        RAISE_APPLICATION_ERROR(-20000, 'Involvement should be To, CC or BCC');
                END IF;

                IF TRIM(p_list) IS NOT NULL THEN
                        UTL_SMTP.WRITE_DATA(p_mail_conn, p_involvement || ': ' || REPLACE(p_list, COMMA, SEMICOLON) || UTL_TCP.CRLF);
                END IF;
        END;

        PROCEDURE write_subject(p_mail_conn IN OUT UTL_SMTP.CONNECTION, p_subject VARCHAR2) IS
                v_env VARCHAR2(20);
        BEGIN
                SELECT REPLACE(REPLACE(REPLACE(REPLACE(global_name, '01D.BC', ' development env'), '01I.BC', ' integration env'), '01U.BC', ' acceptance env'), '01P.BC', ' production env')
                INTO v_env
                FROM global_name;
                
                UTL_SMTP.WRITE_DATA(p_mail_conn, 'Subject: ' || p_subject || ' [' || v_env || ']' || UTL_TCP.CRLF);            
        END;

        PROCEDURE write_msg(p_mail_conn IN OUT UTL_SMTP.CONNECTION, p_boundary VARCHAR2, p_msg VARCHAR2) IS
        BEGIN
                UTL_SMTP.WRITE_DATA(p_mail_conn, '--' || p_boundary || UTL_TCP.CRLF);
                UTL_SMTP.WRITE_DATA(p_mail_conn, 'Content-Type: text/html; charset="iso-8859-1"' || UTL_TCP.CRLF || UTL_TCP.CRLF);

                UTL_SMTP.WRITE_DATA(p_mail_conn, p_msg || UTL_TCP.CRLF || UTL_TCP.CRLF);

                UTL_SMTP.WRITE_DATA(p_mail_conn, '--' || p_boundary || '--' || UTL_TCP.CRLF);
        END;
       
        --

        PROCEDURE send_mail(p_from VARCHAR2, p_to VARCHAR2, p_cc VARCHAR2 DEFAULT NULL, p_bcc VARCHAR2 DEFAULT NULL, p_subject VARCHAR2, p_msg VARCHAR2) IS
                v_boundary  VARCHAR2(19) := '=*#abc1234321cba#*='; -- some unique string not in email
                v_mail_conn UTL_SMTP.CONNECTION;
                SMTP_HOST CONSTANT VARCHAR2(11) := 'mailhub.bc'; -- was exchange.bc
                COMMA CONSTANT VARCHAR2(1) := ',';
                SEMICOLON CONSTANT VARCHAR2(1) := ';';
        BEGIN
                v_mail_conn := UTL_SMTP.OPEN_CONNECTION(SMTP_HOST, 25);
                UTL_SMTP.HELO(v_mail_conn, SMTP_HOST);
                UTL_SMTP.MAIL(v_mail_conn, p_from);

                process_recipients(v_mail_conn, p_to);
                process_recipients(v_mail_conn, p_cc);
                process_recipients(v_mail_conn, p_bcc);

                UTL_SMTP.OPEN_DATA(v_mail_conn);
                UTL_SMTP.WRITE_DATA(v_mail_conn, 'From: ' || p_from || UTL_TCP.CRLF);
                write_recipients(v_mail_conn, 'To', p_to);
                write_recipients(v_mail_conn, 'CC', p_cc);
                write_recipients(v_mail_conn, 'BCC', p_bcc);
                write_subject(v_mail_conn, p_subject);
                UTL_SMTP.WRITE_DATA(v_mail_conn, 'MIME-Version: 1.0' || UTL_TCP.CRLF);                
                UTL_SMTP.WRITE_DATA(v_mail_conn, 'Content-Type: multipart/alternative; boundary="' || v_boundary || '"' || UTL_TCP.CRLF || UTL_TCP.CRLF);

                write_msg(v_mail_conn, v_boundary, p_msg);
                UTL_SMTP.CLOSE_DATA(v_mail_conn);

                UTL_SMTP.QUIT(v_mail_conn);
        END;

END pck_ora_smtp;
/
