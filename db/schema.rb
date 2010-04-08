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

ActiveRecord::Schema.define(:version => 20100213235446) do

  create_table "annotations", :force => true do |t|
    t.integer  "coding_region_id"
    t.text     "annotation",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["annotation", "coding_region_id"], :name => "index_annotations_on_coding_region_id_and_annotation", :unique => true
  add_index "annotations", ["coding_region_id"], :name => "index_annotations_on_coding_region_id"

  create_table "binary_coding_region_measurements", :force => true do |t|
    t.integer  "coding_region_id", :null => false
    t.boolean  "value"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "binary_coding_region_measurements", ["coding_region_id", "type"], :name => "index_binary_coding_region_measurements_on_coding_region_id_and"
  add_index "binary_coding_region_measurements", ["coding_region_id"], :name => "index_binary_coding_region_measurements_on_coding_region_id"

  create_table "blast_hits", :force => true do |t|
    t.integer  "coding_region_id",     :null => false
    t.integer  "hit_coding_region_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blast_hits", ["coding_region_id", "hit_coding_region_id"], :name => "index_blast_hits_on_coding_region_id_and_hit_coding_region_id", :unique => true
  add_index "blast_hits", ["coding_region_id"], :name => "index_blast_hits_on_coding_region_id"

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
    t.integer  "order"
  end

  add_index "cds", ["coding_region_id", "order"], :name => "index_cds_on_order_and_coding_region_id"
  add_index "cds", ["coding_region_id", "start"], :name => "index_cds_on_start_and_coding_region_id"
  add_index "cds", ["coding_region_id", "stop"], :name => "index_cds_on_stop_and_coding_region_id"
  add_index "cds", ["coding_region_id"], :name => "index_cds_on_coding_region_id"
  add_index "cds", ["order"], :name => "index_cds_on_order"
  add_index "cds", ["start"], :name => "index_cds_on_start"
  add_index "cds", ["stop"], :name => "index_cds_on_stop"

  create_table "chromosomal_features", :force => true do |t|
    t.integer  "start",       :null => false
    t.integer  "stop",        :null => false
    t.integer  "scaffold_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",        :null => false
    t.integer  "value",       :null => false
  end

  add_index "chromosomal_features", ["scaffold_id"], :name => "index_chromosomal_features_on_scaffold_id"

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
    t.integer  "coding_region_id", :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "source"
  end

  add_index "coding_region_alternate_string_ids", ["coding_region_id", "name", "source"], :name => "index_coding_region_alternate_string_ids_on_coding_region_id_an"
  add_index "coding_region_alternate_string_ids", ["coding_region_id", "name", "type"], :name => "index4", :unique => true
  add_index "coding_region_alternate_string_ids", ["coding_region_id", "name"], :name => "index3"
  add_index "coding_region_alternate_string_ids", ["coding_region_id", "type", "name"], :name => "index2"
  add_index "coding_region_alternate_string_ids", ["coding_region_id", "type"], :name => "index1"
  add_index "coding_region_alternate_string_ids", ["coding_region_id"], :name => "index_coding_region_alternate_string_ids_on_coding_region_id"
  add_index "coding_region_alternate_string_ids", ["name"], :name => "index_coding_region_alternate_string_ids_on_name"

  create_table "coding_region_drosophila_allele_genes", :force => true do |t|
    t.integer  "coding_region_id",          :null => false
    t.integer  "drosophila_allele_gene_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_drosophila_allele_genes", ["coding_region_id"], :name => "index_coding_region_drosophila_allele_genes_on_coding_region_id"
  add_index "coding_region_drosophila_allele_genes", ["drosophila_allele_gene_id"], :name => "index_coding_region_drosophila_allele_genes_on_drosophila_allel"

  create_table "coding_region_drosophila_rnai_lethalities", :force => true do |t|
    t.integer  "coding_region_id",             :null => false
    t.integer  "drosophila_rnai_lethality_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coding_region_go_terms", :force => true do |t|
    t.integer "coding_region_id"
    t.integer "go_term_id"
    t.string  "evidence_code"
  end

  add_index "coding_region_go_terms", ["coding_region_id", "evidence_code", "go_term_id"], :name => "index_coding_region_go_terms_on_coding_region_id_and_go_term_id", :unique => true
  add_index "coding_region_go_terms", ["coding_region_id", "go_term_id", "evidence_code"], :name => "cge"
  add_index "coding_region_go_terms", ["coding_region_id", "go_term_id"], :name => "code_go"

  create_table "coding_region_localisations", :force => true do |t|
    t.integer  "coding_region_id",       :null => false
    t.integer  "localisation_id",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "localisation_method_id", :null => false
  end

  add_index "coding_region_localisations", ["coding_region_id", "localisation_id", "localisation_method_id"], :name => "index_coding_region_localisations_on_coding_region_id_and_local", :unique => true
  add_index "coding_region_localisations", ["coding_region_id", "localisation_id", "localisation_method_id"], :name => "index_coding_region_localisations_on_localisation_id_and_coding", :unique => true

  create_table "coding_region_mouse_phenotypes", :force => true do |t|
    t.integer  "coding_region_id"
    t.integer  "mouse_phenotype_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_mouse_phenotypes", ["coding_region_id", "mouse_phenotype_id"], :name => "index_coding_region_mouse_phenotype_informations_on_coding_regi", :unique => true

  create_table "coding_region_network_edges", :force => true do |t|
    t.integer  "network_id",              :null => false
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
  add_index "coding_region_phenotype_informations", ["coding_region_id"], :name => "index_coding_region_phenotype_informations_on_coding_region_id"
  add_index "coding_region_phenotype_informations", ["phenotype_information_id"], :name => "index_coding_region_phenotype_informations_on_phenotype_informa"

  create_table "coding_region_phenotype_observeds", :force => true do |t|
    t.integer  "coding_region_id"
    t.integer  "phenotype_observed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_phenotype_observeds", ["coding_region_id", "phenotype_observed_id"], :name => "index_coding_region_phenotype_observeds_on_coding_region_id_and", :unique => true

  create_table "coding_region_strain_orthologues", :force => true do |t|
    t.integer  "coding_region_id", :null => false
    t.string   "name",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_strain_orthologues", ["coding_region_id"], :name => "index_coding_region_strain_orthologues_on_coding_region_id"
  add_index "coding_region_strain_orthologues", ["name"], :name => "index_coding_region_strain_orthologues_on_name"

  create_table "coding_region_yeast_pheno_infos", :force => true do |t|
    t.integer  "coding_region_id",    :null => false
    t.integer  "yeast_pheno_info_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "coding_region_yeast_pheno_infos", ["coding_region_id", "yeast_pheno_info_id"], :name => "index_coding_region_yeast_pheno_infos_on_coding_region_id_and_y", :unique => true
  add_index "coding_region_yeast_pheno_infos", ["coding_region_id"], :name => "index_coding_region_yeast_pheno_infos_on_coding_region_id"
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
  add_index "coding_regions", ["string_id", "gene_id"], :name => "index_coding_regions_on_string_id_and_gene_id", :unique => true
  add_index "coding_regions", ["string_id"], :name => "index_coding_regions_on_string_id"

  create_table "comments", :force => true do |t|
    t.integer  "localisation_annotation_id", :null => false
    t.text     "comment",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["localisation_annotation_id"], :name => "index_comments_on_expression_context_id"

  create_table "consensus_sequences", :force => true do |t|
    t.integer  "nls_db_id"
    t.string   "type",       :null => false
    t.string   "signal",     :null => false
    t.string   "annotation"
    t.integer  "pubmed_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "conserved_domains", :force => true do |t|
    t.integer  "coding_region_id", :null => false
    t.string   "type",             :null => false
    t.string   "identifier",       :null => false
    t.integer  "start",            :null => false
    t.integer  "stop",             :null => false
    t.float    "score",            :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "conserved_domains", ["coding_region_id", "type"], :name => "index_conserved_domains_on_coding_region_id_and_type"

  create_table "curated_top_level_localisations", :force => true do |t|
    t.integer  "coding_region_id",          :null => false
    t.integer  "top_level_localisation_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "curated_top_level_localisations", ["coding_region_id", "top_level_localisation_id"], :name => "index_curated_top_level_localisations_on_coding_region_id_and_t", :unique => true
  add_index "curated_top_level_localisations", ["coding_region_id"], :name => "index_curated_top_level_localisations_on_coding_region_id"

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

  create_table "developmental_stage_top_level_developmental_stages", :force => true do |t|
    t.integer  "developmental_stage_id"
    t.integer  "top_level_developmental_stage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "developmental_stages", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "species_id", :null => false
  end

  add_index "developmental_stages", ["name", "species_id"], :name => "index_developmental_stages_on_name_and_species_id", :unique => true

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

  create_table "drosophila_rnai_lethalities", :force => true do |t|
    t.string   "lethality",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "drosophila_rnai_lethalities", ["lethality"], :name => "index_drosophila_rnai_lethalities_on_lethality", :unique => true

  create_table "export_preds", :force => true do |t|
    t.integer  "coding_region_id", :null => false
    t.boolean  "predicted"
    t.decimal  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expression_contexts", :force => true do |t|
    t.integer  "coding_region_id",           :null => false
    t.integer  "publication_id"
    t.integer  "localisation_id"
    t.integer  "developmental_stage_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "localisation_modifier_id"
    t.integer  "localisation_annotation_id", :null => false
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

  add_index "gene_network_edges", ["gene_id_first", "gene_id_second", "gene_network_id"], :name => "index_gene_network_edges_on_gene_network_id_and_gene_id_first_a", :unique => true
  add_index "gene_network_edges", ["gene_id_first"], :name => "index_gene_network_edges_on_gene_id_first"
  add_index "gene_network_edges", ["gene_id_second"], :name => "index_gene_network_edges_on_gene_id_second"

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

  create_table "go_synonyms", :force => true do |t|
    t.text     "synonym",    :null => false
    t.integer  "go_term_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "go_synonyms", ["go_term_id"], :name => "index_go_synonyms_on_go_term_id"
  add_index "go_synonyms", ["synonym", "go_term_id"], :name => "index_go_synonyms_on_synonym_and_go_term_id", :unique => true
  add_index "go_synonyms", ["synonym"], :name => "index_go_synonyms_on_synonym"

  create_table "go_term_localisations", :force => true do |t|
    t.integer  "go_term_id",      :null => false
    t.integer  "localisation_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "go_term_localisations", ["go_term_id"], :name => "index_go_term_localisations_on_go_term_id"
  add_index "go_term_localisations", ["localisation_id"], :name => "index_go_term_localisations_on_localisation_id"

  create_table "go_term_offsprings", :force => true do |t|
    t.integer  "go_term_id",           :null => false
    t.integer  "offspring_go_term_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "go_term_offsprings", ["go_term_id", "offspring_go_term_id"], :name => "index_go_term_offsprings_on_go_term_id_and_offspring_go_term_id", :unique => true
  add_index "go_term_offsprings", ["go_term_id"], :name => "index_go_term_offsprings_on_go_term_id"

  create_table "go_terms", :force => true do |t|
    t.string   "go_identifier"
    t.string   "term"
    t.string   "aspect"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "go_terms", ["aspect", "go_identifier", "term"], :name => "index_go_terms_on_go_identifier_and_term_and_aspect"
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

  create_table "kawaii_snippets", :force => true do |t|
    t.string "key",   :limit => 50
    t.text   "value"
  end

  create_table "localisation_annotations", :force => true do |t|
    t.text     "localisation"
    t.text     "gene_mapping_comments"
    t.string   "microscopy_type"
    t.string   "microscopy_method"
    t.text     "quote"
    t.string   "strain"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "coding_region_id",      :null => false
  end

  create_table "localisation_methods", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "localisation_methods", ["description"], :name => "index_localisation_methods_on_description", :unique => true

  create_table "localisation_modifiers", :force => true do |t|
    t.string   "modifier",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  add_index "localisation_top_level_localisations", ["localisation_id", "top_level_localisation_id", "type"], :name => "index_localisation_top_level_localisations_on_type_and_localisa"
  add_index "localisation_top_level_localisations", ["localisation_id", "type"], :name => "index_localisation_top_level_localisations_on_localisation_id_a"
  add_index "localisation_top_level_localisations", ["top_level_localisation_id", "type"], :name => "index_localisation_top_level_localisations_on_top_level_localis"

  create_table "localisations", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "species_id", :null => false
  end

  add_index "localisations", ["name", "species_id"], :name => "index_localisations_on_name_and_species_id", :unique => true

  create_table "meta_microarray_measurements", :force => true do |t|
    t.string   "type",                    :null => false
    t.integer  "microarray_timepoint_id", :null => false
    t.decimal  "measurement",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "meta_microarray_measurements", ["microarray_timepoint_id", "type"], :name => "index_meta_microarray_measurements_on_type_and_microarray_timep"

  create_table "microarray_measurements", :force => true do |t|
    t.integer  "microarray_timepoint_id", :null => false
    t.decimal  "measurement",             :null => false
    t.integer  "coding_region_id",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "microarray_measurements", ["coding_region_id", "measurement", "microarray_timepoint_id"], :name => "index_microarray_measurements_on_microarray_timepoint_id_and_co"
  add_index "microarray_measurements", ["coding_region_id", "microarray_timepoint_id"], :name => "index_microarray_measurements_on_coding_region_id_and_microarra"
  add_index "microarray_measurements", ["coding_region_id"], :name => "index_microarray_measurements_on_coding_region_id"
  add_index "microarray_measurements", ["measurement", "microarray_timepoint_id"], :name => "index_microarray_measurements_on_microarray_timepoint_id_and_me"
  add_index "microarray_measurements", ["microarray_timepoint_id"], :name => "index_microarray_measurements_on_microarray_timepoint_id"

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

  create_table "mouse_phenotype_dictionary_entries", :force => true do |t|
    t.string   "pheno_id",   :null => false
    t.string   "pheno_desc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mouse_phenotype_dictionary_entries", ["pheno_desc", "pheno_id"], :name => "index_mouse_pheno_descs_on_pheno_desc_and_pheno_id", :unique => true
  add_index "mouse_phenotype_dictionary_entries", ["pheno_id"], :name => "index_mouse_pheno_descs_on_pheno_id", :unique => true

  create_table "mouse_phenotype_mouse_phenotype_dictionary_entries", :force => true do |t|
    t.integer  "mouse_phenotype_id",                  :null => false
    t.integer  "mouse_phenotype_dictionary_entry_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mouse_phenotype_mouse_phenotype_dictionary_entries", ["mouse_phenotype_dictionary_entry_id", "mouse_phenotype_id"], :name => "index_mouse_phenotype_mouse_phenotype_dictionary_entries_on_mou", :unique => true

  create_table "mouse_phenotypes", :force => true do |t|
    t.string   "mgi_allele",  :null => false
    t.string   "allele_type"
    t.string   "mgi_marker"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mverifications", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "my_caches", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "cache",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "my_caches", ["name"], :name => "index_my_caches_on_name"

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

  add_index "orthomcl_gene_coding_regions", ["coding_region_id", "orthomcl_gene_id"], :name => "index_orthomcl_gene_coding_regions_on_coding_region_id_and_orth", :unique => true
  add_index "orthomcl_gene_coding_regions", ["coding_region_id"], :name => "index_orthomcl_gene_coding_regions_on_coding_region_id"
  add_index "orthomcl_gene_coding_regions", ["orthomcl_gene_id"], :name => "index_orthomcl_gene_coding_regions_on_orthomcl_gene_id"

  create_table "orthomcl_gene_official_datas", :force => true do |t|
    t.integer  "orthomcl_gene_id"
    t.text     "sequence"
    t.text     "annotation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_gene_official_datas", ["orthomcl_gene_id"], :name => "index_orthomcl_gene_official_datas_on_orthomcl_gene_id", :unique => true

  create_table "orthomcl_gene_orthomcl_group_orthomcl_runs", :force => true do |t|
    t.integer  "orthomcl_gene_id",  :null => false
    t.integer  "orthomcl_group_id"
    t.integer  "orthomcl_run_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_gene_orthomcl_group_orthomcl_runs", ["orthomcl_gene_id", "orthomcl_group_id", "orthomcl_run_id"], :name => "ogogor", :unique => true
  add_index "orthomcl_gene_orthomcl_group_orthomcl_runs", ["orthomcl_gene_id", "orthomcl_run_id"], :name => "ogog", :unique => true
  add_index "orthomcl_gene_orthomcl_group_orthomcl_runs", ["orthomcl_group_id"], :name => "index_orthomcl_gene_orthomcl_group_orthomcl_runs_on_orthomcl_gr"

  create_table "orthomcl_genes", :force => true do |t|
    t.string   "orthomcl_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_genes", ["orthomcl_name"], :name => "index_orthomcl_genes_on_orthomcl_name"

  create_table "orthomcl_groups", :force => true do |t|
    t.string   "orthomcl_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_groups", ["orthomcl_name"], :name => "index_orthomcl_groups_on_orthomcl_name"

  create_table "orthomcl_localisation_conservations", :force => true do |t|
    t.integer  "orthomcl_group_id", :null => false
    t.string   "conservation",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_localisation_conservations", ["conservation"], :name => "index_orthomcl_localisation_conservations_on_conservation"
  add_index "orthomcl_localisation_conservations", ["orthomcl_group_id"], :name => "index_orthomcl_localisation_conservations_on_orthomcl_group_id"

  create_table "orthomcl_runs", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orthomcl_runs", ["name"], :name => "index_orthomcl_runs_on_name", :unique => true

  create_table "pfalciparum_tiling_arrays", :force => true do |t|
    t.string  "probe",         :null => false
    t.string  "sequence",      :null => false
    t.decimal "hb3_1",         :null => false
    t.decimal "hb3_2",         :null => false
    t.decimal "three_d7_1",    :null => false
    t.decimal "three_d7_2",    :null => false
    t.decimal "dd2_1",         :null => false
    t.decimal "dd2_2",         :null => false
    t.decimal "dd2_fosr_1",    :null => false
    t.decimal "dd2_fosr_2",    :null => false
    t.decimal "three_d7_attb", :null => false
  end

  add_index "pfalciparum_tiling_arrays", ["probe"], :name => "index_pfalciparum_tiling_arrays_on_probe", :unique => true
  add_index "pfalciparum_tiling_arrays", ["sequence"], :name => "index_pfalciparum_tiling_arrays_on_sequence"

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

  create_table "plasmit_results", :force => true do |t|
    t.integer  "coding_region_id",  :null => false
    t.string   "prediction_string", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "plasmit_results", ["coding_region_id"], :name => "index_plasmit_results_on_coding_region_id"

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

  add_index "probe_map_entries", ["probe_id", "probe_map_id"], :name => "index_probe_map_entries_on_probe_map_id_and_probe_id"

  create_table "probe_maps", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proteomic_experiment_peptides", :force => true do |t|
    t.integer  "coding_region_id"
    t.integer  "proteomic_experiment_id"
    t.string   "peptide"
    t.string   "charge"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proteomic_experiment_peptides", ["coding_region_id", "proteomic_experiment_id", "peptide", "charge"], :name => "index_proteomic_experiment_peptides_on_coding_region_id_and_pro", :unique => true
  add_index "proteomic_experiment_peptides", ["coding_region_id"], :name => "index_proteomic_experiment_peptides_on_coding_region_id"

  create_table "proteomic_experiment_results", :force => true do |t|
    t.integer  "coding_region_id",        :null => false
    t.integer  "number_of_peptides"
    t.float    "spectrum"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "percentage"
    t.integer  "proteomic_experiment_id", :null => false
  end

  create_table "proteomic_experiments", :force => true do |t|
    t.string   "name",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "publication_id", :null => false
  end

  create_table "publications", :force => true do |t|
    t.integer  "pubmed_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "title"
    t.text     "authors"
    t.text     "abstract"
    t.string   "date"
    t.string   "journal"
  end

  create_table "scaffolds", :force => true do |t|
    t.integer  "species_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "length"
  end

  add_index "scaffolds", ["species_id"], :name => "index_scaffolds_on_species_id"

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
    t.integer  "coding_region_id",     :null => false
    t.decimal  "nn_Cmax",              :null => false
    t.integer  "nn_Cmax_position",     :null => false
    t.boolean  "nn_Cmax_prediction",   :null => false
    t.decimal  "nn_Ymax",              :null => false
    t.integer  "nn_Ymax_position",     :null => false
    t.boolean  "nn_Ymax_prediction",   :null => false
    t.decimal  "nn_Smax",              :null => false
    t.integer  "nn_Smax_position",     :null => false
    t.boolean  "nn_Smax_prediction",   :null => false
    t.decimal  "nn_Smean",             :null => false
    t.boolean  "nn_Smean_prediction",  :null => false
    t.decimal  "nn_D",                 :null => false
    t.boolean  "nn_D_prediction",      :null => false
    t.decimal  "hmm_result",           :null => false
    t.decimal  "hmm_Cmax",             :null => false
    t.integer  "hmm_Cmax_position",    :null => false
    t.boolean  "hmm_Cmax_prediction",  :null => false
    t.decimal  "hmm_Sprob",            :null => false
    t.boolean  "hmm_Sprob_prediction", :null => false
  end

  add_index "signal_ps", ["coding_region_id"], :name => "index_signal_ps_on_coding_region_id", :unique => true

  create_table "species", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "orthomcl_three_letter"
  end

  create_table "string_coding_region_measurements", :force => true do |t|
    t.string   "measurement"
    t.integer  "coding_region_id", :null => false
    t.string   "type",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "string_coding_region_measurements", ["coding_region_id", "measurement", "type"], :name => "strind_code_ctm"
  add_index "string_coding_region_measurements", ["coding_region_id", "type"], :name => "index_string_coding_region_measurements_on_coding_region_id_and"

  create_table "taxon_names", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taxons", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "top_level_developmental_stages", :force => true do |t|
    t.string   "name",       :null => false
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

  add_index "transmembrane_domain_measurements", ["coding_region_id"], :name => "index_transmembrane_domain_measurements_on_coding_region_id"

  create_table "transmembrane_domains", :force => true do |t|
    t.integer  "coding_region_id", :null => false
    t.integer  "start",            :null => false
    t.integer  "stop",             :null => false
    t.string   "type",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "orientation"
  end

  add_index "transmembrane_domains", ["coding_region_id", "type"], :name => "index_transmembrane_domains_on_coding_region_id_and_type"

  create_table "user_comments", :force => true do |t|
    t.string   "title",            :limit => 50, :null => false
    t.string   "comment",                        :null => false
    t.integer  "user_id"
    t.integer  "coding_region_id",               :null => false
    t.integer  "number",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_comments", ["coding_region_id", "number"], :name => "index_user_comments_on_coding_region_id_and_number", :unique => true
  add_index "user_comments", ["coding_region_id"], :name => "index_user_comments_on_coding_region_id"

  create_table "wolf_psort_predictions", :force => true do |t|
    t.integer  "coding_region_id"
    t.string   "organism_type"
    t.string   "localisation"
    t.decimal  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wolf_psort_predictions", ["coding_region_id"], :name => "index_wolf_psort_predictions_on_coding_region_id"

  create_table "yeast_pheno_infos", :force => true do |t|
    t.string   "experiment_type", :null => false
    t.string   "phenotype",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "mutant_type",     :null => false
  end

  add_foreign_key "blast_hits", "coding_regions", :name => "blast_hits_coding_region_id_fk", :dependent => :delete

  add_foreign_key "cds", "coding_regions", :name => "cds_coding_region_id_fk", :dependent => :delete

  add_foreign_key "chromosomal_features", "scaffolds", :name => "chromosomal_features_scaffold_id_fk", :dependent => :delete

  add_foreign_key "cluster_entries", "clusters", :name => "cluster_entries_cluster_id_fk", :dependent => :delete

  add_foreign_key "clusters", "clustersets", :name => "clusters_clusterset_id_fk", :dependent => :delete

  add_foreign_key "coding_region_alternate_string_ids", "coding_regions", :name => "coding_region_alternate_string_ids_coding_region_id_fk", :dependent => :delete

  add_foreign_key "coding_region_drosophila_allele_genes", "coding_regions", :name => "coding_region_drosophila_allele_genes_coding_region_id_fk", :dependent => :delete

  add_foreign_key "coding_region_drosophila_rnai_lethalities", "coding_regions", :name => "coding_region_drosophila_rnai_lethalities_coding_region_id_fk", :dependent => :delete
  add_foreign_key "coding_region_drosophila_rnai_lethalities", "drosophila_rnai_lethalities", :name => "coding_region_drosophila_rnai_lethalities_drosophila_rnai_letha", :dependent => :delete

  add_foreign_key "coding_region_go_terms", "coding_regions", :name => "coding_region_go_terms_coding_region_id_fk", :dependent => :delete
  add_foreign_key "coding_region_go_terms", "go_terms", :name => "coding_region_go_terms_go_term_id_fk", :dependent => :delete

  add_foreign_key "coding_region_localisations", "coding_regions", :name => "coding_region_localisations_coding_region_id_fk", :dependent => :delete
  add_foreign_key "coding_region_localisations", "localisations", :name => "coding_region_localisations_localisation_id_fk", :dependent => :delete

  add_foreign_key "coding_region_mouse_phenotypes", "coding_regions", :name => "coding_region_mouse_phenotypes_coding_region_id_fk", :dependent => :delete
  add_foreign_key "coding_region_mouse_phenotypes", "mouse_phenotypes", :name => "coding_region_mouse_phenotypes_mouse_phenotype_id_fk", :dependent => :delete

  add_foreign_key "coding_region_network_edges", "networks", :name => "coding_region_network_edges_network_id_fk", :dependent => :delete

  add_foreign_key "coding_region_phenotype_informations", "coding_regions", :name => "coding_region_phenotype_informations_coding_region_id_fk", :dependent => :delete
  add_foreign_key "coding_region_phenotype_informations", "phenotype_informations", :name => "coding_region_phenotype_informations_phenotype_information_id_f", :dependent => :delete

  add_foreign_key "coding_region_phenotype_observeds", "coding_regions", :name => "coding_region_phenotype_observeds_coding_region_id_fk", :dependent => :delete
  add_foreign_key "coding_region_phenotype_observeds", "phenotype_observeds", :name => "coding_region_phenotype_observeds_phenotype_observed_id_fk", :dependent => :delete

  add_foreign_key "coding_region_strain_orthologues", "coding_regions", :name => "coding_region_strain_orthologues_coding_region_id_fk", :dependent => :delete

  add_foreign_key "coding_region_yeast_pheno_infos", "coding_regions", :name => "coding_region_yeast_pheno_infos_coding_region_id_fk", :dependent => :delete
  add_foreign_key "coding_region_yeast_pheno_infos", "yeast_pheno_infos", :name => "coding_region_yeast_pheno_infos_yeast_pheno_info_id_fk", :dependent => :delete

  add_foreign_key "coding_regions", "genes", :name => "coding_regions_gene_id_fk", :dependent => :delete

  add_foreign_key "conserved_domains", "coding_regions", :name => "conserved_domains_coding_region_id_fk", :dependent => :delete

  add_foreign_key "curated_top_level_localisations", "coding_regions", :name => "curated_top_level_localisations_coding_region_id_fk", :dependent => :delete

  add_foreign_key "drosophila_allele_phenotype_drosophila_allele_genes", "drosophila_allele_phenotypes", :name => "drosophila_allele_phenotype_drosophila_allele_genes_drosophila_", :dependent => :delete

  add_foreign_key "expression_contexts", "coding_regions", :name => "expression_contexts_coding_region_id_fk", :dependent => :delete
  add_foreign_key "expression_contexts", "developmental_stages", :name => "expression_contexts_developmental_stage_id_fk", :dependent => :delete
  add_foreign_key "expression_contexts", "localisations", :name => "expression_contexts_localisation_id_fk", :dependent => :delete
  add_foreign_key "expression_contexts", "publications", :name => "expression_contexts_publication_id_fk", :dependent => :delete

  add_foreign_key "gene_alternate_names", "genes", :name => "gene_alternate_names_gene_id_fk", :dependent => :delete

  add_foreign_key "gene_network_edges", "gene_networks", :name => "gene_network_edges_gene_network_id_fk", :dependent => :delete

  add_foreign_key "genes", "scaffolds", :name => "genes_scaffold_id_fk", :dependent => :delete

  add_foreign_key "go_alternates", "go_terms", :name => "go_alternates_go_term_id_fk", :dependent => :delete

  add_foreign_key "go_synonyms", "go_terms", :name => "go_synonyms_go_term_id_fk", :dependent => :delete

  add_foreign_key "integer_coding_region_measurements", "coding_regions", :name => "integer_coding_region_measurements_coding_region_id_fk", :dependent => :delete

  add_foreign_key "localisation_annotations", "coding_regions", :name => "localisation_annotations_coding_region_id_fk", :dependent => :delete

  add_foreign_key "localisation_synonyms", "localisations", :name => "localisation_synonyms_localisation_id_fk", :dependent => :delete

  add_foreign_key "microarray_measurements", "coding_regions", :name => "microarray_measurements_coding_region_id_fk", :dependent => :delete
  add_foreign_key "microarray_measurements", "microarray_timepoints", :name => "microarray_measurements_microarray_timepoint_id_fk", :dependent => :delete

  add_foreign_key "microarray_timepoints", "microarrays", :name => "microarray_timepoints_microarray_id_fk", :dependent => :delete

  add_foreign_key "mouse_phenotype_mouse_phenotype_dictionary_entries", "mouse_phenotype_dictionary_entries", :name => "mouse_phenotype_mouse_phenotype_dictionary_entries_mouse_phenot", :dependent => :delete
  add_foreign_key "mouse_phenotype_mouse_phenotype_dictionary_entries", "mouse_phenotypes", :name => "fk1", :dependent => :delete

  add_foreign_key "orthomcl_gene_coding_regions", "coding_regions", :name => "orthomcl_gene_coding_regions_coding_region_id_fk", :dependent => :delete
  add_foreign_key "orthomcl_gene_coding_regions", "orthomcl_genes", :name => "orthomcl_gene_coding_regions_orthomcl_gene_id_fk", :dependent => :delete

  add_foreign_key "orthomcl_gene_orthomcl_group_orthomcl_runs", "orthomcl_genes", :name => "orthomcl_gene_orthomcl_group_orthomcl_runs_orthomcl_gene_id_fk", :dependent => :delete
  add_foreign_key "orthomcl_gene_orthomcl_group_orthomcl_runs", "orthomcl_groups", :name => "orthomcl_gene_orthomcl_group_orthomcl_runs_orthomcl_group_id_fk", :dependent => :delete
  add_foreign_key "orthomcl_gene_orthomcl_group_orthomcl_runs", "orthomcl_runs", :name => "orthomcl_gene_orthomcl_group_orthomcl_runs_orthomcl_run_id_fk", :dependent => :delete

  add_foreign_key "plasmodb_gene_list_entries", "plasmodb_gene_lists", :name => "plasmodb_gene_list_entries_plasmodb_gene_list_id_fk", :dependent => :delete

  add_foreign_key "probe_map_entries", "probe_maps", :name => "probe_map_entries_probe_map_id_fk", :dependent => :delete

  add_foreign_key "proteomic_experiment_peptides", "coding_regions", :name => "proteomic_experiment_peptides_coding_region_id_fk", :dependent => :delete
  add_foreign_key "proteomic_experiment_peptides", "proteomic_experiments", :name => "proteomic_experiment_peptides_proteomic_experiment_id_fk", :dependent => :delete

  add_foreign_key "proteomic_experiment_results", "coding_regions", :name => "proteomic_experiment_results_coding_region_id_fk", :dependent => :delete
  add_foreign_key "proteomic_experiment_results", "proteomic_experiments", :name => "proteomic_experiment_results_proteomic_experiment_id_fk", :dependent => :delete

  add_foreign_key "proteomic_experiments", "publications", :name => "proteomic_experiments_publication_id_fk", :dependent => :delete

  add_foreign_key "scaffolds", "species", :name => "scaffolds_species_id_fk", :dependent => :delete

  add_foreign_key "transmembrane_domain_measurements", "coding_regions", :name => "transmembrane_domain_measurements_coding_region_id_fk", :dependent => :delete

end
