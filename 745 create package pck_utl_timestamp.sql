CREATE OR REPLACE PACKAGE pck_utl_timestamp IS

        --
        -- Package: PCK_UTL_TIMESTAMP
        --
        -- Version      Date            Comments
        -- -------      ----------      ----------------------------------------------------------------------------------------------------
        -- 1.0          27/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods to work with timestamp
        --
              
        FUNCTION diff(p_start_timestamp TIMESTAMP, p_end_timestamp TIMESTAMP, p_unit VARCHAR2) RETURN NUMBER;

END pck_utl_timestamp;
/

CREATE OR REPLACE PACKAGE BODY pck_utl_timestamp IS
        
        FUNCTION diff(p_start_timestamp TIMESTAMP, p_end_timestamp TIMESTAMP, p_unit VARCHAR2) RETURN NUMBER IS
                v_diff NUMBER;
        BEGIN
                --
                -- difference in units between two timestamps
                --
                SELECT EXTRACT (DAY FROM (p_end_timestamp - p_start_timestamp)) * 24 + EXTRACT(HOUR FROM (p_end_timestamp - p_start_timestamp)) INTO v_diff
                FROM DUAL
                WHERE p_unit = 'HOUR'; -- implemented unit

                RETURN v_diff;
        EXCEPTION WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20001, 'unit not implemented');
        END;

END pck_utl_timestamp;
/
