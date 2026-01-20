CREATE OR REPLACE PACKAGE pck_api_pim IS

        --
        -- Package: PCK_API_PIM
        --
        -- Version      Date            Comments
        -- -------      ----------      --------------------------------------------------------------------------------------------
        -- 1.0          29/01/2025      Initial version
        --
        -- Remarks:
        -- 1. methods for pim api
        --

        PROCEDURE upload_code_val_list(p_code_val_list BLOB);

        FUNCTION retrieve_descr_code_val RETURN SYS_REFCURSOR;
        
        --
        
        PROCEDURE load_code_list(p_list BLOB);
        
        FUNCTION  find_descr_code RETURN SYS_REFCURSOR;
        
        FUNCTION  find_code_set RETURN SYS_REFCURSOR;

END pck_api_pim;
/

BEGIN syn_mgr.create_synonym('pck_api_pim'); END;
/
GRANT EXECUTE ON pck_api_pim TO cds_online, cds_batch
/

CREATE OR REPLACE PACKAGE BODY pck_api_pim IS

        PROCEDURE upload_code_val_list(p_code_val_list BLOB) IS
        BEGIN
                MERGE INTO pim_code t USING ( SELECT set_nm
                        ,val
                        ,val_descr_en
                        ,val_descr_fr
                        ,val_descr_nl
                        ,SYSTIMESTAMP AS load_dt
                        FROM JSON_TABLE ( p_code_val_list, '$[*]' COLUMNS ( set_nm PATH '$.setNm'
                                ,val PATH '$.val'
                                ,val_descr_en PATH '$.valDescrEn'
                                ,val_descr_fr PATH '$.valDescrFr'
                                ,val_descr_nl PATH '$.valDescrNl'
                                )
                        )
                ) s
                ON ( t.set_nm = s.set_nm AND t.val = s.val )
                WHEN NOT MATCHED THEN INSERT ( set_nm
                        ,val
                        ,val_descr_en
                        ,val_descr_fr
                        ,val_descr_nl
                        ,load_dt
                        )
                        VALUES ( s.set_nm
                        ,s.val
                        ,s.val_descr_en
                        ,s.val_descr_fr
                        ,s.val_descr_nl
                        ,s.load_dt
                        )
                WHEN MATCHED THEN UPDATE SET val_descr_en = s.val_descr_en
                        ,val_descr_fr = s.val_descr_fr
                        ,val_descr_nl = s.val_descr_nl
                        ,load_dt = s.load_dt
                ;
        END;

        FUNCTION retrieve_descr_code_val RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT ('setNm' VALUE set_nm
                                                   ,'val' VALUE val
                                                   ,'valDescrEn' VALUE val_descr_en
                                                   ,'valDescrFr' VALUE val_descr_fr
                                                   ,'valDescrNl' VALUE val_descr_nl RETURNING BLOB
                                                   ) AS root_obj                                                 
                FROM pim_code
                WHERE val_descr_en IS NOT NULL AND val_descr_fr IS NOT NULL AND val_descr_nl IS NOT NULL
                ORDER BY val;

                RETURN c_list;
        END;
        
        --

        PROCEDURE load_code_list(p_list BLOB) IS
        BEGIN
                MERGE INTO pim_code t USING ( SELECT set_nm
                        ,val
                        ,val_descr_en
                        ,val_descr_fr
                        ,val_descr_nl
                        ,SYSTIMESTAMP AS load_dt
                        FROM JSON_TABLE ( p_list, '$[*]' COLUMNS ( set_nm PATH '$.setNm'
                                ,val PATH '$.val'
                                ,val_descr_en PATH '$.valDescrEn'
                                ,val_descr_fr PATH '$.valDescrFr'
                                ,val_descr_nl PATH '$.valDescrNl'
                                )
                        )
                ) s
                ON( t.set_nm = s.set_nm AND t.val = s.val )
                WHEN NOT MATCHED THEN INSERT ( set_nm
                        ,val
                        ,val_descr_en
                        ,val_descr_fr
                        ,val_descr_nl
                        ,load_dt
                        )
                        VALUES ( s.set_nm
                        ,s.val
                        ,s.val_descr_en
                        ,s.val_descr_fr
                        ,s.val_descr_nl
                        ,s.load_dt
                        )
                WHEN MATCHED THEN UPDATE SET val_descr_en = s.val_descr_en
                        ,val_descr_fr = s.val_descr_fr
                        ,val_descr_nl = s.val_descr_nl
                        ,load_dt = s.load_dt
                ;
        END;

        FUNCTION find_descr_code RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT ('setNm' VALUE set_nm
                                                   ,'val' VALUE val
                                                   ,'valDescrEn' VALUE val_descr_en
                                                   ,'valDescrFr' VALUE val_descr_fr
                                                   ,'valDescrNl' VALUE val_descr_nl RETURNING BLOB
                                                   ) AS root_obj                                                 
                FROM pim_code
                WHERE val_descr_en IS NOT NULL AND val_descr_fr IS NOT NULL AND val_descr_nl IS NOT NULL
                ORDER BY val;

                RETURN c_list;
        END;

        FUNCTION find_code_set RETURN SYS_REFCURSOR IS
                c_list SYS_REFCURSOR;
        BEGIN
                OPEN c_list FOR SELECT JSON_OBJECT ('setNm' VALUE set_nm
                                                   ,'setId' VALUE JSON_OBJECT ('id' VALUE set_id, 'idScope' VALUE set_id_scope, 'idCtx' VALUE set_id_ctx) RETURNING BLOB
                                                   ) AS root_obj                                                 
                FROM pim_code_set
                WHERE set_id IS NOT NULL AND set_id_scope IS NOT NULL AND set_id_ctx IS NOT NULL
                ORDER BY set_id;

                RETURN c_list;
        END;

END pck_api_pim;
/
