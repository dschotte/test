CREATE OR REPLACE PACKAGE pck_utl_base64 IS

        --
        -- Package: PCK_UTL_BASE64
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          26/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods to work with base64
        --

        FUNCTION base64_to_blob(p_base64 CLOB) RETURN BLOB;        

        FUNCTION blob_to_base64(p_blob BLOB) RETURN CLOB;  
        
END pck_utl_base64;
/

CREATE OR REPLACE PACKAGE BODY pck_utl_base64 IS

        FUNCTION base64_to_blob(p_base64 CLOB) RETURN BLOB IS
                v_base64_offset INTEGER := 1;
                v_blob BLOB;
                v_chunk_size INTEGER := 12000; -- set a multiple of 3 not higher than 32767
                v_buffer VARCHAR2(32767);
        BEGIN
                BEGIN
                        IF p_base64 IS NULL THEN
                                RETURN NULL;
                        END IF;
                        DBMS_LOB.CREATETEMPORARY(v_blob, FALSE, DBMS_LOB.CALL);
                        LOOP
                                DBMS_LOB.READ(p_base64, v_chunk_size, v_base64_offset, v_buffer);
                                v_base64_offset := v_base64_offset + v_chunk_size;
                                DBMS_LOB.APPEND(v_blob, TO_BLOB(UTL_ENCODE.BASE64_DECODE(UTL_RAW.CAST_TO_RAW(v_buffer))));
                        END LOOP;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        NULL;
                END;
                RETURN v_blob;
        END;        

        FUNCTION blob_to_base64(p_blob BLOB) RETURN CLOB IS
                v_blob_offset INTEGER := 1;
                v_base64 CLOB;
                v_chunk_size INTEGER := 12000; -- set a multiple of 3 not higher than 24573
                v_chunk RAW(32767);
        BEGIN
                BEGIN
                        IF p_blob IS NULL THEN
                                RETURN NULL;
                        END IF;
                        DBMS_LOB.CREATETEMPORARY(v_base64, FALSE, DBMS_LOB.CALL);
                        LOOP
                                DBMS_LOB.READ(p_blob, v_chunk_size, v_blob_offset, v_chunk);
                                v_blob_offset := v_blob_offset + v_chunk_size;
                                DBMS_LOB.APPEND(v_base64, TO_CLOB(UTL_RAW.CAST_TO_VARCHAR2(UTL_ENCODE.BASE64_ENCODE(v_chunk))));
                        END LOOP;
                EXCEPTION WHEN NO_DATA_FOUND THEN
                        NULL;
                END;
                RETURN v_base64;
        END;        
        
END pck_utl_base64;
/
