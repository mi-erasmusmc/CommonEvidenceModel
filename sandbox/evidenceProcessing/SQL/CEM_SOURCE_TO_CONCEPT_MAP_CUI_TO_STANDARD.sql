/*Generate Temporary UMLS Lookup*/
SELECT DISTINCT CUI, SAB AS SOURCE_CODE_TYPE, MIN(c.concept_id) AS CONCEPT_ID
INTO #TEMP_1
FROM @umls.MRCONSO m
	JOIN @vocabulary.CONCEPT c
		ON c.concept_code = m.SCUI
WHERE ((SAB = 'SNOMEDCT_US' AND LAT = 'ENG' AND TTY='PT')
OR SAB = 'RXNORM')
GROUP BY CUI, SAB;

/*To Get Rid of SNOMED CT Duplicates for RxNorm*/
SELECT CUI
INTO #TEMP_DUPES
FROM #TEMP_1
GROUP BY CUI
HAVING COUNT(*) > 1;

SELECT *
INTO #TEMP_UMLS_LU
FROM #TEMP_1
WHERE CUI IN (
	SELECT CUI FROM #TEMP_DUPES
)
AND SOURCE_CODE_TYPE = 'RxNorm'
UNION
SELECT *
FROM #TEMP_1
WHERE CUI NOT IN (
	SELECT CUI FROM #TEMP_DUPES
)
ORDER BY 1,2;

/* replace any existing CUI_TO_STANDARD code mappings in the STCM table */

DROP INDEX IF EXISTS {@targetDialect == "postgresql"} ? {@schema.}IDX_STCM_SOURCE_CODE {@targetDialect == "sql server"} ? {ON @fqTableName};

DELETE FROM @fqTableName where SOURCE_VOCABULARY_ID = 'CUI_TO_STANDARD';

INSERT INTO @fqTableName (SOURCE_CODE, SOURCE_CONCEPT_ID, SOURCE_VOCABULARY_ID,
  SOURCE_CODE_DESCRIPTION, TARGET_CONCEPT_ID, TARGET_VOCABULARY_ID,
  VALID_START_DATE, VALID_END_DATE, INVALID_REASON)

  SELECT CUI AS SOURCE_CODE,
  	0 AS SOURCE_CONCEPT_ID,
  	'CUI_TO_STANDARD' AS SOURCE_VOCABULARY_ID,
  	'' AS SOURCE_CODE_DESCRIPTION,
  	CONCEPT_ID AS TARGET_CONCEPT_ID,
  	NULL AS TARGET_CONCEPT_ID,
  	CAST('1970-01-01' AS DATE) AS VALID_START_DATE,
    CAST('2099-12-31' AS DATE) AS VALID_END_DATE,
  	NULL AS INVALID_REASON
  FROM #TEMP_UMLS_LU;

CREATE INDEX IDX_STCM_SOURCE_CODE ON @fqTableName (SOURCE_CODE);