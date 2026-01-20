CREATE OR REPLACE PACKAGE pck_ora_load_table AS

        --
        -- Package: PCK_ORA_LOAD_TABLE
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------
        -- 1.0          25/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods to use oracle load tables
        --

        PROCEDURE truncate(p_table VARCHAR2);
       
        PROCEDURE gather_stats(p_owner VARCHAR2, p_table VARCHAR2);

        PROCEDURE swap(p_table VARCHAR2, p_other_table VARCHAR2);
 
END pck_ora_load_table;
/

CREATE OR REPLACE PACKAGE BODY pck_ora_load_table AS

        PROCEDURE truncate(p_table VARCHAR2) IS
        BEGIN
                EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || p_table;
        END;

        PROCEDURE gather_stats(p_owner VARCHAR2, p_table VARCHAR2) IS
        BEGIN
                DBMS_STATS.GATHER_TABLE_STATS(p_owner, p_table, cascade => TRUE);
        END;
        
        PROCEDURE swap(p_table VARCHAR2, p_other_table VARCHAR2) IS
                v_temp_other_table VARCHAR2(128) := 'TEMP_' || p_other_table;
        BEGIN
                EXECUTE IMMEDIATE 'ALTER TABLE ' || p_other_table || ' RENAME TO ' || v_temp_other_table;
                EXECUTE IMMEDIATE 'ALTER TABLE ' || p_table || ' RENAME TO ' || p_other_table;
                EXECUTE IMMEDIATE 'ALTER TABLE ' || v_temp_other_table || ' RENAME TO ' || p_table;
        END;

END pck_ora_load_table;
/
