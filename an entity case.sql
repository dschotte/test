--
-- blob in beginning of table
--
CREATE TABLE tst_entity
(creation_dt TIMESTAMP NOT NULL
,entity BLOB CONSTRAINT tst_entity_chk CHECK (entity IS JSON)
,entity_id RAW(16) PRIMARY KEY
)
LOB (entity) STORE AS SECUREFILE (ENABLE STORAGE IN ROW NOCOMPRESS CACHE)
TABLESPACE CDS_DATA
/

--
-- 1.000.000 rows in 38,965 s (1 index = pk)
--
INSERT INTO tst_entity (creation_dt, entity_id, entity)
SELECT
SYSTIMESTAMP AS creation_dt,
SYS_GUID() AS entity_id,
'{"PONumber" : ' || ROWNUM || ',
  "Reference" : "2022' || ROWNUM || 'DBOWIE",
  "Requestor" : "David Bowie",
  "User" : "DBOWIE",
  "CostCenter" : "A42",
  "ShippingInstructions" : {"name" : "David Bowie",
                            "Address": {"street" : "42 Ziggy Street",
                                        "city" : "Canberra",
                                         "state" : "ACT",
                                         "zipCode" : 2601,
                                         "country" : "Australia"},
                            "Phone" : [{"type" : "Office", "number" : "555-' || ROWNUM || '"},
                                       {"type" : "Mobile", "number" : "777-' || ROWNUM || '"}]},
  "Special Instructions" : null,
  "AllowPartialShipment" : true,
  "LineItems" : [{"ItemNumber" : 1,
                  "Part" : {"Description" : "Hunky Dory",
                            "UnitPrice" : 10.95},
                             "Quantity" : 5.0},
                 {"ItemNumber" : 2,
                  "Part" : {"Description" : "Pin-Ups",
                            "UnitPrice" : 10.95},
                            "Quantity" : 3.0}]}' AS entity
FROM DUAL CONNECT BY LEVEL <= 1000000
/

--
-- 1.000.000 rows in 3,184 s
--
BEGIN
DBMS_STATS.GATHER_TABLE_STATS(ownname=>null, tabname=>'TST_ENTITY');
END;
/



--
-- lookup detail table -- 2.000.000 rows in 14,714 s -- we do this with ERROR ON ERROR NULL ON EMPTY
--
CREATE TABLE tst_entity_phone AS
SELECT t.entity_id, jt.phone_tp, jt.phone_nr
FROM tst_entity t,
     JSON_TABLE( t.entity, '$.ShippingInstructions.Phone[*]'
       ERROR ON ERROR NULL ON EMPTY
       COLUMNS (phone_tp VARCHAR2(20) PATH '$.type'
               ,phone_nr VARCHAR2(15) PATH '$.number'
               ) ) jt
WHERE jt.phone_nr IS NOT NULL
/

BEGIN
DBMS_STATS.GATHER_TABLE_STATS(ownname=>null, tabname=>'TST_ENTITY_PHONE');
END;
/

--
-- 2.000.000 rows in 2,325 s
--
CREATE INDEX tst_entity_phone_fk ON tst_entity_phone (entity_id)
TABLESPACE cds_idx
/
--
-- 0,041 s
--
ALTER TABLE tst_entity_phone
ADD CONSTRAINT tst_entity_phone_fk FOREIGN KEY (entity_id) REFERENCES tst_entity (entity_id) -- indexed by tst_entity_phone_fk
ENABLE NOVALIDATE -- we just got the master data
/

--
-- 2.000.000 rows in 5,437 s
--
CREATE INDEX tst_entity_phone_idx ON tst_entity_phone (phone_nr)
TABLESPACE cds_idx
/

--
-- lookup by phone
--
SELECT e.* FROM tst_entity e
WHERE EXISTS (SELECT 1 FROM tst_entity_phone p WHERE p.entity_id = e.entity_id AND p.phone_nr = '777-8' AND p.phone_tp = 'Mobile')
/
--
-- suppose phone type is not in lookup table
--
SELECT e.* FROM tst_entity e
WHERE EXISTS (SELECT 1 FROM tst_entity_phone p WHERE p.entity_id = e.entity_id AND p.phone_nr = '777-8')
AND JSON_EXISTS (e.entity, '$.ShippingInstructions.Phone[*]?(@.number == $number && @.type == $type)' PASSING '777-8' AS "number", 'Mobile' AS "type")
/
--
-- we can also extend the lookup table with a view
--
CREATE OR REPLACE VIEW tst_entity_phone_v AS
SELECT p.entity_id,
       p.phone_nr,
       j.phone_tp
FROM   tst_entity_phone p
JOIN   tst_entity e ON e.entity_id = p.entity_id
JOIN   JSON_TABLE(e.entity, '$.ShippingInstructions.Phone[*]' COLUMNS (phone_nr PATH '$.number' ,phone_tp PATH '$.type')) j ON j.phone_nr = p.phone_nr
/

--
-- and then try... but this is much slower
--
SELECT e.* FROM tst_entity e
WHERE EXISTS (SELECT 1 FROM tst_entity_phone_v v WHERE v.entity_id = e.entity_id AND v.phone_nr = '777-8' AND v.phone_tp = 'Mobile')
/
