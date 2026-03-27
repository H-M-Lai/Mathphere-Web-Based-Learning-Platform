SELECT
    t.TABLE_SCHEMA                      AS [Schema],
    t.TABLE_NAME                        AS [Table],
    c.COLUMN_NAME                       AS [Column],
    c.ORDINAL_POSITION                  AS [Pos],
    c.DATA_TYPE                         AS [DataType],
    CASE
        WHEN c.DATA_TYPE IN ('char','varchar','nchar','nvarchar')
             THEN CAST(c.CHARACTER_MAXIMUM_LENGTH AS varchar)
        WHEN c.DATA_TYPE IN ('decimal','numeric')
             THEN CAST(c.NUMERIC_PRECISION AS varchar)
                  + ',' + CAST(c.NUMERIC_SCALE AS varchar)
        ELSE NULL
    END                                 AS [Length_Precision],
    c.IS_NULLABLE                       AS [Nullable],
    c.COLUMN_DEFAULT                    AS [Default]
FROM
    INFORMATION_SCHEMA.TABLES   t
    JOIN INFORMATION_SCHEMA.COLUMNS c
        ON  c.TABLE_SCHEMA = t.TABLE_SCHEMA
        AND c.TABLE_NAME   = t.TABLE_NAME
WHERE
    t.TABLE_TYPE = 'BASE TABLE'
ORDER BY
    t.TABLE_SCHEMA, t.TABLE_NAME, c.ORDINAL_POSITION;


-- ─────────────────────────────────────────────────────────────────────
--  2. PRIMARY KEYS
-- ─────────────────────────────────────────────────────────────────────
SELECT
    kcu.TABLE_SCHEMA    AS [Schema],
    kcu.TABLE_NAME      AS [Table],
    kcu.COLUMN_NAME     AS [PK_Column],
    kcu.ORDINAL_POSITION AS [KeyOrder],
    tc.CONSTRAINT_NAME  AS [Constraint]
FROM
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS   tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
        ON  kcu.CONSTRAINT_NAME  = tc.CONSTRAINT_NAME
        AND kcu.TABLE_SCHEMA     = tc.TABLE_SCHEMA
WHERE
    tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
ORDER BY
    kcu.TABLE_SCHEMA, kcu.TABLE_NAME, kcu.ORDINAL_POSITION;


-- ─────────────────────────────────────────────────────────────────────
--  3. FOREIGN KEYS (child → parent)
-- ─────────────────────────────────────────────────────────────────────
SELECT
    fk.name                                 AS [FK_Name],
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS [Child_Schema],
    OBJECT_NAME(fk.parent_object_id)        AS [Child_Table],
    COL_NAME(fkc.parent_object_id,  fkc.parent_column_id)    AS [Child_Column],
    OBJECT_SCHEMA_NAME(fk.referenced_object_id)               AS [Parent_Schema],
    OBJECT_NAME(fk.referenced_object_id)    AS [Parent_Table],
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS [Parent_Column],
    fk.delete_referential_action_desc       AS [On_Delete],
    fk.update_referential_action_desc       AS [On_Update]
FROM
    sys.foreign_keys        fk
    JOIN sys.foreign_key_columns fkc
        ON fkc.constraint_object_id = fk.object_id
ORDER BY
    Child_Schema, Child_Table, FK_Name;


-- ─────────────────────────────────────────────────────────────────────
--  4. INDEXES (non-PK)
-- ─────────────────────────────────────────────────────────────────────
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS [Schema],
    OBJECT_NAME(i.object_id)        AS [Table],
    i.name                          AS [Index_Name],
    i.type_desc                     AS [Type],
    i.is_unique                     AS [Unique],
    STRING_AGG(c.name, ', ')
        WITHIN GROUP (ORDER BY ic.key_ordinal) AS [Columns]
FROM
    sys.indexes         i
    JOIN sys.index_columns ic
        ON  ic.object_id = i.object_id
        AND ic.index_id  = i.index_id
    JOIN sys.columns    c
        ON  c.object_id  = i.object_id
        AND c.column_id  = ic.column_id
WHERE
    i.is_primary_key = 0
    AND i.type > 0                    -- exclude heaps
    AND OBJECT_SCHEMA_NAME(i.object_id) != 'sys'
GROUP BY
    i.object_id, i.name, i.type_desc, i.is_unique
ORDER BY
    [Schema], [Table], [Index_Name];


-- ─────────────────────────────────────────────────────────────────────
--  5. CHECK CONSTRAINTS  (e.g. status allowed values)
-- ─────────────────────────────────────────────────────────────────────
SELECT
    tc.TABLE_SCHEMA     AS [Schema],
    tc.TABLE_NAME       AS [Table],
    cc.CONSTRAINT_NAME  AS [Constraint],
    cc.CHECK_CLAUSE     AS [Rule]
FROM
    INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.CHECK_CONSTRAINTS cc
        ON cc.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
ORDER BY
    tc.TABLE_SCHEMA, tc.TABLE_NAME;


-- ─────────────────────────────────────────────────────────────────────
--  6. ROW COUNT PER TABLE  (quick size overview)
-- ─────────────────────────────────────────────────────────────────────
SELECT
    s.name          AS [Schema],
    t.name          AS [Table],
    p.rows          AS [RowCount]
FROM
    sys.tables         t
    JOIN sys.schemas   s ON s.schema_id  = t.schema_id
    JOIN sys.partitions p ON p.object_id = t.object_id
                         AND p.index_id  IN (0, 1)   -- heap or clustered
ORDER BY
    p.rows DESC, s.name, t.name;
