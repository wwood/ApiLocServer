--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: annotations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE annotations (
    id integer NOT NULL,
    coding_region_id integer,
    annotation text DEFAULT NULL::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: binary_coding_region_measurements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE binary_coding_region_measurements (
    id integer NOT NULL,
    coding_region_id integer NOT NULL,
    value boolean,
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: brafl_upstream_distances; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE brafl_upstream_distances (
    id integer NOT NULL,
    go_term_id integer NOT NULL,
    upstream_distance integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    coding_region_id integer
);


--
-- Name: cds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cds (
    id integer NOT NULL,
    coding_region_id integer NOT NULL,
    start integer NOT NULL,
    stop integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: cluster_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cluster_entries (
    id integer NOT NULL,
    coding_region_id integer,
    cluster_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: clusters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clusters (
    id integer NOT NULL,
    clusterset_id integer,
    published_number integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: clustersets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clustersets (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: coding_region_alternate_string_ids; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_alternate_string_ids (
    id integer NOT NULL,
    coding_region_id integer,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: coding_region_drosophila_allele_genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_drosophila_allele_genes (
    id integer NOT NULL,
    coding_region_id integer NOT NULL,
    drosophila_allele_gene_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: coding_region_go_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_go_terms (
    id integer NOT NULL,
    coding_region_id integer,
    go_term_id integer
);


--
-- Name: coding_region_localisations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_localisations (
    id integer NOT NULL,
    coding_region_id integer NOT NULL,
    localisation_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    localisation_method_id integer NOT NULL
);


--
-- Name: coding_region_mouse_phenotype_informations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_mouse_phenotype_informations (
    id integer NOT NULL,
    coding_region_id integer,
    mouse_phenotype_information_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: coding_region_network_edges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_network_edges (
    id integer NOT NULL,
    network_id integer NOT NULL,
    "integer" integer NOT NULL,
    coding_region_id_first integer NOT NULL,
    coding_region_id_second integer NOT NULL,
    strength numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: coding_region_phenotype_informations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_phenotype_informations (
    id integer NOT NULL,
    coding_region_id integer,
    phenotype_information_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: coding_region_phenotype_observeds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_phenotype_observeds (
    id integer NOT NULL,
    coding_region_id integer,
    phenotype_observed_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: coding_region_yeast_pheno_infos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_yeast_pheno_infos (
    id integer NOT NULL,
    coding_region_id integer NOT NULL,
    yeast_pheno_info_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: coding_regions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_regions (
    id integer NOT NULL,
    gene_id integer,
    jgi_protein_id integer,
    upstream_distance integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    string_id character varying(255),
    orientation character varying(255)
);


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE comments (
    id integer NOT NULL,
    expression_context_id integer NOT NULL,
    comment character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: derisi20063d7logmean; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE derisi20063d7logmean (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: developmental_stage_synonyms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE developmental_stage_synonyms (
    id integer NOT NULL,
    developmental_stage_id integer,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: developmental_stages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE developmental_stages (
    id integer NOT NULL,
    type character varying(255) DEFAULT NULL::character varying,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: drosophila_allele_genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE drosophila_allele_genes (
    id integer NOT NULL,
    allele character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: drosophila_allele_phenotype_drosophila_allele_genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE drosophila_allele_phenotype_drosophila_allele_genes (
    id integer NOT NULL,
    drosophila_allele_gene_id integer NOT NULL,
    drosophila_allele_phenotype_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: drosophila_allele_phenotypes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE drosophila_allele_phenotypes (
    id integer NOT NULL,
    phenotype character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: expression_contexts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE expression_contexts (
    id integer NOT NULL,
    coding_region_id integer NOT NULL,
    publication_id integer,
    localisation_id integer,
    developmental_stage_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: float_coding_region_measurements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE float_coding_region_measurements (
    id integer NOT NULL,
    type character varying(255),
    coding_region_id integer,
    value double precision,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: gene_alternate_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gene_alternate_names (
    id integer NOT NULL,
    gene_id integer,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: gene_network_edges; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gene_network_edges (
    id integer NOT NULL,
    gene_network_id integer NOT NULL,
    gene_id_first integer NOT NULL,
    gene_id_second integer NOT NULL,
    strength numeric,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: gene_networks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gene_networks (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: generic_go_maps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE generic_go_maps (
    id integer NOT NULL,
    child_id integer,
    parent_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genes (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scaffold_id integer
);


--
-- Name: go_alternates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_alternates (
    id integer NOT NULL,
    go_identifier character varying(255) DEFAULT NULL::character varying,
    go_term_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: go_list_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_list_entries (
    id integer NOT NULL,
    go_list_id integer,
    go_term_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: go_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_lists (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: go_map_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_map_entries (
    id integer NOT NULL,
    go_map_id integer,
    parent_id integer,
    child_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: go_maps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_maps (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: go_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_terms (
    id integer NOT NULL,
    go_identifier character varying(255) DEFAULT NULL::character varying,
    term character varying(255) DEFAULT NULL::character varying,
    aspect character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: gus; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gus (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: integer_coding_region_measurements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE integer_coding_region_measurements (
    id integer NOT NULL,
    type character varying(255),
    coding_region_id integer,
    value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: localisation_methods; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE localisation_methods (
    id integer NOT NULL,
    description character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: localisation_synonyms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE localisation_synonyms (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    localisation_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: localisation_top_level_localisations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE localisation_top_level_localisations (
    id integer NOT NULL,
    localisation_id integer,
    top_level_localisation_id integer,
    type character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: localisations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE localisations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: microarray_measurements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE microarray_measurements (
    id integer NOT NULL,
    microarray_timepoint_id integer NOT NULL,
    measurement numeric NOT NULL,
    coding_region_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: microarray_timepoints; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE microarray_timepoints (
    id integer NOT NULL,
    microarray_id integer,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: microarrays; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE microarrays (
    id integer NOT NULL,
    description character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mouse_pheno_descs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mouse_pheno_descs (
    id integer NOT NULL,
    pheno_id character varying(255) NOT NULL,
    pheno_desc character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mouse_phenotype_informations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mouse_phenotype_informations (
    id integer NOT NULL,
    mgi_allele character varying(255) NOT NULL,
    allele_type character varying(255) DEFAULT NULL::character varying,
    mgi_marker character varying(255) DEFAULT NULL::character varying,
    mouse_pheno_desc_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: mverifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE mverifications (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: networks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE networks (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: orthomcl_gene_coding_regions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orthomcl_gene_coding_regions (
    id integer NOT NULL,
    coding_region_id integer,
    orthomcl_gene_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: orthomcl_gene_official_datas; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orthomcl_gene_official_datas (
    id integer NOT NULL,
    orthomcl_gene_id integer,
    sequence text,
    annotation text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: orthomcl_genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orthomcl_genes (
    id integer NOT NULL,
    orthomcl_name character varying(255) DEFAULT NULL::character varying,
    orthomcl_group_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: orthomcl_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orthomcl_groups (
    id integer NOT NULL,
    orthomcl_name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    orthomcl_run_id integer NOT NULL
);


--
-- Name: orthomcl_runs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orthomcl_runs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: phenotype_informations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE phenotype_informations (
    id integer NOT NULL,
    dbxref character varying(255) DEFAULT NULL::character varying,
    phenotype character varying(255) DEFAULT NULL::character varying,
    experiments integer,
    "primary" integer,
    specific integer,
    observed integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: phenotype_observeds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE phenotype_observeds (
    id integer NOT NULL,
    dbxref character varying(255) DEFAULT NULL::character varying,
    phenotype character varying(255) DEFAULT NULL::character varying,
    experiments integer,
    "primary" integer,
    specific integer,
    observed integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: plasmo_db_gene_list_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE plasmo_db_gene_list_entries (
    id integer NOT NULL,
    plasmo_db_gene_list_id integer,
    gene_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: plasmodb_gene_list_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE plasmodb_gene_list_entries (
    id integer NOT NULL,
    plasmodb_gene_list_id integer,
    coding_region_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: plasmodb_gene_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE plasmodb_gene_lists (
    id integer NOT NULL,
    description character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: probe_map_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE probe_map_entries (
    id integer NOT NULL,
    probe_map_id integer NOT NULL,
    probe_id integer NOT NULL,
    coding_region_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: probe_maps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE probe_maps (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: publications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE publications (
    id integer NOT NULL,
    pubmed_id integer,
    url character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: scaffolds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scaffolds (
    id integer NOT NULL,
    species_id integer,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: scripts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scripts (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: sequences; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sequences (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    coding_region_id integer NOT NULL,
    sequence text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: signal_ps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE signal_ps (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: species; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE species (
    id integer NOT NULL,
    name character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    orthomcl_three_letter character varying(255)
);


--
-- Name: taxon_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_names (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: taxons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxons (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: top_level_localisations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE top_level_localisations (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: transmembrane_domain_measurements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transmembrane_domain_measurements (
    id integer NOT NULL,
    coding_region_id integer,
    measurement numeric NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    type character varying(255) DEFAULT 'MinTransmembraneDomainLength'::character varying NOT NULL
);


--
-- Name: transmembrane_domains; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE transmembrane_domains (
    id integer NOT NULL,
    coding_region_id integer NOT NULL,
    start integer NOT NULL,
    stop integer NOT NULL,
    type character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: verifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE verifications (
    id integer NOT NULL
);


--
-- Name: yeast_pheno_infos; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE yeast_pheno_infos (
    id integer NOT NULL,
    experiment_type character varying(255) NOT NULL,
    phenotype character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE annotations_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE annotations_id_seq OWNED BY annotations.id;


--
-- Name: binary_coding_region_measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE binary_coding_region_measurements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: binary_coding_region_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE binary_coding_region_measurements_id_seq OWNED BY binary_coding_region_measurements.id;


--
-- Name: brafl_upstream_distances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brafl_upstream_distances_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: brafl_upstream_distances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brafl_upstream_distances_id_seq OWNED BY brafl_upstream_distances.id;


--
-- Name: cds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cds_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: cds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cds_id_seq OWNED BY cds.id;


--
-- Name: cluster_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cluster_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: cluster_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cluster_entries_id_seq OWNED BY cluster_entries.id;


--
-- Name: clusters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clusters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: clusters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clusters_id_seq OWNED BY clusters.id;


--
-- Name: clustersets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clustersets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: clustersets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clustersets_id_seq OWNED BY clustersets.id;


--
-- Name: coding_region_alternate_string_ids_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_region_alternate_string_ids_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_region_alternate_string_ids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_region_alternate_string_ids_id_seq OWNED BY coding_region_alternate_string_ids.id;


--
-- Name: coding_region_drosophila_allele_genes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_region_drosophila_allele_genes_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_region_drosophila_allele_genes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_region_drosophila_allele_genes_id_seq OWNED BY coding_region_drosophila_allele_genes.id;


--
-- Name: coding_region_go_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_region_go_terms_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_region_go_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_region_go_terms_id_seq OWNED BY coding_region_go_terms.id;


--
-- Name: coding_region_localisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_region_localisations_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_region_localisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_region_localisations_id_seq OWNED BY coding_region_localisations.id;


--
-- Name: coding_region_mouse_phenotype_informations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_region_mouse_phenotype_informations_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_region_mouse_phenotype_informations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_region_mouse_phenotype_informations_id_seq OWNED BY coding_region_mouse_phenotype_informations.id;


--
-- Name: coding_region_network_edges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_region_network_edges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_region_network_edges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_region_network_edges_id_seq OWNED BY coding_region_network_edges.id;


--
-- Name: coding_region_phenotype_informations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_region_phenotype_informations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_region_phenotype_informations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_region_phenotype_informations_id_seq OWNED BY coding_region_phenotype_informations.id;


--
-- Name: coding_region_phenotype_observeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_region_phenotype_observeds_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_region_phenotype_observeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_region_phenotype_observeds_id_seq OWNED BY coding_region_phenotype_observeds.id;


--
-- Name: coding_region_yeast_pheno_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_region_yeast_pheno_infos_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_region_yeast_pheno_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_region_yeast_pheno_infos_id_seq OWNED BY coding_region_yeast_pheno_infos.id;


--
-- Name: coding_regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE coding_regions_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: coding_regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE coding_regions_id_seq OWNED BY coding_regions.id;


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- Name: derisi20063d7logmean_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE derisi20063d7logmean_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: derisi20063d7logmean_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE derisi20063d7logmean_id_seq OWNED BY derisi20063d7logmean.id;


--
-- Name: developmental_stage_synonyms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE developmental_stage_synonyms_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: developmental_stage_synonyms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE developmental_stage_synonyms_id_seq OWNED BY developmental_stage_synonyms.id;


--
-- Name: developmental_stages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE developmental_stages_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: developmental_stages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE developmental_stages_id_seq OWNED BY developmental_stages.id;


--
-- Name: drosophila_allele_genes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE drosophila_allele_genes_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: drosophila_allele_genes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE drosophila_allele_genes_id_seq OWNED BY drosophila_allele_genes.id;


--
-- Name: drosophila_allele_phenotype_drosophila_allele_genes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE drosophila_allele_phenotype_drosophila_allele_genes_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: drosophila_allele_phenotype_drosophila_allele_genes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE drosophila_allele_phenotype_drosophila_allele_genes_id_seq OWNED BY drosophila_allele_phenotype_drosophila_allele_genes.id;


--
-- Name: drosophila_allele_phenotypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE drosophila_allele_phenotypes_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: drosophila_allele_phenotypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE drosophila_allele_phenotypes_id_seq OWNED BY drosophila_allele_phenotypes.id;


--
-- Name: expression_contexts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE expression_contexts_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: expression_contexts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE expression_contexts_id_seq OWNED BY expression_contexts.id;


--
-- Name: float_coding_region_measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE float_coding_region_measurements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: float_coding_region_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE float_coding_region_measurements_id_seq OWNED BY float_coding_region_measurements.id;


--
-- Name: gene_alternate_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gene_alternate_names_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: gene_alternate_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gene_alternate_names_id_seq OWNED BY gene_alternate_names.id;


--
-- Name: gene_network_edges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gene_network_edges_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: gene_network_edges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gene_network_edges_id_seq OWNED BY gene_network_edges.id;


--
-- Name: gene_networks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gene_networks_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: gene_networks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gene_networks_id_seq OWNED BY gene_networks.id;


--
-- Name: generic_go_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE generic_go_maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: generic_go_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE generic_go_maps_id_seq OWNED BY generic_go_maps.id;


--
-- Name: genes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE genes_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: genes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE genes_id_seq OWNED BY genes.id;


--
-- Name: go_alternates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE go_alternates_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: go_alternates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE go_alternates_id_seq OWNED BY go_alternates.id;


--
-- Name: go_list_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE go_list_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: go_list_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE go_list_entries_id_seq OWNED BY go_list_entries.id;


--
-- Name: go_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE go_lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: go_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE go_lists_id_seq OWNED BY go_lists.id;


--
-- Name: go_map_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE go_map_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: go_map_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE go_map_entries_id_seq OWNED BY go_map_entries.id;


--
-- Name: go_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE go_maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: go_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE go_maps_id_seq OWNED BY go_maps.id;


--
-- Name: go_terms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE go_terms_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: go_terms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE go_terms_id_seq OWNED BY go_terms.id;


--
-- Name: gus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: gus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gus_id_seq OWNED BY gus.id;


--
-- Name: integer_coding_region_measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE integer_coding_region_measurements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: integer_coding_region_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE integer_coding_region_measurements_id_seq OWNED BY integer_coding_region_measurements.id;


--
-- Name: localisation_methods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE localisation_methods_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: localisation_methods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE localisation_methods_id_seq OWNED BY localisation_methods.id;


--
-- Name: localisation_synonyms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE localisation_synonyms_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: localisation_synonyms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE localisation_synonyms_id_seq OWNED BY localisation_synonyms.id;


--
-- Name: localisation_top_level_localisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE localisation_top_level_localisations_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: localisation_top_level_localisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE localisation_top_level_localisations_id_seq OWNED BY localisation_top_level_localisations.id;


--
-- Name: localisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE localisations_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: localisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE localisations_id_seq OWNED BY localisations.id;


--
-- Name: microarray_measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE microarray_measurements_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: microarray_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE microarray_measurements_id_seq OWNED BY microarray_measurements.id;


--
-- Name: microarray_timepoints_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE microarray_timepoints_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: microarray_timepoints_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE microarray_timepoints_id_seq OWNED BY microarray_timepoints.id;


--
-- Name: microarrays_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE microarrays_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: microarrays_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE microarrays_id_seq OWNED BY microarrays.id;


--
-- Name: min_transmembrane_domain_lengths_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE min_transmembrane_domain_lengths_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: min_transmembrane_domain_lengths_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE min_transmembrane_domain_lengths_id_seq OWNED BY transmembrane_domain_measurements.id;


--
-- Name: mouse_pheno_descs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mouse_pheno_descs_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: mouse_pheno_descs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mouse_pheno_descs_id_seq OWNED BY mouse_pheno_descs.id;


--
-- Name: mouse_phenotype_informations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mouse_phenotype_informations_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: mouse_phenotype_informations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mouse_phenotype_informations_id_seq OWNED BY mouse_phenotype_informations.id;


--
-- Name: mverifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE mverifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: mverifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE mverifications_id_seq OWNED BY mverifications.id;


--
-- Name: networks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE networks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: networks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE networks_id_seq OWNED BY networks.id;


--
-- Name: orthomcl_gene_coding_regions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orthomcl_gene_coding_regions_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: orthomcl_gene_coding_regions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orthomcl_gene_coding_regions_id_seq OWNED BY orthomcl_gene_coding_regions.id;


--
-- Name: orthomcl_gene_official_datas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orthomcl_gene_official_datas_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: orthomcl_gene_official_datas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orthomcl_gene_official_datas_id_seq OWNED BY orthomcl_gene_official_datas.id;


--
-- Name: orthomcl_genes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orthomcl_genes_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: orthomcl_genes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orthomcl_genes_id_seq OWNED BY orthomcl_genes.id;


--
-- Name: orthomcl_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orthomcl_groups_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: orthomcl_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orthomcl_groups_id_seq OWNED BY orthomcl_groups.id;


--
-- Name: orthomcl_runs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orthomcl_runs_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: orthomcl_runs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orthomcl_runs_id_seq OWNED BY orthomcl_runs.id;


--
-- Name: phenotype_informations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE phenotype_informations_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: phenotype_informations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phenotype_informations_id_seq OWNED BY phenotype_informations.id;


--
-- Name: phenotype_observeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE phenotype_observeds_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: phenotype_observeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE phenotype_observeds_id_seq OWNED BY phenotype_observeds.id;


--
-- Name: plasmo_db_gene_list_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE plasmo_db_gene_list_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: plasmo_db_gene_list_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE plasmo_db_gene_list_entries_id_seq OWNED BY plasmo_db_gene_list_entries.id;


--
-- Name: plasmodb_gene_list_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE plasmodb_gene_list_entries_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: plasmodb_gene_list_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE plasmodb_gene_list_entries_id_seq OWNED BY plasmodb_gene_list_entries.id;


--
-- Name: plasmodb_gene_lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE plasmodb_gene_lists_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: plasmodb_gene_lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE plasmodb_gene_lists_id_seq OWNED BY plasmodb_gene_lists.id;


--
-- Name: probe_map_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE probe_map_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: probe_map_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE probe_map_entries_id_seq OWNED BY probe_map_entries.id;


--
-- Name: probe_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE probe_maps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: probe_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE probe_maps_id_seq OWNED BY probe_maps.id;


--
-- Name: publications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE publications_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: publications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE publications_id_seq OWNED BY publications.id;


--
-- Name: scaffolds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scaffolds_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: scaffolds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scaffolds_id_seq OWNED BY scaffolds.id;


--
-- Name: scripts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE scripts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: scripts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE scripts_id_seq OWNED BY scripts.id;


--
-- Name: sequences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sequences_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: sequences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sequences_id_seq OWNED BY sequences.id;


--
-- Name: signal_ps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE signal_ps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: signal_ps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE signal_ps_id_seq OWNED BY signal_ps.id;


--
-- Name: species_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE species_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: species_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE species_id_seq OWNED BY species.id;


--
-- Name: taxon_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxon_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: taxon_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxon_names_id_seq OWNED BY taxon_names.id;


--
-- Name: taxons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taxons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: taxons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taxons_id_seq OWNED BY taxons.id;


--
-- Name: top_level_localisations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE top_level_localisations_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: top_level_localisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE top_level_localisations_id_seq OWNED BY top_level_localisations.id;


--
-- Name: transmembrane_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transmembrane_domains_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: transmembrane_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transmembrane_domains_id_seq OWNED BY transmembrane_domains.id;


--
-- Name: verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE verifications_id_seq OWNED BY verifications.id;


--
-- Name: yeast_pheno_infos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE yeast_pheno_infos_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: yeast_pheno_infos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE yeast_pheno_infos_id_seq OWNED BY yeast_pheno_infos.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE annotations ALTER COLUMN id SET DEFAULT nextval('annotations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE binary_coding_region_measurements ALTER COLUMN id SET DEFAULT nextval('binary_coding_region_measurements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE brafl_upstream_distances ALTER COLUMN id SET DEFAULT nextval('brafl_upstream_distances_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE cds ALTER COLUMN id SET DEFAULT nextval('cds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE cluster_entries ALTER COLUMN id SET DEFAULT nextval('cluster_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE clusters ALTER COLUMN id SET DEFAULT nextval('clusters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE clustersets ALTER COLUMN id SET DEFAULT nextval('clustersets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_alternate_string_ids ALTER COLUMN id SET DEFAULT nextval('coding_region_alternate_string_ids_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_drosophila_allele_genes ALTER COLUMN id SET DEFAULT nextval('coding_region_drosophila_allele_genes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_go_terms ALTER COLUMN id SET DEFAULT nextval('coding_region_go_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_localisations ALTER COLUMN id SET DEFAULT nextval('coding_region_localisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_mouse_phenotype_informations ALTER COLUMN id SET DEFAULT nextval('coding_region_mouse_phenotype_informations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_network_edges ALTER COLUMN id SET DEFAULT nextval('coding_region_network_edges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_phenotype_informations ALTER COLUMN id SET DEFAULT nextval('coding_region_phenotype_informations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_phenotype_observeds ALTER COLUMN id SET DEFAULT nextval('coding_region_phenotype_observeds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_yeast_pheno_infos ALTER COLUMN id SET DEFAULT nextval('coding_region_yeast_pheno_infos_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_regions ALTER COLUMN id SET DEFAULT nextval('coding_regions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE derisi20063d7logmean ALTER COLUMN id SET DEFAULT nextval('derisi20063d7logmean_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE developmental_stage_synonyms ALTER COLUMN id SET DEFAULT nextval('developmental_stage_synonyms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE developmental_stages ALTER COLUMN id SET DEFAULT nextval('developmental_stages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE drosophila_allele_genes ALTER COLUMN id SET DEFAULT nextval('drosophila_allele_genes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE drosophila_allele_phenotype_drosophila_allele_genes ALTER COLUMN id SET DEFAULT nextval('drosophila_allele_phenotype_drosophila_allele_genes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE drosophila_allele_phenotypes ALTER COLUMN id SET DEFAULT nextval('drosophila_allele_phenotypes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE expression_contexts ALTER COLUMN id SET DEFAULT nextval('expression_contexts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE float_coding_region_measurements ALTER COLUMN id SET DEFAULT nextval('float_coding_region_measurements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE gene_alternate_names ALTER COLUMN id SET DEFAULT nextval('gene_alternate_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE gene_network_edges ALTER COLUMN id SET DEFAULT nextval('gene_network_edges_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE gene_networks ALTER COLUMN id SET DEFAULT nextval('gene_networks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE generic_go_maps ALTER COLUMN id SET DEFAULT nextval('generic_go_maps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE genes ALTER COLUMN id SET DEFAULT nextval('genes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE go_alternates ALTER COLUMN id SET DEFAULT nextval('go_alternates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE go_list_entries ALTER COLUMN id SET DEFAULT nextval('go_list_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE go_lists ALTER COLUMN id SET DEFAULT nextval('go_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE go_map_entries ALTER COLUMN id SET DEFAULT nextval('go_map_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE go_maps ALTER COLUMN id SET DEFAULT nextval('go_maps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE go_terms ALTER COLUMN id SET DEFAULT nextval('go_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE gus ALTER COLUMN id SET DEFAULT nextval('gus_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE integer_coding_region_measurements ALTER COLUMN id SET DEFAULT nextval('integer_coding_region_measurements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE localisation_methods ALTER COLUMN id SET DEFAULT nextval('localisation_methods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE localisation_synonyms ALTER COLUMN id SET DEFAULT nextval('localisation_synonyms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE localisation_top_level_localisations ALTER COLUMN id SET DEFAULT nextval('localisation_top_level_localisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE localisations ALTER COLUMN id SET DEFAULT nextval('localisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE microarray_measurements ALTER COLUMN id SET DEFAULT nextval('microarray_measurements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE microarray_timepoints ALTER COLUMN id SET DEFAULT nextval('microarray_timepoints_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE microarrays ALTER COLUMN id SET DEFAULT nextval('microarrays_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE mouse_pheno_descs ALTER COLUMN id SET DEFAULT nextval('mouse_pheno_descs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE mouse_phenotype_informations ALTER COLUMN id SET DEFAULT nextval('mouse_phenotype_informations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE mverifications ALTER COLUMN id SET DEFAULT nextval('mverifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE networks ALTER COLUMN id SET DEFAULT nextval('networks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE orthomcl_gene_coding_regions ALTER COLUMN id SET DEFAULT nextval('orthomcl_gene_coding_regions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE orthomcl_gene_official_datas ALTER COLUMN id SET DEFAULT nextval('orthomcl_gene_official_datas_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE orthomcl_genes ALTER COLUMN id SET DEFAULT nextval('orthomcl_genes_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE orthomcl_groups ALTER COLUMN id SET DEFAULT nextval('orthomcl_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE orthomcl_runs ALTER COLUMN id SET DEFAULT nextval('orthomcl_runs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE phenotype_informations ALTER COLUMN id SET DEFAULT nextval('phenotype_informations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE phenotype_observeds ALTER COLUMN id SET DEFAULT nextval('phenotype_observeds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE plasmo_db_gene_list_entries ALTER COLUMN id SET DEFAULT nextval('plasmo_db_gene_list_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE plasmodb_gene_list_entries ALTER COLUMN id SET DEFAULT nextval('plasmodb_gene_list_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE plasmodb_gene_lists ALTER COLUMN id SET DEFAULT nextval('plasmodb_gene_lists_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE probe_map_entries ALTER COLUMN id SET DEFAULT nextval('probe_map_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE probe_maps ALTER COLUMN id SET DEFAULT nextval('probe_maps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE publications ALTER COLUMN id SET DEFAULT nextval('publications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE scaffolds ALTER COLUMN id SET DEFAULT nextval('scaffolds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE scripts ALTER COLUMN id SET DEFAULT nextval('scripts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE sequences ALTER COLUMN id SET DEFAULT nextval('sequences_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE signal_ps ALTER COLUMN id SET DEFAULT nextval('signal_ps_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE species ALTER COLUMN id SET DEFAULT nextval('species_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE taxon_names ALTER COLUMN id SET DEFAULT nextval('taxon_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE taxons ALTER COLUMN id SET DEFAULT nextval('taxons_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE top_level_localisations ALTER COLUMN id SET DEFAULT nextval('top_level_localisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE transmembrane_domain_measurements ALTER COLUMN id SET DEFAULT nextval('min_transmembrane_domain_lengths_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE transmembrane_domains ALTER COLUMN id SET DEFAULT nextval('transmembrane_domains_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE verifications ALTER COLUMN id SET DEFAULT nextval('verifications_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE yeast_pheno_infos ALTER COLUMN id SET DEFAULT nextval('yeast_pheno_infos_id_seq'::regclass);


--
-- Name: annotations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY annotations
    ADD CONSTRAINT annotations_pkey PRIMARY KEY (id);


--
-- Name: binary_coding_region_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY binary_coding_region_measurements
    ADD CONSTRAINT binary_coding_region_measurements_pkey PRIMARY KEY (id);


--
-- Name: brafl_upstream_distances_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY brafl_upstream_distances
    ADD CONSTRAINT brafl_upstream_distances_pkey PRIMARY KEY (id);


--
-- Name: cds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cds
    ADD CONSTRAINT cds_pkey PRIMARY KEY (id);


--
-- Name: cluster_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cluster_entries
    ADD CONSTRAINT cluster_entries_pkey PRIMARY KEY (id);


--
-- Name: clusters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clusters
    ADD CONSTRAINT clusters_pkey PRIMARY KEY (id);


--
-- Name: clustersets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY clustersets
    ADD CONSTRAINT clustersets_pkey PRIMARY KEY (id);


--
-- Name: coding_region_alternate_string_ids_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_region_alternate_string_ids
    ADD CONSTRAINT coding_region_alternate_string_ids_pkey PRIMARY KEY (id);


--
-- Name: coding_region_drosophila_allele_genes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_region_drosophila_allele_genes
    ADD CONSTRAINT coding_region_drosophila_allele_genes_pkey PRIMARY KEY (id);


--
-- Name: coding_region_go_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_region_go_terms
    ADD CONSTRAINT coding_region_go_terms_pkey PRIMARY KEY (id);


--
-- Name: coding_region_localisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_region_localisations
    ADD CONSTRAINT coding_region_localisations_pkey PRIMARY KEY (id);


--
-- Name: coding_region_mouse_phenotype_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_region_mouse_phenotype_informations
    ADD CONSTRAINT coding_region_mouse_phenotype_informations_pkey PRIMARY KEY (id);


--
-- Name: coding_region_network_edges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_region_network_edges
    ADD CONSTRAINT coding_region_network_edges_pkey PRIMARY KEY (id);


--
-- Name: coding_region_phenotype_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_region_phenotype_informations
    ADD CONSTRAINT coding_region_phenotype_informations_pkey PRIMARY KEY (id);


--
-- Name: coding_region_phenotype_observeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_region_phenotype_observeds
    ADD CONSTRAINT coding_region_phenotype_observeds_pkey PRIMARY KEY (id);


--
-- Name: coding_region_yeast_pheno_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_region_yeast_pheno_infos
    ADD CONSTRAINT coding_region_yeast_pheno_infos_pkey PRIMARY KEY (id);


--
-- Name: coding_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_regions
    ADD CONSTRAINT coding_regions_pkey PRIMARY KEY (id);


--
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: derisi20063d7logmean_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY derisi20063d7logmean
    ADD CONSTRAINT derisi20063d7logmean_pkey PRIMARY KEY (id);


--
-- Name: developmental_stage_synonyms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY developmental_stage_synonyms
    ADD CONSTRAINT developmental_stage_synonyms_pkey PRIMARY KEY (id);


--
-- Name: developmental_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY developmental_stages
    ADD CONSTRAINT developmental_stages_pkey PRIMARY KEY (id);


--
-- Name: drosophila_allele_genes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY drosophila_allele_genes
    ADD CONSTRAINT drosophila_allele_genes_pkey PRIMARY KEY (id);


--
-- Name: drosophila_allele_phenotype_drosophila_allele_genes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY drosophila_allele_phenotype_drosophila_allele_genes
    ADD CONSTRAINT drosophila_allele_phenotype_drosophila_allele_genes_pkey PRIMARY KEY (id);


--
-- Name: drosophila_allele_phenotypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY drosophila_allele_phenotypes
    ADD CONSTRAINT drosophila_allele_phenotypes_pkey PRIMARY KEY (id);


--
-- Name: expression_contexts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY expression_contexts
    ADD CONSTRAINT expression_contexts_pkey PRIMARY KEY (id);


--
-- Name: float_coding_region_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY float_coding_region_measurements
    ADD CONSTRAINT float_coding_region_measurements_pkey PRIMARY KEY (id);


--
-- Name: gene_alternate_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gene_alternate_names
    ADD CONSTRAINT gene_alternate_names_pkey PRIMARY KEY (id);


--
-- Name: gene_network_edges_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gene_network_edges
    ADD CONSTRAINT gene_network_edges_pkey PRIMARY KEY (id);


--
-- Name: gene_networks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gene_networks
    ADD CONSTRAINT gene_networks_pkey PRIMARY KEY (id);


--
-- Name: generic_go_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY generic_go_maps
    ADD CONSTRAINT generic_go_maps_pkey PRIMARY KEY (id);


--
-- Name: genes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY genes
    ADD CONSTRAINT genes_pkey PRIMARY KEY (id);


--
-- Name: go_alternates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY go_alternates
    ADD CONSTRAINT go_alternates_pkey PRIMARY KEY (id);


--
-- Name: go_list_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY go_list_entries
    ADD CONSTRAINT go_list_entries_pkey PRIMARY KEY (id);


--
-- Name: go_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY go_lists
    ADD CONSTRAINT go_lists_pkey PRIMARY KEY (id);


--
-- Name: go_map_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY go_map_entries
    ADD CONSTRAINT go_map_entries_pkey PRIMARY KEY (id);


--
-- Name: go_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY go_maps
    ADD CONSTRAINT go_maps_pkey PRIMARY KEY (id);


--
-- Name: go_terms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY go_terms
    ADD CONSTRAINT go_terms_pkey PRIMARY KEY (id);


--
-- Name: gus_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY gus
    ADD CONSTRAINT gus_pkey PRIMARY KEY (id);


--
-- Name: integer_coding_region_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY integer_coding_region_measurements
    ADD CONSTRAINT integer_coding_region_measurements_pkey PRIMARY KEY (id);


--
-- Name: localisation_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY localisation_methods
    ADD CONSTRAINT localisation_methods_pkey PRIMARY KEY (id);


--
-- Name: localisation_synonyms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY localisation_synonyms
    ADD CONSTRAINT localisation_synonyms_pkey PRIMARY KEY (id);


--
-- Name: localisation_top_level_localisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY localisation_top_level_localisations
    ADD CONSTRAINT localisation_top_level_localisations_pkey PRIMARY KEY (id);


--
-- Name: localisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY localisations
    ADD CONSTRAINT localisations_pkey PRIMARY KEY (id);


--
-- Name: microarray_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY microarray_measurements
    ADD CONSTRAINT microarray_measurements_pkey PRIMARY KEY (id);


--
-- Name: microarray_timepoints_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY microarray_timepoints
    ADD CONSTRAINT microarray_timepoints_pkey PRIMARY KEY (id);


--
-- Name: microarrays_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY microarrays
    ADD CONSTRAINT microarrays_pkey PRIMARY KEY (id);


--
-- Name: min_transmembrane_domain_lengths_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transmembrane_domain_measurements
    ADD CONSTRAINT min_transmembrane_domain_lengths_pkey PRIMARY KEY (id);


--
-- Name: mouse_pheno_descs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mouse_pheno_descs
    ADD CONSTRAINT mouse_pheno_descs_pkey PRIMARY KEY (id);


--
-- Name: mouse_phenotype_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mouse_phenotype_informations
    ADD CONSTRAINT mouse_phenotype_informations_pkey PRIMARY KEY (id);


--
-- Name: mverifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mverifications
    ADD CONSTRAINT mverifications_pkey PRIMARY KEY (id);


--
-- Name: networks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY networks
    ADD CONSTRAINT networks_pkey PRIMARY KEY (id);


--
-- Name: orthomcl_gene_coding_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orthomcl_gene_coding_regions
    ADD CONSTRAINT orthomcl_gene_coding_regions_pkey PRIMARY KEY (id);


--
-- Name: orthomcl_gene_official_datas_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orthomcl_gene_official_datas
    ADD CONSTRAINT orthomcl_gene_official_datas_pkey PRIMARY KEY (id);


--
-- Name: orthomcl_genes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orthomcl_genes
    ADD CONSTRAINT orthomcl_genes_pkey PRIMARY KEY (id);


--
-- Name: orthomcl_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orthomcl_groups
    ADD CONSTRAINT orthomcl_groups_pkey PRIMARY KEY (id);


--
-- Name: orthomcl_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orthomcl_runs
    ADD CONSTRAINT orthomcl_runs_pkey PRIMARY KEY (id);


--
-- Name: phenotype_informations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY phenotype_informations
    ADD CONSTRAINT phenotype_informations_pkey PRIMARY KEY (id);


--
-- Name: phenotype_observeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY phenotype_observeds
    ADD CONSTRAINT phenotype_observeds_pkey PRIMARY KEY (id);


--
-- Name: plasmo_db_gene_list_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plasmo_db_gene_list_entries
    ADD CONSTRAINT plasmo_db_gene_list_entries_pkey PRIMARY KEY (id);


--
-- Name: plasmodb_gene_list_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plasmodb_gene_list_entries
    ADD CONSTRAINT plasmodb_gene_list_entries_pkey PRIMARY KEY (id);


--
-- Name: plasmodb_gene_lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY plasmodb_gene_lists
    ADD CONSTRAINT plasmodb_gene_lists_pkey PRIMARY KEY (id);


--
-- Name: probe_map_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY probe_map_entries
    ADD CONSTRAINT probe_map_entries_pkey PRIMARY KEY (id);


--
-- Name: probe_maps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY probe_maps
    ADD CONSTRAINT probe_maps_pkey PRIMARY KEY (id);


--
-- Name: publications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY publications
    ADD CONSTRAINT publications_pkey PRIMARY KEY (id);


--
-- Name: scaffolds_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scaffolds
    ADD CONSTRAINT scaffolds_pkey PRIMARY KEY (id);


--
-- Name: scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scripts
    ADD CONSTRAINT scripts_pkey PRIMARY KEY (id);


--
-- Name: sequences_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sequences
    ADD CONSTRAINT sequences_pkey PRIMARY KEY (id);


--
-- Name: signal_ps_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY signal_ps
    ADD CONSTRAINT signal_ps_pkey PRIMARY KEY (id);


--
-- Name: species_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY species
    ADD CONSTRAINT species_pkey PRIMARY KEY (id);


--
-- Name: taxon_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxon_names
    ADD CONSTRAINT taxon_names_pkey PRIMARY KEY (id);


--
-- Name: taxons_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taxons
    ADD CONSTRAINT taxons_pkey PRIMARY KEY (id);


--
-- Name: top_level_localisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY top_level_localisations
    ADD CONSTRAINT top_level_localisations_pkey PRIMARY KEY (id);


--
-- Name: transmembrane_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY transmembrane_domains
    ADD CONSTRAINT transmembrane_domains_pkey PRIMARY KEY (id);


--
-- Name: verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (id);


--
-- Name: yeast_pheno_infos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY yeast_pheno_infos
    ADD CONSTRAINT yeast_pheno_infos_pkey PRIMARY KEY (id);


--
-- Name: drosophila_allele_phenotype_dag_dag; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX drosophila_allele_phenotype_dag_dag ON drosophila_allele_phenotype_drosophila_allele_genes USING btree (drosophila_allele_gene_id);


--
-- Name: drosophila_allele_phenotype_dag_dap; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX drosophila_allele_phenotype_dag_dap ON drosophila_allele_phenotype_drosophila_allele_genes USING btree (drosophila_allele_phenotype_id);


--
-- Name: go_term_idx_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX go_term_idx_name ON go_terms USING btree (go_identifier);


--
-- Name: index_annotations_on_coding_region_id_and_annotation; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_annotations_on_coding_region_id_and_annotation ON annotations USING btree (coding_region_id, annotation);


--
-- Name: index_binary_coding_region_measurements_on_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_binary_coding_region_measurements_on_coding_region_id ON binary_coding_region_measurements USING btree (coding_region_id);


--
-- Name: index_binary_coding_region_measurements_on_coding_region_id_and; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_binary_coding_region_measurements_on_coding_region_id_and ON binary_coding_region_measurements USING btree (coding_region_id, type);


--
-- Name: index_cds_on_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_cds_on_coding_region_id ON cds USING btree (coding_region_id);


--
-- Name: index_cluster_entries_on_cluster_id_and_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_cluster_entries_on_cluster_id_and_coding_region_id ON cluster_entries USING btree (cluster_id, coding_region_id);


--
-- Name: index_coding_region_alternate_string_ids_on_coding_region_id_an; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_alternate_string_ids_on_coding_region_id_an ON coding_region_alternate_string_ids USING btree (coding_region_id, name);


--
-- Name: index_coding_region_alternate_string_ids_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coding_region_alternate_string_ids_on_name ON coding_region_alternate_string_ids USING btree (name);


--
-- Name: index_coding_region_drosophila_allele_genes_on_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coding_region_drosophila_allele_genes_on_coding_region_id ON coding_region_drosophila_allele_genes USING btree (coding_region_id);


--
-- Name: index_coding_region_drosophila_allele_genes_on_drosophila_allel; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coding_region_drosophila_allele_genes_on_drosophila_allel ON coding_region_drosophila_allele_genes USING btree (drosophila_allele_gene_id);


--
-- Name: index_coding_region_go_terms_on_coding_region_id_and_go_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_go_terms_on_coding_region_id_and_go_term_id ON coding_region_go_terms USING btree (coding_region_id, go_term_id);


--
-- Name: index_coding_region_localisations_on_coding_region_id_and_local; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_localisations_on_coding_region_id_and_local ON coding_region_localisations USING btree (coding_region_id, localisation_id, localisation_method_id);


--
-- Name: index_coding_region_localisations_on_localisation_id_and_coding; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_localisations_on_localisation_id_and_coding ON coding_region_localisations USING btree (localisation_id, coding_region_id, localisation_method_id);


--
-- Name: index_coding_region_mouse_phenotype_informations_on_coding_regi; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_mouse_phenotype_informations_on_coding_regi ON coding_region_mouse_phenotype_informations USING btree (coding_region_id, mouse_phenotype_information_id);


--
-- Name: index_coding_region_network_edges_on_network_id_and_coding_regi; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_network_edges_on_network_id_and_coding_regi ON coding_region_network_edges USING btree (network_id, coding_region_id_first, coding_region_id_second);


--
-- Name: index_coding_region_phenotype_informations_on_coding_region_id_; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_phenotype_informations_on_coding_region_id_ ON coding_region_phenotype_informations USING btree (coding_region_id, phenotype_information_id);


--
-- Name: index_coding_region_phenotype_observeds_on_coding_region_id_and; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_phenotype_observeds_on_coding_region_id_and ON coding_region_phenotype_observeds USING btree (coding_region_id, phenotype_observed_id);


--
-- Name: index_coding_region_yeast_pheno_infos_on_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coding_region_yeast_pheno_infos_on_coding_region_id ON coding_region_yeast_pheno_infos USING btree (coding_region_id);


--
-- Name: index_coding_region_yeast_pheno_infos_on_coding_region_id_and_y; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_yeast_pheno_infos_on_coding_region_id_and_y ON coding_region_yeast_pheno_infos USING btree (coding_region_id, yeast_pheno_info_id);


--
-- Name: index_coding_region_yeast_pheno_infos_on_yeast_pheno_info_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coding_region_yeast_pheno_infos_on_yeast_pheno_info_id ON coding_region_yeast_pheno_infos USING btree (yeast_pheno_info_id);


--
-- Name: index_coding_regions_on_gene_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coding_regions_on_gene_id ON coding_regions USING btree (gene_id);


--
-- Name: index_coding_regions_on_orientation; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coding_regions_on_orientation ON coding_regions USING btree (orientation);


--
-- Name: index_coding_regions_on_string_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coding_regions_on_string_id ON coding_regions USING btree (string_id);


--
-- Name: index_comments_on_expression_context_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_comments_on_expression_context_id ON comments USING btree (expression_context_id);


--
-- Name: index_developmental_stage_synonyms_on_developmental_stage_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_developmental_stage_synonyms_on_developmental_stage_id ON developmental_stage_synonyms USING btree (developmental_stage_id);


--
-- Name: index_developmental_stage_synonyms_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_developmental_stage_synonyms_on_name ON developmental_stage_synonyms USING btree (name);


--
-- Name: index_drosophila_allele_genes_on_allele; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_drosophila_allele_genes_on_allele ON drosophila_allele_genes USING btree (allele);


--
-- Name: index_drosophila_allele_phenotypes_on_phenotype; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_drosophila_allele_phenotypes_on_phenotype ON drosophila_allele_phenotypes USING btree (phenotype);


--
-- Name: index_expression_contexts_on_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_expression_contexts_on_coding_region_id ON expression_contexts USING btree (coding_region_id);


--
-- Name: index_float_coding_region_measurements_on_type_and_coding_regio; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_float_coding_region_measurements_on_type_and_coding_regio ON float_coding_region_measurements USING btree (type, coding_region_id);


--
-- Name: index_gene_alternate_names_on_gene_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_gene_alternate_names_on_gene_id ON gene_alternate_names USING btree (gene_id);


--
-- Name: index_gene_alternate_names_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_gene_alternate_names_on_name ON gene_alternate_names USING btree (name);


--
-- Name: index_gene_network_edges_on_gene_id_first; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_gene_network_edges_on_gene_id_first ON gene_network_edges USING btree (gene_id_first);


--
-- Name: index_gene_network_edges_on_gene_id_second; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_gene_network_edges_on_gene_id_second ON gene_network_edges USING btree (gene_id_second);


--
-- Name: index_gene_network_edges_on_gene_network_id_and_gene_id_first_a; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_gene_network_edges_on_gene_network_id_and_gene_id_first_a ON gene_network_edges USING btree (gene_network_id, gene_id_first, gene_id_second);


--
-- Name: index_genes_on_scaffold_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_genes_on_scaffold_id ON genes USING btree (scaffold_id);


--
-- Name: index_go_alternates_on_go_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_go_alternates_on_go_identifier ON go_alternates USING btree (go_identifier);


--
-- Name: index_go_map_entries_on_go_map_id_and_parent_id_and_child_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_go_map_entries_on_go_map_id_and_parent_id_and_child_id ON go_map_entries USING btree (go_map_id, parent_id, child_id);


--
-- Name: index_integer_coding_region_measurements_on_type_and_coding_reg; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_integer_coding_region_measurements_on_type_and_coding_reg ON integer_coding_region_measurements USING btree (type, coding_region_id);


--
-- Name: index_localisation_methods_on_description; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_localisation_methods_on_description ON localisation_methods USING btree (description);


--
-- Name: index_localisation_top_level_localisations_on_localisation_id_a; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_localisation_top_level_localisations_on_localisation_id_a ON localisation_top_level_localisations USING btree (localisation_id, type);


--
-- Name: index_localisation_top_level_localisations_on_top_level_localis; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_localisation_top_level_localisations_on_top_level_localis ON localisation_top_level_localisations USING btree (top_level_localisation_id, type);


--
-- Name: index_localisation_top_level_localisations_on_type_and_localisa; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_localisation_top_level_localisations_on_type_and_localisa ON localisation_top_level_localisations USING btree (type, localisation_id, top_level_localisation_id);


--
-- Name: index_microarray_measurements_on_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_microarray_measurements_on_coding_region_id ON microarray_measurements USING btree (coding_region_id);


--
-- Name: index_microarray_measurements_on_microarray_timepoint_id_and_co; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_microarray_measurements_on_microarray_timepoint_id_and_co ON microarray_measurements USING btree (microarray_timepoint_id, coding_region_id, measurement);


--
-- Name: index_microarray_timepoints_on_microarray_id_and_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_microarray_timepoints_on_microarray_id_and_name ON microarray_timepoints USING btree (microarray_id, name);


--
-- Name: index_min_transmembrane_domain_lengths_on_coding_region_id_and_; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_min_transmembrane_domain_lengths_on_coding_region_id_and_ ON transmembrane_domain_measurements USING btree (coding_region_id, type);


--
-- Name: index_mouse_pheno_descs_on_pheno_desc_and_pheno_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mouse_pheno_descs_on_pheno_desc_and_pheno_id ON mouse_pheno_descs USING btree (pheno_desc, pheno_id);


--
-- Name: index_mouse_pheno_descs_on_pheno_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_mouse_pheno_descs_on_pheno_id ON mouse_pheno_descs USING btree (pheno_id);


--
-- Name: index_networks_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_networks_on_name ON networks USING btree (name);


--
-- Name: index_orthomcl_gene_coding_regions_on_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orthomcl_gene_coding_regions_on_coding_region_id ON orthomcl_gene_coding_regions USING btree (coding_region_id);


--
-- Name: index_orthomcl_gene_coding_regions_on_coding_region_id_and_orth; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orthomcl_gene_coding_regions_on_coding_region_id_and_orth ON orthomcl_gene_coding_regions USING btree (coding_region_id, orthomcl_gene_id);


--
-- Name: index_orthomcl_gene_coding_regions_on_orthomcl_gene_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orthomcl_gene_coding_regions_on_orthomcl_gene_id ON orthomcl_gene_coding_regions USING btree (orthomcl_gene_id);


--
-- Name: index_orthomcl_gene_official_datas_on_orthomcl_gene_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orthomcl_gene_official_datas_on_orthomcl_gene_id ON orthomcl_gene_official_datas USING btree (orthomcl_gene_id);


--
-- Name: index_orthomcl_genes_on_orthomcl_group_id_and_orthomcl_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orthomcl_genes_on_orthomcl_group_id_and_orthomcl_name ON orthomcl_genes USING btree (orthomcl_group_id, orthomcl_name);


--
-- Name: index_orthomcl_genes_on_orthomcl_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orthomcl_genes_on_orthomcl_name ON orthomcl_genes USING btree (orthomcl_name);


--
-- Name: index_orthomcl_groups_on_orthomcl_run_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orthomcl_groups_on_orthomcl_run_id ON orthomcl_groups USING btree (orthomcl_run_id);


--
-- Name: index_orthomcl_groups_on_orthomcl_run_id_and_orthomcl_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_orthomcl_groups_on_orthomcl_run_id_and_orthomcl_name ON orthomcl_groups USING btree (orthomcl_run_id, orthomcl_name);


--
-- Name: index_orthomcl_runs_on_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orthomcl_runs_on_name ON orthomcl_runs USING btree (name);


--
-- Name: index_plasmodb_gene_list_entries_on_plasmodb_gene_list_id_and_c; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_plasmodb_gene_list_entries_on_plasmodb_gene_list_id_and_c ON plasmodb_gene_list_entries USING btree (plasmodb_gene_list_id, coding_region_id);


--
-- Name: index_scaffolds_on_species_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_scaffolds_on_species_id ON scaffolds USING btree (species_id);


--
-- Name: index_sequences_on_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_sequences_on_coding_region_id ON sequences USING btree (coding_region_id);


--
-- Name: index_sequences_on_coding_region_id_and_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sequences_on_coding_region_id_and_type ON sequences USING btree (coding_region_id, type);


--
-- Name: index_transmembrane_domain_measurements_on_coding_region_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transmembrane_domain_measurements_on_coding_region_id ON transmembrane_domain_measurements USING btree (coding_region_id);


--
-- Name: index_transmembrane_domains_on_coding_region_id_and_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_transmembrane_domains_on_coding_region_id_and_type ON transmembrane_domains USING btree (coding_region_id, type);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('69');

INSERT INTO schema_migrations (version) VALUES ('68');

INSERT INTO schema_migrations (version) VALUES ('36');

INSERT INTO schema_migrations (version) VALUES ('37');

INSERT INTO schema_migrations (version) VALUES ('60');

INSERT INTO schema_migrations (version) VALUES ('32');

INSERT INTO schema_migrations (version) VALUES ('26');

INSERT INTO schema_migrations (version) VALUES ('40');

INSERT INTO schema_migrations (version) VALUES ('49');

INSERT INTO schema_migrations (version) VALUES ('47');

INSERT INTO schema_migrations (version) VALUES ('15');

INSERT INTO schema_migrations (version) VALUES ('7');

INSERT INTO schema_migrations (version) VALUES ('9');

INSERT INTO schema_migrations (version) VALUES ('61');

INSERT INTO schema_migrations (version) VALUES ('25');

INSERT INTO schema_migrations (version) VALUES ('22');

INSERT INTO schema_migrations (version) VALUES ('48');

INSERT INTO schema_migrations (version) VALUES ('21');

INSERT INTO schema_migrations (version) VALUES ('41');

INSERT INTO schema_migrations (version) VALUES ('31');

INSERT INTO schema_migrations (version) VALUES ('43');

INSERT INTO schema_migrations (version) VALUES ('34');

INSERT INTO schema_migrations (version) VALUES ('14');

INSERT INTO schema_migrations (version) VALUES ('38');

INSERT INTO schema_migrations (version) VALUES ('20');

INSERT INTO schema_migrations (version) VALUES ('58');

INSERT INTO schema_migrations (version) VALUES ('29');

INSERT INTO schema_migrations (version) VALUES ('28');

INSERT INTO schema_migrations (version) VALUES ('6');

INSERT INTO schema_migrations (version) VALUES ('59');

INSERT INTO schema_migrations (version) VALUES ('57');

INSERT INTO schema_migrations (version) VALUES ('67');

INSERT INTO schema_migrations (version) VALUES ('54');

INSERT INTO schema_migrations (version) VALUES ('10');

INSERT INTO schema_migrations (version) VALUES ('23');

INSERT INTO schema_migrations (version) VALUES ('52');

INSERT INTO schema_migrations (version) VALUES ('5');

INSERT INTO schema_migrations (version) VALUES ('13');

INSERT INTO schema_migrations (version) VALUES ('46');

INSERT INTO schema_migrations (version) VALUES ('64');

INSERT INTO schema_migrations (version) VALUES ('56');

INSERT INTO schema_migrations (version) VALUES ('65');

INSERT INTO schema_migrations (version) VALUES ('24');

INSERT INTO schema_migrations (version) VALUES ('4');

INSERT INTO schema_migrations (version) VALUES ('62');

INSERT INTO schema_migrations (version) VALUES ('11');

INSERT INTO schema_migrations (version) VALUES ('45');

INSERT INTO schema_migrations (version) VALUES ('27');

INSERT INTO schema_migrations (version) VALUES ('19');

INSERT INTO schema_migrations (version) VALUES ('3');

INSERT INTO schema_migrations (version) VALUES ('50');

INSERT INTO schema_migrations (version) VALUES ('1');

INSERT INTO schema_migrations (version) VALUES ('33');

INSERT INTO schema_migrations (version) VALUES ('55');

INSERT INTO schema_migrations (version) VALUES ('39');

INSERT INTO schema_migrations (version) VALUES ('30');

INSERT INTO schema_migrations (version) VALUES ('18');

INSERT INTO schema_migrations (version) VALUES ('63');

INSERT INTO schema_migrations (version) VALUES ('35');

INSERT INTO schema_migrations (version) VALUES ('44');

INSERT INTO schema_migrations (version) VALUES ('51');

INSERT INTO schema_migrations (version) VALUES ('8');

INSERT INTO schema_migrations (version) VALUES ('16');

INSERT INTO schema_migrations (version) VALUES ('53');

INSERT INTO schema_migrations (version) VALUES ('42');

INSERT INTO schema_migrations (version) VALUES ('12');

INSERT INTO schema_migrations (version) VALUES ('66');

INSERT INTO schema_migrations (version) VALUES ('2');

INSERT INTO schema_migrations (version) VALUES ('17');

INSERT INTO schema_migrations (version) VALUES ('20080613012004');

INSERT INTO schema_migrations (version) VALUES ('20080613012117');

INSERT INTO schema_migrations (version) VALUES ('20080617034756');

INSERT INTO schema_migrations (version) VALUES ('20080626011459');

INSERT INTO schema_migrations (version) VALUES ('20080626013148');

INSERT INTO schema_migrations (version) VALUES ('20080626013250');

INSERT INTO schema_migrations (version) VALUES ('20080714014554');

INSERT INTO schema_migrations (version) VALUES ('20080714014601');

INSERT INTO schema_migrations (version) VALUES ('20080716235613');

INSERT INTO schema_migrations (version) VALUES ('20080717054412');

INSERT INTO schema_migrations (version) VALUES ('20080717062229');

INSERT INTO schema_migrations (version) VALUES ('20080721103728');

INSERT INTO schema_migrations (version) VALUES ('20080811015332');

INSERT INTO schema_migrations (version) VALUES ('20080811021029');

INSERT INTO schema_migrations (version) VALUES ('20080821033348');

INSERT INTO schema_migrations (version) VALUES ('20080821035705');

INSERT INTO schema_migrations (version) VALUES ('20080821035725');

INSERT INTO schema_migrations (version) VALUES ('20080821041240');

INSERT INTO schema_migrations (version) VALUES ('20080818042704');

INSERT INTO schema_migrations (version) VALUES ('20080818051357');

INSERT INTO schema_migrations (version) VALUES ('20080819053623');

INSERT INTO schema_migrations (version) VALUES ('20080822065008');

INSERT INTO schema_migrations (version) VALUES ('20080823033826');

INSERT INTO schema_migrations (version) VALUES ('20080823063031');

INSERT INTO schema_migrations (version) VALUES ('20080823064422');

INSERT INTO schema_migrations (version) VALUES ('20080823075049');

INSERT INTO schema_migrations (version) VALUES ('20080823091512');

INSERT INTO schema_migrations (version) VALUES ('20080826055159');

INSERT INTO schema_migrations (version) VALUES ('20080827014223');

INSERT INTO schema_migrations (version) VALUES ('20080827005801');

INSERT INTO schema_migrations (version) VALUES ('20080827072655');

INSERT INTO schema_migrations (version) VALUES ('20080827234440');

INSERT INTO schema_migrations (version) VALUES ('20080828003320');

INSERT INTO schema_migrations (version) VALUES ('20080828003544');

INSERT INTO schema_migrations (version) VALUES ('20080827023722');

INSERT INTO schema_migrations (version) VALUES ('20080819011606');

INSERT INTO schema_migrations (version) VALUES ('20080828043112');

INSERT INTO schema_migrations (version) VALUES ('20080828050648');

INSERT INTO schema_migrations (version) VALUES ('20080828060613');

INSERT INTO schema_migrations (version) VALUES ('20080828071634');

INSERT INTO schema_migrations (version) VALUES ('20080829053209');

INSERT INTO schema_migrations (version) VALUES ('20080830030326');

INSERT INTO schema_migrations (version) VALUES ('20080830031036');

INSERT INTO schema_migrations (version) VALUES ('20080830045757');

INSERT INTO schema_migrations (version) VALUES ('20080830051616');

INSERT INTO schema_migrations (version) VALUES ('20080830064227');

INSERT INTO schema_migrations (version) VALUES ('20080901123318');

INSERT INTO schema_migrations (version) VALUES ('20080901124937');

INSERT INTO schema_migrations (version) VALUES ('20080902041238');

INSERT INTO schema_migrations (version) VALUES ('20080902041615');

INSERT INTO schema_migrations (version) VALUES ('20080902044459');

INSERT INTO schema_migrations (version) VALUES ('20080903012939');

INSERT INTO schema_migrations (version) VALUES ('20080904002848');

INSERT INTO schema_migrations (version) VALUES ('20080904021754');

INSERT INTO schema_migrations (version) VALUES ('20080904025228');

INSERT INTO schema_migrations (version) VALUES ('20080925024844');