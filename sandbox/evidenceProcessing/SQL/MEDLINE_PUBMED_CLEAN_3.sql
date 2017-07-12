WITH CTE_PAIRS AS (
	SELECT *
	FROM (
		SELECT DISTINCT MESH_CODE AS DRUG_MESH_CODE, MESH_NAME AS DRUG_MESH_NAME
		FROM @tableNameForPrep
		WHERE MESH_TYPE = 'DRUG'
		AND MESH_CODE = '@drug'
	) z
	CROSS JOIN (
		SELECT DISTINCT MESH_CODE AS CONDITION_MESH_CODE, MESH_NAME AS CONDITION_MESH_NAME
		FROM @tableNameForPrep
		WHERE MESH_TYPE = 'CONDITION'
		--AND MESH_CODE = '@condition'
	) x
)
INSERT INTO @tableName (SOURCE_ID, SOURCE_CODE_1, SOURCE_CODE_TYPE_1, SOURCE_CODE_NAME_1,
	RELATIONSHIP_ID, SOURCE_CODE_2, SOURCE_CODE_TYPE_2, SOURCE_CODE_NAME_2,
	UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE, DISTINCT_PMID_COUNT)
SELECT DISTINCT
	'MEDLINE_PUBMED' AS SOURCE_ID,
	p.DRUG_MESH_CODE AS SOURCE_CODE_1,
	'MeSH' AS SOURCE_CODE_TYPE_1,
	p.DRUG_MESH_NAME AS SOURCE_CODE_NAME_1,
	'Co-Occurrence' AS RELATIONSHIP_ID,
	p.CONDITION_MESH_CODE AS SOURCE_CODE_2,
	'MeSH' AS SOURCE_CODE_TYPE_2,
	p.CONDITION_MESH_NAME AS SOURCE_CODE_NAME_2,
	p.DRUG_MESH_CODE +'-'+ p.CONDITION_MESH_CODE AS UNIQUE_IDENTIFIER,
	'DRUG_MESH_CODE-CONDITION_MESH_CODE' AS UNIQUE_IDENTIFIER_TYPE,
	COUNT(DISTINCT c.PMID) AS DISTINCT_PMID_COUNT
FROM CTE_PAIRS p
	LEFT OUTER JOIN @tableNameForPrep d
		ON d.MESH_CODE = p.DRUG_MESH_CODE
	LEFT OUTER JOIN @tableNameForPrep c
		ON c.MESH_CODE = p.CONDITION_MESH_CODE
		AND c.PMID = d.PMID
GROUP BY p.DRUG_MESH_CODE, p.DRUG_MESH_NAME, p.CONDITION_MESH_CODE, p.CONDITION_MESH_NAME