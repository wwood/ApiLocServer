--
-- PostgreSQL database dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'Standard public schema';


--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: -
--

CREATE PROCEDURAL LANGUAGE plpgsql;


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: brafl_upstream_distances_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE brafl_upstream_distances_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: brafl_upstream_distances_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE brafl_upstream_distances_id_seq OWNED BY brafl_upstream_distances.id;


--
-- Name: cds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE cds (
    id integer NOT NULL,
    coding_region_id integer NOT NULL,
    "start" integer NOT NULL,
    stop integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: cluster_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cluster_entries_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: cluster_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cluster_entries_id_seq OWNED BY cluster_entries.id;


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
-- Name: clusters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clusters_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: clusters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clusters_id_seq OWNED BY clusters.id;


--
-- Name: clustersets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE clustersets (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: clustersets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE clustersets_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: clustersets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE clustersets_id_seq OWNED BY clustersets.id;


--
-- Name: coding_region_alternate_string_ids; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_alternate_string_ids (
    id integer NOT NULL,
    coding_region_id integer,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: coding_region_go_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE coding_region_go_terms (
    id integer NOT NULL,
    coding_region_id integer,
    go_term_id integer
);


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
-- Name: derisi20063d7logmean; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE derisi20063d7logmean (
    id integer NOT NULL,
    plasmodbid text,
    timepoint1 double precision,
    timepoint2 double precision,
    timepoint3 double precision,
    timepoint4 double precision,
    timepoint5 double precision,
    timepoint6 double precision,
    timepoint7 double precision,
    timepoint8 double precision,
    timepoint9 double precision,
    timepoint10 double precision,
    timepoint11 double precision,
    timepoint12 double precision,
    timepoint13 double precision,
    timepoint14 double precision,
    timepoint15 double precision,
    timepoint16 double precision,
    timepoint17 double precision,
    timepoint18 double precision,
    timepoint19 double precision,
    timepoint20 double precision,
    timepoint21 double precision,
    timepoint22 double precision,
    timepoint23 double precision,
    timepoint24 double precision,
    timepoint25 double precision,
    timepoint26 double precision,
    timepoint27 double precision,
    timepoint28 double precision,
    timepoint29 double precision,
    timepoint30 double precision,
    timepoint31 double precision,
    timepoint32 double precision,
    timepoint33 double precision,
    timepoint34 double precision,
    timepoint35 double precision,
    timepoint36 double precision,
    timepoint37 double precision,
    timepoint38 double precision,
    timepoint39 double precision,
    timepoint40 double precision,
    timepoint41 double precision,
    timepoint42 double precision,
    timepoint43 double precision,
    timepoint44 double precision,
    timepoint45 double precision,
    timepoint46 double precision,
    timepoint47 double precision,
    timepoint48 double precision,
    timepoint49 double precision,
    timepoint50 double precision,
    timepoint51 double precision,
    timepoint52 double precision,
    timepoint53 double precision,
    coding_region_id integer
);


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
-- Name: generic_go_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE generic_go_maps_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: generic_go_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE generic_go_maps_id_seq OWNED BY generic_go_maps.id;


--
-- Name: genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE genes (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    scaffold_id integer
);


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
-- Name: go_alternates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_alternates (
    id integer NOT NULL,
    go_identifier character varying(255),
    go_term_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: go_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_lists (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: go_map_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE go_map_entries_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: go_map_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE go_map_entries_id_seq OWNED BY go_map_entries.id;


--
-- Name: go_maps; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_maps (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: go_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE go_maps_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: go_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE go_maps_id_seq OWNED BY go_maps.id;


--
-- Name: go_terms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE go_terms (
    id integer NOT NULL,
    go_identifier character varying(255),
    term character varying(255),
    aspect character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: gus; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE gus (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: localisation_methods; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE localisation_methods (
    id integer NOT NULL,
    description character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: localisations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE localisations (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: orthomcl_genes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orthomcl_genes (
    id integer NOT NULL,
    orthomcl_name character varying(255),
    orthomcl_group_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: orthomcl_groups; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orthomcl_groups (
    id integer NOT NULL,
    version integer,
    orthomcl_name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    orthomcl_run_id integer NOT NULL
);


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
-- Name: orthomcl_runs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE orthomcl_runs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: plasmodb_gene_lists; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE plasmodb_gene_lists (
    id integer NOT NULL,
    description character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: probe_map_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE probe_map_entries_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: probe_map_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE probe_map_entries_id_seq OWNED BY probe_map_entries.id;


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
-- Name: probe_maps_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE probe_maps_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


--
-- Name: probe_maps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE probe_maps_id_seq OWNED BY probe_maps.id;


--
-- Name: scaffolds; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scaffolds (
    id integer NOT NULL,
    species_id integer,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: schema_info; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_info (
    version integer
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
-- Name: species; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE species (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: taxon_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxon_names (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: taxons; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taxons (
    id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


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
-- Name: verifications; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE verifications (
    id integer NOT NULL
);


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

ALTER TABLE coding_region_go_terms ALTER COLUMN id SET DEFAULT nextval('coding_region_go_terms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_region_localisations ALTER COLUMN id SET DEFAULT nextval('coding_region_localisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE coding_regions ALTER COLUMN id SET DEFAULT nextval('coding_regions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE derisi20063d7logmean ALTER COLUMN id SET DEFAULT nextval('derisi20063d7logmean_id_seq'::regclass);


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

ALTER TABLE localisation_methods ALTER COLUMN id SET DEFAULT nextval('localisation_methods_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE localisations ALTER COLUMN id SET DEFAULT nextval('localisations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE orthomcl_gene_coding_regions ALTER COLUMN id SET DEFAULT nextval('orthomcl_gene_coding_regions_id_seq'::regclass);


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

ALTER TABLE scaffolds ALTER COLUMN id SET DEFAULT nextval('scaffolds_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE scripts ALTER COLUMN id SET DEFAULT nextval('scripts_id_seq'::regclass);


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

ALTER TABLE verifications ALTER COLUMN id SET DEFAULT nextval('verifications_id_seq'::regclass);


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
-- Name: coding_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY coding_regions
    ADD CONSTRAINT coding_regions_pkey PRIMARY KEY (id);


--
-- Name: derisi20063d7logmean_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY derisi20063d7logmean
    ADD CONSTRAINT derisi20063d7logmean_pkey PRIMARY KEY (id);


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
-- Name: localisation_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY localisation_methods
    ADD CONSTRAINT localisation_methods_pkey PRIMARY KEY (id);


--
-- Name: localisations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY localisations
    ADD CONSTRAINT localisations_pkey PRIMARY KEY (id);


--
-- Name: orthomcl_gene_coding_regions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY orthomcl_gene_coding_regions
    ADD CONSTRAINT orthomcl_gene_coding_regions_pkey PRIMARY KEY (id);


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
-- Name: verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY verifications
    ADD CONSTRAINT verifications_pkey PRIMARY KEY (id);


--
-- Name: go_alternate_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX go_alternate_index ON go_alternates USING btree (go_identifier);


--
-- Name: go_term_idx_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX go_term_idx_name ON go_terms USING btree (go_identifier);


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
-- Name: index_coding_region_go_terms_on_coding_region_id_and_go_term_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_go_terms_on_coding_region_id_and_go_term_id ON coding_region_go_terms USING btree (coding_region_id, go_term_id);


--
-- Name: index_coding_region_localisations_on_coding_region_id_and_local; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_coding_region_localisations_on_coding_region_id_and_local ON coding_region_localisations USING btree (coding_region_id, localisation_id);


--
-- Name: index_coding_regions_on_gene_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_coding_regions_on_gene_id ON coding_regions USING btree (gene_id);


--
-- Name: index_go_map_entries_on_go_map_id_and_parent_id_and_child_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_go_map_entries_on_go_map_id_and_parent_id_and_child_id ON go_map_entries USING btree (go_map_id, parent_id, child_id);


--
-- Name: index_localisation_methods_on_description; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_localisation_methods_on_description ON localisation_methods USING btree (description);


--
-- Name: index_orthomcl_gene_coding_regions_on_coding_region_id_and_orth; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orthomcl_gene_coding_regions_on_coding_region_id_and_orth ON orthomcl_gene_coding_regions USING btree (coding_region_id, orthomcl_gene_id);


--
-- Name: index_orthomcl_genes_on_orthomcl_group_id_and_orthomcl_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orthomcl_genes_on_orthomcl_group_id_and_orthomcl_name ON orthomcl_genes USING btree (orthomcl_group_id, orthomcl_name);


--
-- Name: index_orthomcl_groups_on_version_and_orthomcl_name; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_orthomcl_groups_on_version_and_orthomcl_name ON orthomcl_groups USING btree (version, orthomcl_name);


--
-- Name: index_plasmodb_gene_list_entries_on_plasmodb_gene_list_id_and_c; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_plasmodb_gene_list_entries_on_plasmodb_gene_list_id_and_c ON plasmodb_gene_list_entries USING btree (plasmodb_gene_list_id, coding_region_id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_info (version) VALUES (52)