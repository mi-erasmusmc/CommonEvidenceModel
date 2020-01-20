--@vocabSchema

IF OBJECT_ID('@tableName','U') IS NOT NULL
DROP TABLE @tableName;

CREATE TABLE @tableName (
  ID SERIAL,
	SOURCE_ID	VARCHAR(20),
	SOURCE_CODE_1	VARCHAR(50),
	SOURCE_CODE_TYPE_1	VARCHAR(55),
	SOURCE_CODE_NAME_1	VARCHAR(500),
	RELATIONSHIP_ID	VARCHAR(20),
	SOURCE_CODE_2	VARCHAR(50),
	SOURCE_CODE_TYPE_2	VARCHAR(55),
	SOURCE_CODE_NAME_2	VARCHAR(500),
	UNIQUE_IDENTIFIER	VARCHAR(50),
	UNIQUE_IDENTIFIER_TYPE	VARCHAR(50),
  SPL_ID VARCHAR(50),
  TRADE_NAME VARCHAR(500),
  SPL_DATE DATE,
  SPL_SECTION VARCHAR(50),
  CONDITION_PT VARCHAR(500)
);

INSERT INTO @tableName (SOURCE_ID, SOURCE_CODE_1,
	SOURCE_CODE_TYPE_1, SOURCE_CODE_NAME_1, RELATIONSHIP_ID,
	SOURCE_CODE_2, SOURCE_CODE_TYPE_2,	SOURCE_CODE_NAME_2,
	UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE, SPL_ID,TRADE_NAME,SPL_DATE,
	SPL_SECTION,CONDITION_PT)
SELECT DISTINCT
  '@sourceId' AS SOURCE_ID,
	s.SET_ID AS SOURCE_CODE_1,
	'SET_ID' AS SOURCE_CODE_TYPE_1,
	s.TRADE_NAME AS SOURCE_CODE_NAME_1,
	'Has Adverse Event' AS RELATIONSHP_ID,
	s.CONDITION_CONCEPT_ID AS SOURCE_CODE_2,
	'OMOP CONCEPT_ID' AS SOURCE_CODE_TYPE_2,
	s.CONDITION_LLT AS SOURCE_CODE_NAME_2,
	s.SET_ID AS UNIQUE_IDENTIFIER,
	'SET_ID' AS UNIQUE_IDENTIFIER_TYPE,
	s.SPL_ID,
	s.TRADE_NAME,
	CAST(s.SPL_DATE AS DATE) AS SPL_DATE,
	s.SPL_SECTION,
	s.CONDITION_PT
FROM @sourceSchema.dbo.SPLICER s
ORDER BY s.SET_ID, s.CONDITION_LLT;

CREATE INDEX IDX_@sourceId_UNIQUE_IDENTIFIER_SOURCE_CODE_1_SOURCE_CODE_2 ON @tableName (UNIQUE_IDENTIFIER, SOURCE_CODE_1, SOURCE_CODE_2);

ALTER TABLE @tableName OWNER TO RW_GRP;
