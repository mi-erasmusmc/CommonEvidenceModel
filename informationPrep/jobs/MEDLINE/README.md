MEDLINE staging data load process
===================================

Background
----------
This is the MEDLINE staging data load process.

The ETL job downloads the source data files from the following ftp sites:

[PUBMED ftp site](ftp://ftp.ncbi.nlm.gov/pubmed)
[MESH ftp site](ftp://nlmpubs.nlm.nih.gov)

Table(s) loaded
---------------
staging_medline tables

Dependencies
------------

1. Java JDK (e.g. openjdk).
2. MedlineXmlToDatabase java executable and lib - see the below GitHub repo for installation and usage details:

[MedlineXMLToDatabase GitHub repository](https://github.com/OHDSI/MedlineXmlToDatabase)

Notes:
- The .ini file required for running the app is created in the `load_medline.sh` script. It is based on the variables in
  the secret.config file. If the required ini configurations have been updated please update the script.
- At the time of writing the staging_medline schema is about 134 GB in size it is likely to continue growing rapidly, be
  sure to have sufficient disk space available

Instructions
------------

1. Place the MedlineXmlToDatabase.jar and MedlineXmlToDatabase_lib folder in this directory. \
2. Brace yourself for a long wait (over a week)...
3. Run the `load_medline.sh` script
