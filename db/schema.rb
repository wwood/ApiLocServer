# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20080929064304) do

  create_table "annotations", :force => true do |t|
    t.integer  "coding_region_id"
    t.text     "annotation",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["annotation", "coding_region_id"], :name => "index_annotations_on_coding_region_id_and_annotation", :unique => true

  create_table "binary_coding_region_measurements", :force => true do |t|
    t.integer  "coding_region_id", :null => false
    t.boolean  "value"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "binary_coding_region_measurements", ["coding_region_id"], :name => "index_binary_coding_region_measurements_on_coding_region_id"
  add_index "binary_coding_region_measurements", ["coding_region_id", "type"], :name => "index_binary_coding_region_measurements_on_coding_region_id_and"

  create_table "brafl_upstream_distances", :force => true do |t|
    t.integer  "go_term_id",        :null => false
    t.integer  "upstream_distance", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coding_region_id"
  end

  create_table "cds", :force => true do |t|
    t.integer  "coding_region_id", :null => false
    t.integer  "start",            :null => false
    t.integer  "stop",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cds", ["coding_region_id"], :name => "index_cds_on_coding_region_id"

  create_table "cluster_entries", :force => true do |t|
    t.integer  "coding_region_id"
    t.integer  "cluster_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cluster_entries", ["cluster_id", "coding_region_id"], :name => "index_cluster_entries_on_cluster_id_and_coding_region_id", :unique => true

  create_table "clusters", :force => true do |t|
    t.integer  "clusterset_id"
    t.integer  "published_number"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "clustersets", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coding_region_alternate_string_ids", :force => true do |t|
    t.integer  "coding_region_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_alternate_string_ids", ["coding_region_id"], :name => "index_coding_region_alternate_string_ids_on_coding_region_id"
  add_index "coding_region_alternate_string_ids", ["coding_region_id", "name"], :name => "index_coding_region_alternate_string_ids_on_coding_region_id_an", :unique => true
  add_index "coding_region_alternate_string_ids", ["name"], :name => "index_coding_region_alternate_string_ids_on_name"

  create_table "coding_region_drosophila_allele_genes", :force => true do |t|
    t.integer  "coding_region_id",          :null => false
    t.integer  "drosophila_allele_gene_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_drosophila_allele_genes", ["coding_region_id"], :name => "index_coding_region_drosophila_allele_genes_on_coding_region_id"
  add_index "coding_region_drosophila_allele_genes", ["drosophila_allele_gene_id"], :name => "index_coding_region_drosophila_allele_genes_on_drosophila_allel"

  create_table "coding_region_go_terms", :force => true do |t|
    t.integer "coding_region_id"
    t.integer "go_term_id"
  end

  add_index "coding_region_go_terms", ["coding_region_id", "go_term_id"], :name => "index_coding_region_go_terms_on_coding_region_id_and_go_term_id", :unique => true

  create_table "coding_region_localisations", :force => true do |t|
    t.integer  "coding_region_id",       :null => false
    t.integer  "localisation_id",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "localisation_method_id", :null => false
  end

  add_index "coding_region_localisations", ["coding_region_id", "localisation_id", "localisation_method_id"], :name => "index_coding_region_localisations_on_coding_region_id_and_local", :unique => true
  add_index "coding_region_localisations", ["coding_region_id", "localisation_id", "localisation_method_id"], :name => "index_coding_region_localisations_on_localisation_id_and_coding", :unique => true

  create_table "coding_region_mouse_phenotype_informations", :force => true do |t|
    t.integer  "coding_region_id"
    t.integer  "mouse_phenotype_information_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_mouse_phenotype_informations", ["coding_region_id", "mouse_phenotype_information_id"], :name => "index_coding_region_mouse_phenotype_informations_on_coding_regi", :unique => true

  create_table "coding_region_network_edges", :force => true do |t|
    t.integer  "network_id",              :null => false
    t.integer  "integer",                 :null => false
    t.integer  "coding_region_id_first",  :null => false
    t.integer  "coding_region_id_second", :null => false
    t.decimal  "strength"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_network_edges", ["coding_region_id_first", "coding_region_id_second", "network_id"], :name => "index_coding_region_network_edges_on_network_id_and_coding_regi", :unique => true

  create_table "coding_region_phenotype_informations", :force => true do |t|
    t.integer  "coding_region_id"
    t.integer  "phenotype_information_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_phenotype_informations", ["coding_region_id", "phenotype_information_id"], :name => "index_coding_region_phenotype_informations_on_coding_region_id_", :unique => true

  create_table "coding_region_phenotype_observeds", :force => true do |t|
    t.integer  "coding_region_id"
    t.integer  "phenotype_observed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_phenotype_observeds", ["coding_region_id", "phenotype_observed_id"], :name => "index_coding_region_phenotype_observeds_on_coding_region_id_and", :unique => true

  create_table "coding_region_yeast_pheno_infos", :force => true do |t|
    t.integer  "coding_region_id",    :null => false
    t.integer  "yeast_pheno_info_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_yeast_pheno_infos", ["coding_region_id"], :name => "index_coding_region_yeast_pheno_infos_on_coding_region_id"
  add_index "coding_region_yeast_pheno_infos", ["coding_region_id", "yeast_pheno_info_id"], :name => "index_coding_region_yeast_pheno_infos_on_coding_region_id_and_y", :unique => true
  add_index "coding_region_yeast_pheno_infos", ["yeast_pheno_info_id"], :name => "index_coding_region_yeast_pheno_infos_on_yeast_pheno_info_id"

  create_table "coding_regions", :force => true do |t|
    t.integer  "gene_id"
    t.integer  "jgi_protein_id"
    t.integer  "upstream_distance"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "string_id"
    t.string   "orientation"
  end

  add_index "coding_regions", ["gene_id"], :name => "index_coding_regions_on_gene_id"
  add_index "coding_regions", ["orientation"], :name => "index_coding_regions_on_orientation"
  add_index "coding_regions", ["string_id"], :name => "index_coding_regions_on_string_id"

  create_table "comments", :force => true do |t|
    t.integer  "expression_context_id", :null => false
    t.string   "comment",               :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["expression_context_id"], :name => "index_comments_on_expression_context_id"

  create_table "derisi20063d7logmean", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "developmental_stage_synonyms", :force => true do |t|
    t.integer  "developmental_stage_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "developmental_stage_synonyms", ["developmental_stage_id"], :name => "index_developmental_stage_synonyms_on_developmental_stage_id"
  add_index "developmental_stage_synonyms", ["name"], :name => "index_developmental_stage_synonyms_on_name"

  create_table "developmental_stages", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "drosophila_allele_genes", :force => true do |t|
    t.string   "allele",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "drosophila_allele_genes", ["allele"], :name => "index_drosophila_allele_genes_on_allele", :unique => true

  create_table "drosophila_allele_phenotype_drosophila_allele_genes", :force => true do |t|
    t.integer  "drosophila_allele_gene_id",      :null => false
    t.integer  "drosophila_allele_phenotype_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "drosophila_allele_phenotype_drosophila_allele_genes", ["drosophila_allele_gene_id"], :name => "drosophila_allele_phenotype_dag_dag"
  add_index "drosophila_allele_phenotype_drosophila_allele_genes", ["drosophila_allele_phenotype_id"], :name => "drosophila_allele_phenotype_dag_dap"

  create_table "drosophila_allele_phenotypes", :force => true do |t|
    t.string   "phenotype"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "drosophila_allele_phenotypes", ["phenotype"], :name => "index_drosophila_allele_phenotypes_on_phenotype"

  create_table "expression_contexts", :force => true do |t|
    t.integer  "coding_region_id",       :null => false
    t.integer  "publication_id"
    t.integer  "localisation_id"
    t.integer  "developmental_stage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "expression_contexts", ["coding_region_id"], :name => "index_expression_contexts_on_coding_region_id"

  create_table "float_coding_region_measurements", :force => true do |t|
    t.string   "type"
    t.integer  "coding_region_id"
    t.float    "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "float_coding_region_measurements", ["coding_region_id", "type"], :name => "index_float_coding_region_measurements_on_type_and_coding_regio"

  create_table "gene_alternate_names", :force => true do |t|
    t.integer  "gene_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gene_alternate_names", ["gene_id"], :name => "index_gene_alternate_names_on_gene_id"
  add_index "gene_alternate_names", ["name"], :name => "index_gene_alternate_names_on_name"

  create_table "gene_network_edges", :force => true do |t|
    t.integer  "gene_network_id", :null => false
    t.integer  "gene_id_first",   :null => false
    t.integer  "gene_id_second",  :null => false
    t.decimal  "strength"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gene_network_edges", ["gene_id_first"], :name => "index_gene_network_edges_on_gene_id_first"
  add_index "gene_network_edges", ["gene_id_second"], :name => "index_gene_network_edges_on_gene_id_second"
  add_index "gene_network_edges", ["gene_id_first", "gene_id_second", "gene_network_id"], :name => "index_gene_network_edges_on_gene_network_id_and_gene_id_first_a", :unique => true

  create_table "gene_networks", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "generic_go_maps", :force => true do |t|
    t.integer  "child_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scaffold_id"
  end

  add_index "genes", ["scaffold_id"], :name => "index_genes_on_scaffold_id"

  create_table "go_alternates", :force => true do |t|
    t.string   "go_identifier"
    t.integer  "go_term_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "go_alternates", ["go_identifier"], :name => "index_go_alternates_on_go_identifier", :unique => true

  create_table "go_list_entries", :force => true do |t|
    t.integer  "go_list_id"
    t.integer  "go_term_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "go_lists", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "go_map_entries", :force => true do |t|
    t.integer  "go_map_id"
    t.integer  "parent_id"
    t.integer  "child_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "go_map_entries", ["child_id", "go_map_id", "parent_id"], :name => "index_go_map_entries_on_go_map_id_and_parent_id_and_child_id", :unique => true

  create_table "go_maps", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "go_terms", :force => true do |t|
    t.string   "go_identifier"
    t.string   "term"
    t.string   "aspect"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "go_terms", ["go_identifier"], :name => "go_term_idx_name", :unique => true

  create_table "gus", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "integer_coding_region_measurements", :force => true do |t|
    t.string   "type"
    t.integer  "coding_region_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "integer_coding_region_measurements", ["coding_region_id", "type"], :name => "index_integer_coding_region_measurements_on_type_and_coding_reg"

  create_table "localisation_methods", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "localisation_methods", ["description"], :name => "index_localisation_methods_on_description", :unique => true

  create_table "localisation_synonyms", :force => true do |t|
    t.string   "name"
    t.integer  "localisation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "localisation_top_level_localisations", :force => true do |t|
    t.integer  "localisation_id"
    t.integer  "top_level_localisation_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "localisation_top_level_localisations", ["localisation_id", "type"], :name => "index_localisation_top_level_localisations_on_localisation_id_a"
  add_index "localisation_top_level_localisations", ["top_level_localisation_id", "type"], :name => "index_localisation_top_level_localisations_on_top_level_localis"
  add_index "localisation_top_level_localisations", ["localisation_id", "top_level_localisation_id", "type"], :name => "index_localisation_top_level_localisations_on_type_and_localisa"

  create_table "localisations", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "microarray_measurements", :force => true do |t|
    t.integer  "microarray_timepoint_id", :null => false
    t.decimal  "measurement",             :null => false
    t.integer  "coding_region_id",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "microarray_measurements", ["coding_region_id"], :name => "index_microarray_measurements_on_coding_region_id"
  add_index "microarray_measurements", ["coding_region_id", "measurement", "microarray_timepoint_id"], :name => "index_microarray_measurements_on_microarray_timepoint_id_and_co"

  create_table "microarray_timepoints", :force => true do |t|
    t.integer  "microarray_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "microarray_timepoints", ["microarray_id", "name"], :name => "index_microarray_timepoints_on_microarray_id_and_name", :unique => true

  create_table "microarrays", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mouse_pheno_descs", :force => true do |t|
    t.string   "pheno_id",   :null => false
    t.string   "pheno_desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mouse_pheno_descs", ["pheno_desc", "pheno_id"], :name => "index_mouse_pheno_descs_on_pheno_desc_and_pheno_id", :unique => true
  add_index "mouse_pheno_descs", ["pheno_id"], :name => "index_mouse_pheno_descs_on_pheno_id", :unique => true

  create_table "mouse_phenotype_informations", :force => true do |t|
    t.string   "mgi_allele",          :null => false
    t.string   "allele_type"
    t.string   "mgi_marker"
    t.integer  "mouse_pheno_desc_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mverifications", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "networks", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "networks", ["name"], :name => "index_networks_on_name", :unique => true

  create_table "orthomcl_gene_coding_regions", :force => true do |t|
    t.integer  "coding_region_id"
    t.integer  "orthomcl_gene_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_gene_coding_regions", ["coding_region_id"], :name => "index_orthomcl_gene_coding_regions_on_coding_region_id"
  add_index "orthomcl_gene_coding_regions", ["coding_region_id", "orthomcl_gene_id"], :name => "index_orthomcl_gene_coding_regions_on_coding_region_id_and_orth", :unique => true
  add_index "orthomcl_gene_coding_regions", ["orthomcl_gene_id"], :name => "index_orthomcl_gene_coding_regions_on_orthomcl_gene_id"

  create_table "orthomcl_gene_official_datas", :force => true do |t|
    t.integer  "orthomcl_gene_id"
    t.text     "sequence"
    t.text     "annotation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_gene_official_datas", ["orthomcl_gene_id"], :name => "index_orthomcl_gene_official_datas_on_orthomcl_gene_id", :unique => true

  create_table "orthomcl_genes", :force => true do |t|
    t.string   "orthomcl_name"
    t.integer  "orthomcl_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_genes", ["orthomcl_group_id", "orthomcl_name"], :name => "index_orthomcl_genes_on_orthomcl_group_id_and_orthomcl_name", :unique => true
  add_index "orthomcl_genes", ["orthomcl_name"], :name => "index_orthomcl_genes_on_orthomcl_name"

  create_table "orthomcl_groups", :force => true do |t|
    t.string   "orthomcl_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "orthomcl_run_id", :null => false
  end

  add_index "orthomcl_groups", ["orthomcl_run_id"], :name => "index_orthomcl_groups_on_orthomcl_run_id"
  add_index "orthomcl_groups", ["orthomcl_name", "orthomcl_run_id"], :name => "index_orthomcl_groups_on_orthomcl_run_id_and_orthomcl_name"

  create_table "orthomcl_runs", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_runs", ["name"], :name => "index_orthomcl_runs_on_name", :unique => true

  create_table "phenotype_informations", :force => true do |t|
    t.string   "dbxref"
    t.string   "phenotype"
    t.integer  "experiments"
    t.integer  "primary"
    t.integer  "specific"
    t.integer  "observed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "phenotype_observeds", :force => true do |t|
    t.string   "dbxref"
    t.string   "phenotype"
    t.integer  "experiments"
    t.integer  "primary"
    t.integer  "specific"
    t.integer  "observed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plasmo_db_gene_list_entries", :force => true do |t|
    t.integer  "plasmo_db_gene_list_id"
    t.integer  "gene_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plasmodb_gene_list_entries", :force => true do |t|
    t.integer  "plasmodb_gene_list_id"
    t.integer  "coding_region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plasmodb_gene_list_entries", ["coding_region_id", "plasmodb_gene_list_id"], :name => "index_plasmodb_gene_list_entries_on_plasmodb_gene_list_id_and_c", :unique => true

  create_table "plasmodb_gene_lists", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "probe_map_entries", :force => true do |t|
    t.integer  "probe_map_id",     :null => false
    t.integer  "probe_id",         :null => false
    t.integer  "coding_region_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "probe_maps", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "publications", :force => true do |t|
    t.integer  "pubmed_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scaffolds", :force => true do |t|
    t.integer  "species_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scaffolds", ["species_id"], :name => "index_scaffolds_on_species_id"

  create_table "scripts", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sequences", :force => true do |t|
    t.string   "type",             :null => false
    t.integer  "coding_region_id", :null => false
    t.text     "sequence",         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sequences", ["coding_region_id", "type"], :name => "index_sequences_on_coding_region_id_and_type", :unique => true

  create_table "signal_ps", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "species", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "orthomcl_three_letter"
  end

  create_table "taxon_names", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taxons", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "top_level_localisations", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transmembrane_domain_measurements", :force => true do |t|
    t.integer  "coding_region_id"
    t.decimal  "measurement",                                                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",             :default => "MinTransmembraneDomainLength", :null => false
  end

  add_index "transmembrane_domain_measurements", ["coding_region_id", "type"], :name => "index_min_transmembrane_domain_lengths_on_coding_region_id_and_", :unique => true
  add_index "transmembrane_domain_measurements", ["coding_region_id"], :name => "index_transmembrane_domain_measurements_on_coding_region_id"

  create_table "transmembrane_domains", :force => true do |t|
    t.integer  "coding_region_id", :null => false
    t.integer  "start",            :null => false
    t.integer  "stop",             :null => false
    t.string   "type",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transmembrane_domains", ["coding_region_id", "type"], :name => "index_transmembrane_domains_on_coding_region_id_and_type"

  create_table "verifications", :force => true do |t|
  end

  create_table "yeast_pheno_infos", :force => true do |t|
    t.string   "experiment_type", :null => false
    t.string   "phenotype",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
