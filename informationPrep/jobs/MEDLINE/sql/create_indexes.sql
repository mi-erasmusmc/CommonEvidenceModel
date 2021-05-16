set search_path = staging_medline;

CREATE INDEX idx_medcit_meshheadinglist_meshheading_descriptorname_ui ON medcit_meshheadinglist_meshheading (descriptorname_ui);
CREATE INDEX idx_medcit_supplmeshlist_supplmeshname_ui ON medcit_supplmeshlist_supplmeshname (ui);
CREATE INDEX idx_mesh_term_ui ON mesh_term (ui);
CREATE INDEX idx_mesh_relationship_ui_1 ON mesh_relationship (ui_1);
CREATE INDEX idx_mesh_relationship_ui_2 ON mesh_relationship (ui_2);
CREATE INDEX idx_mesh_ancestor_ancestor_ui ON mesh_ancestor (ancestor_ui);
CREATE INDEX idx_mesh_ancestor_descendant_ui ON mesh_ancestor (descendant_ui);


ANALYZE medcit;
ANALYZE medcit_art_abstract_abstracttext;
ANALYZE medcit_art_authorlist_author;
ANALYZE medcit_art_authorlist_author_affiliationinfo;
ANALYZE medcit_art_authorlist_author_affiliationinfo_identifier;
ANALYZE medcit_art_authorlist_author_identifier;
ANALYZE medcit_art_dblist_db;
ANALYZE medcit_art_dblist_db_accessionnumberlist_accessionnumber;
ANALYZE medcit_art_elocationid;
ANALYZE medcit_art_grantlist_grant;
ANALYZE medcit_art_language;
ANALYZE medcit_art_publicationtypelist_publicationtype;
ANALYZE medcit_chemicallist_chemical;
ANALYZE medcit_citationsubset;
ANALYZE medcit_commentscorrectionslist_commentscorrections;
ANALYZE medcit_generalnote;
ANALYZE medcit_genesymbollist_genesymbol;
ANALYZE medcit_investigatorlist_investigator;
ANALYZE medcit_investigatorlist_investigator_affiliationinfo;
ANALYZE medcit_keywordlist;
ANALYZE medcit_keywordlist_keyword;
ANALYZE medcit_meshheadinglist_meshheading;
ANALYZE medcit_meshheadinglist_meshheading_qualifiername;
ANALYZE medcit_otherabstract;
ANALYZE medcit_otherabstract_abstracttext;
ANALYZE medcit_otherid;
ANALYZE medcit_personalnamesubjectlist_personalnamesubject;
ANALYZE medcit_spaceflightmission;
ANALYZE medcit_supplmeshlist_supplmeshname;
ANALYZE mesh_ancestor;
ANALYZE mesh_relationship;
ANALYZE mesh_term;
ANALYZE pmid_to_date;