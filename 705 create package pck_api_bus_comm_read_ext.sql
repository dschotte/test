CREATE OR REPLACE PACKAGE pck_api_bus_comm_read_ext AS

        --
        -- Package: PCK_API_BUS_COMM_READ_EXT
        --
        -- Version      Date            Comments
        -- -------      ----------      ------------------------------------------------------------------------------------------------------------------------
        -- 1.0          23/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for business communication read extended api
        --

        FUNCTION find(p_reader_app_id VARCHAR2, p_offset_num NUMBER, p_next_num NUMBER, p_sorting_dir VARCHAR2, p_ctry_pfx VARCHAR2, p_natl_num VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_dir_cd VARCHAR2, p_subm_app_id VARCHAR2, p_ch_class_cd VARCHAR2) RETURN SYS_REFCURSOR;

END pck_api_bus_comm_read_ext;
/

BEGIN syn_mgr.create_synonym('pck_api_bus_comm_read_ext'); END;
/
GRANT EXECUTE ON pck_api_bus_comm_read_ext TO cds_online
/

CREATE OR REPLACE PACKAGE BODY pck_api_bus_comm_read_ext AS

        FUNCTION find(p_offset_num NUMBER, p_next_num NUMBER, p_sorting_dir VARCHAR2, p_ctry_pfx VARCHAR2, p_natl_num VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_dir_cd VARCHAR2, p_subm_app_id VARCHAR2, p_ch_class_cd VARCHAR2) RETURN SYS_REFCURSOR IS
                v_sql VARCHAR2(4000) := CHR(32);
                c_cursor SYS_REFCURSOR;
        BEGIN
                v_sql := v_sql || ' WITH bus_comm_id_table AS ( SELECT p.bus_comm_id FROM bus_comm_phone_cnt p WHERE 1 = 1 ';

                v_sql := v_sql || ' AND p.ctry_pfx = :p_ctry_pfx AND p.natl_num = :p_natl_num ';
                v_sql := v_sql || ' AND p.start_dt >= :p_since_start_dt AND p.start_dt < :p_before_start_dt ';
                v_sql := v_sql || ' AND p.role_type = DECODE(:p_dir_cd, ''BCDIR001'', ''SENT_FROM'', ''BCDIR002'', ''SENT_TO'') ';

                IF p_subm_app_id IS NOT NULL THEN
                        v_sql := v_sql || ' AND p.subm_app_id = :p_subm_app_id ';
                ELSE
                        v_sql := v_sql || ' AND (1 = 1 OR :p_subm_app_id IS NULL) ';
                END IF;

                IF p_ch_class_cd IS NOT NULL THEN
                        v_sql := v_sql || ' AND p.ch_class_cd = :p_ch_class_cd ';
                ELSE
                        v_sql := v_sql || ' AND (1 = 1 OR :p_ch_class_cd IS NULL) ';
                END IF;

                v_sql := v_sql || ' ORDER BY p.start_dt ' || p_sorting_dir;
                v_sql := v_sql || ' OFFSET :p_offset_num ROWS FETCH NEXT :p_next_num ROWS ONLY ) ';
                
                v_sql := v_sql || ' SELECT j.bus_comm_id, j.start_dt, j.bus_comm_json_ext AS root_obj FROM bus_comm_json_ext j JOIN bus_comm_id_table t ON j.bus_comm_id = t.bus_comm_id ';
                v_sql := v_sql || ' ORDER BY j.start_dt ' || p_sorting_dir;

                OPEN c_cursor FOR v_sql USING p_ctry_pfx, p_natl_num, p_since_start_dt, p_before_start_dt, p_dir_cd, p_subm_app_id, p_ch_class_cd, p_offset_num, p_next_num;

                RETURN c_cursor;
        END;

        --

        FUNCTION find(p_reader_app_id VARCHAR2, p_offset_num NUMBER, p_next_num NUMBER, p_sorting_dir VARCHAR2, p_ctry_pfx VARCHAR2, p_natl_num VARCHAR2, p_since_start_dt TIMESTAMP, p_before_start_dt TIMESTAMP, p_dir_cd VARCHAR2, p_subm_app_id VARCHAR2, p_ch_class_cd VARCHAR2) RETURN SYS_REFCURSOR IS
                c_cursor SYS_REFCURSOR;
        BEGIN
                pck_bus_comm_read_ext_log.log_find(p_reader_app_id, p_offset_num, p_next_num, p_sorting_dir, p_ctry_pfx, p_natl_num, p_since_start_dt, p_before_start_dt, p_dir_cd, p_subm_app_id, p_ch_class_cd);

                IF p_offset_num IS NULL OR p_next_num IS NULL OR p_ctry_pfx IS NULL OR p_natl_num IS NULL OR p_since_start_dt IS NULL OR p_before_start_dt IS NULL OR p_dir_cd IS NULL THEN
                        OPEN c_cursor FOR SELECT NULL AS bus_comm_id, NULL AS start_dt, NULL AS root_obj FROM DUAL WHERE 1 = 0;
                ELSE
                        c_cursor := find(p_offset_num, p_next_num, p_sorting_dir, p_ctry_pfx, p_natl_num, p_since_start_dt, p_before_start_dt, p_dir_cd, p_subm_app_id, p_ch_class_cd);                     
                END IF;

                RETURN c_cursor;
        END;

END pck_api_bus_comm_read_ext;
/
