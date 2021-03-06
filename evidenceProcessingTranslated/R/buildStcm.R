# Copyright 2017 Observational Health Data Sciences and Informatics
#
# This file is part of evidenceProcessingTranslated
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#' Build SOURCE_TO_CONCEPT_MAP
#'
#' @param connectionDetails connection information
#'
#' @param vocabulary where is the vocabulary located
#'
#' @param stcmTable where to load the STCM
#'
#' @param umlsSchema where to pick up UMLS mappings
#'
#' @param faers where can we find the FAERS data
#'
#' @export
buildStcm <- function(connectionDetails,vocabulary,stcmTable,umlsSchema,faers,sherlock){
  ################################################################################
  # VARIABLES
  ################################################################################
  conn <- DatabaseConnector::connect(connectionDetails = connectionDetails)

  ################################################################################
  # WORK
  ################################################################################
  #Create Table & Load Data
  sql <- SqlRender::readSql("./inst/sql/sql_server/cem_source_to_concept_map.sql")

  renderedSql <- SqlRender::render(sql=sql,
                                      stcmTable=stcmTable,
                                      vocabulary=vocabulary,
                                      umlsSchema=umlsSchema,
                                      faers=faers)

  translatedSql <- SqlRender::translate(renderedSql,
                                           targetDialect=Sys.getenv("dbms"))

  DatabaseConnector::executeSql(conn=conn,translatedSql)

  ###########
  # SHERLOCK 1 = Split ;
  ###########
  print("Build Source to Concept Map: Sherlock 1/2 - Select concepts to split (source_code_2)")
  sql <- paste0("
                SELECT DISTINCT
                	SOURCE_CODE_2 AS SOURCE_CODE,
                	0 AS SOURCE_CONCEPT_ID,
                	'SHERLOCK_TO_STANDARD' AS SOURCE_VOCABULARY_ID,
                	SOURCE_CODE_NAME_2 AS SOURCE_CODE_DESCRIPTION,
                	SOURCE_CODE_2 AS TARGET_CONCEPT_ID,
                	NULL AS TARGET_VOCABULARY_ID,
                	CAST('1970-01-01' AS DATE) AS VALID_START_DATE,
                  CAST('2099-12-31' AS DATE) AS VALID_END_DATE,
                  NULL AS INVALID_REASON
                FROM ",sherlock," WHERE SOURCE_CODE_2 LIKE '%,%'
                ")
  renderedSql <- SqlRender::render(sql=sql)
  translatedSql <- SqlRender::translate(renderedSql,
                                        targetDialect=Sys.getenv("dbms"))
  df <- DatabaseConnector::querySql(conn=conn,translatedSql)

  print("Build Source to Concept Map: Sherlock 1/2 - Insert concepts")
  df <- tidyr::separate_rows(df,TARGET_CONCEPT_ID,sep=",\\s+")
  df$TARGET_CONCEPT_ID <- as.integer(df$TARGET_CONCEPT_ID)
  df$TARGET_CONCEPT_ID[is.na(df$TARGET_CONCEPT_ID)] <- as.integer(0)

  # tidyr returns a tibble, which DatabaseConnector can not deal with, so converting it back to a 'classic' data frame.
  frame <- as.data.frame(df)

  DatabaseConnector::insertTable(conn = conn,
                                 tableName = stcmTable,
                                 data = frame,
                                 dropTableIfExists = FALSE,
                                 createTable = FALSE)

  rm(df)
  rm(frame)

  ###########
  # SHERLOCK 2 = Split ,
  ###########
  print("Build Source to Concept Map: Sherlock 2/2 - Select concepts to split (source_code_1)")
  sql <- paste0("
                SELECT DISTINCT
                	SOURCE_CODE_1 AS SOURCE_CODE,
                	0 AS SOURCE_CONCEPT_ID,
                	'SHERLOCK_TO_STANDARD' AS SOURCE_VOCABULARY_ID,
                	SOURCE_CODE_NAME_1 AS SOURCE_CODE_DESCRIPTION,
                	SOURCE_CODE_1 AS TARGET_CONCEPT_ID,
                	NULL AS TARGET_VOCABULARY_ID,
                	CAST('1970-01-01' AS DATE) AS VALID_START_DATE,
                  CAST('2099-12-31' AS DATE) AS VALID_END_DATE,
                  NULL AS INVALID_REASON
                FROM ",sherlock," WHERE SOURCE_CODE_1 LIKE '%,%'
                ")
  renderedSql <- SqlRender::render(sql=sql)
  translatedSql <- SqlRender::translate(renderedSql,
                                        targetDialect=Sys.getenv("dbms"))
  df <- DatabaseConnector::querySql(conn=conn,translatedSql)

  print("Build Source to Concept Map: Sherlock 2/2 - insert concepts")
  df <- tidyr::separate_rows(df,TARGET_CONCEPT_ID,sep=",\\s+")
  df$TARGET_CONCEPT_ID <- as.integer(df$TARGET_CONCEPT_ID)
  df$TARGET_CONCEPT_ID[is.na(df$TARGET_CONCEPT_ID)] <- as.integer(0)

  # tidyr returns a tibble, which DatabaseConnector can not deal with, so converting it back to a 'classic' data frame.
  frame <- as.data.frame(df)

  DatabaseConnector::insertTable(conn = conn,
                                 tableName = stcmTable,
                                 data = frame,
                                 dropTableIfExists = FALSE,
                                 createTable = FALSE,)

  rm(df)
  rm(frame)

  ###########
  # MANUAL WORK
  ###########
  print("Build Source to Concept Map: Load Manual Maps 1/2 - EU PL ADR")
  df <- read.csv("inst/csv/EU_PL_ADR_SUBSTANCES_TO_STANDARD.csv",
                 sep=",",header=TRUE)
  df$valid_start_date <- as.Date(df$valid_start_date)
  df$valid_end_date <- as.Date(df$valid_end_date)
  DatabaseConnector::insertTable(conn,stcmTable,df,
                                 dropTableIfExists = FALSE, createTable = FALSE)
  rm(df)

  print("Build Source to Concept Map: Load Manual Maps 2/2 - Trifiro Conditions" )
  df <- read.csv("inst/csv/TRIFIRO_23_CONDITIONS_STCM.csv",
                 sep=",",header=TRUE)
  df$valid_start_date <- as.Date(df$valid_start_date)
  df$valid_end_date <- as.Date(df$valid_end_date)
  DatabaseConnector::insertTable(conn,stcmTable,df,
                                 dropTableIfExists = FALSE, createTable = FALSE)
  ################################################################################
  # CLEAN
  ################################################################################
  rm(df)
  DatabaseConnector::disconnect(conn)
  }
