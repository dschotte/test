CREATE OR REPLACE PACKAGE pck_udf_uuid IS

        --
        -- Package: PCK_UDF_UUID
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------
        -- 1.0          25/01/2025      Initial version
        --
        -- Remarks:
        -- 1. user defined functions for uuid
        --

        FUNCTION iso_to_raw(p_uuid VARCHAR2) RETURN RAW;

        FUNCTION raw_to_iso(p_uuid RAW) RETURN VARCHAR2;

END pck_udf_uuid;
/

CREATE OR REPLACE PACKAGE BODY pck_udf_uuid IS
        
        FUNCTION iso_to_raw(p_uuid VARCHAR2) RETURN RAW IS
                PRAGMA UDF;
        BEGIN
                --
                -- http://www.itu.int/rec/T-REC-X.667/en; accept both lowercase and uppercase 
                --
                IF NOT REGEXP_LIKE(p_uuid, '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$') THEN
                        RETURN NULL;
                END IF;
                --
                -- remove dashes, uppercase
                --
                RETURN HEXTORAW(REPLACE(p_uuid, '-', NULL));
        END;

        FUNCTION raw_to_iso(p_uuid RAW) RETURN VARCHAR2 IS
                PRAGMA UDF;
        BEGIN
                --
                -- http://www.itu.int/rec/T-REC-X.667/en; format with dashes, lowercase
                --
                RETURN LOWER(REGEXP_REPLACE(RAWTOHEX(p_uuid), '([0-9A-F]{8})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{4})([0-9A-F]{12})', '\1-\2-\3-\4-\5'));
        END;

END pck_udf_uuid;
/
