class AddForeignKeysRetrospectively < ActiveRecord::Migration
  def self.up
    #    add_foreign_key :microarray_timepoints,  :microarrays, :dependent => :delete #example, included below
    # NOTE: some are commented out because they refer to subclasses, not table names
    
    #  has_many :coding_region_drosophila_rnai_lethalities, :dependent => :destroy
    add_foreign_key :coding_region_drosophila_rnai_lethalities, :drosophila_rnai_lethalities, :dependent => :delete
    #  has_many :coding_region_phenotype_informations, :dependent => :destroy
    add_foreign_key :coding_region_phenotype_informations, :phenotype_informations, :dependent => :delete
    #  has_many :coding_region_phenotype_observeds, :dependent => :destroy
    add_foreign_key :coding_region_phenotype_observeds, :phenotype_observeds, :dependent => :delete
    #  has_many :scaffolds, :dependent => :destroy
    add_foreign_key :scaffolds, :species, :dependent => :delete
    #  has_many :gene_network_edges, :dependent => :destroy
    add_foreign_key :gene_network_edges, :gene_networks, :dependent => :delete
    #  has_many :expression_contexts, :dependent => :destroy
    add_foreign_key :expression_contexts, :developmental_stages, :dependent => :delete
    #  has_many :genes, :dependent => :destroy
    add_foreign_key :genes, :scaffolds, :dependent => :delete
    #  has_many :chromosomal_features, :dependent => :destroy
    add_foreign_key :chromosomal_features, :scaffolds, :dependent => :delete
    #    #  has_many :jiang_7g8_ten_kb_bin_sfp_counts, :dependent => :destroy, :class_name => 'Jiang7G8TenKbBinSfpCount'
    #    add_foreign_key :jiang_7g8_ten_kb_bin_sfp_counts, :scaffolds, :dependent => :delete
    #    #  has_many :jiang_fcr3_ten_kb_bin_sfp_counts, :dependent => :destroy, :class_name => 'JiangFCR3TenKbBinSfpCount'
    #    add_foreign_key :jiang_fcr3_ten_kb_bin_sfp_counts, :scaffolds, :dependent => :delete
    #    #  has_many :jiang_dd2_ten_kb_bin_sfp_counts, :dependent => :destroy, :class_name => 'JiangDd2TenKbBinSfpCount'
    #    add_foreign_key :jiang_dd2_ten_kb_bin_sfp_counts, :scaffolds, :dependent => :delete
    #    #  has_many :jiang_hb3_ten_kb_bin_sfp_counts, :dependent => :destroy, :class_name => 'JiangHB3TenKbBinSfpCount'
    #    add_foreign_key :jiang_hb3_ten_kb_bin_sfp_counts, :scaffolds, :dependent => :delete
    #  has_many :proteomic_experiment_results, :dependent => :destroy
    add_foreign_key :proteomic_experiment_results, :proteomic_experiments, :dependent => :delete
    #  has_many :proteomic_experiment_peptides, :dependent => :destroy
    add_foreign_key :proteomic_experiment_peptides, :proteomic_experiments, :dependent => :delete
    #  has_many :coding_region_localisations, :dependent => :destroy
    add_foreign_key :coding_region_localisations, :localisations, :dependent => :delete
    #  has_many :expression_contexts, :dependent => :destroy
    add_foreign_key :expression_contexts, :localisations, :dependent => :delete
    #  has_many :localisation_synonyms, :dependent => :destroy
    add_foreign_key :localisation_synonyms, :localisations, :dependent => :delete
    #  has_many :mouse_phenotype_mouse_phenotype_dictionary_entries, :dependent => :destroy
    add_foreign_key :mouse_phenotype_mouse_phenotype_dictionary_entries, :mouse_phenotype_dictionary_entries, :dependent => :delete
    #  has_many :plasmodb_gene_list_entries, :dependent => :destroy
    add_foreign_key :plasmodb_gene_list_entries, :plasmodb_gene_lists, :dependent => :delete
    #  has_many :cluster_entries, :dependent => :destroy
    add_foreign_key :cluster_entries, :clusters, :dependent => :delete
    #  has_many :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
    add_foreign_key :orthomcl_gene_orthomcl_group_orthomcl_runs, :orthomcl_runs, :dependent => :delete
    #  has_many :microarray_timepoints, :dependent => :destroy
    add_foreign_key :microarray_timepoints, :microarrays, :dependent => :delete
    #  has_many :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
    add_foreign_key :orthomcl_gene_orthomcl_group_orthomcl_runs, :orthomcl_genes, :dependent => :delete
    #  has_many :orthomcl_gene_coding_regions, :dependent => :destroy
    add_foreign_key :orthomcl_gene_coding_regions, :orthomcl_genes, :dependent => :delete
    #  has_many :coding_region_go_terms, :dependent => :destroy
    add_foreign_key :coding_region_go_terms, :go_terms, :dependent => :delete
    #  has_many :go_alternates, :dependent => :destroy
    add_foreign_key :go_alternates, :go_terms, :dependent => :delete
    #  has_many :go_synonyms, :dependent => :destroy
    add_foreign_key :go_synonyms, :go_terms, :dependent => :delete
    #  has_many :coding_region_yeast_pheno_infos, :dependent => :destroy
    add_foreign_key :coding_region_yeast_pheno_infos, :yeast_pheno_infos, :dependent => :delete
    #  has_many :clusters, :dependent => :destroy
    add_foreign_key :clusters, :clustersets, :dependent => :delete
    #  has_many :probe_map_entries, :dependent => :destroy
    add_foreign_key :probe_map_entries, :probe_maps, :dependent => :delete
    #  has_many :coding_region_go_terms, :dependent => :destroy
    add_foreign_key :coding_region_go_terms, :coding_regions, :dependent => :delete
    #  has_many :cds, :dependent => :destroy
    add_foreign_key :cds, :coding_regions, :dependent => :delete
    #  has_many :coding_region_alternate_string_ids, :dependent => :destroy
    add_foreign_key :coding_region_alternate_string_ids, :coding_regions, :dependent => :delete
#    #  has_many :literature_defined_coding_region_alternate_string_ids, :dependent => :destroy
#    add_foreign_key :literature_defined_coding_region_alternate_string_ids, :coding_regions, :dependent => :delete
#    #  has_many :case_sensitive_literature_defined_coding_region_alternate_string_ids, :dependent => :destroy
#    add_foreign_key :case_sensitive_literature_defined_coding_region_alternate_string_ids, :coding_regions, :dependent => :delete
    #  has_many :coding_region_strain_orthologues, :dependent => :destroy
    add_foreign_key :coding_region_strain_orthologues, :coding_regions, :dependent => :delete
    #  has_many :coding_region_localisations, :dependent => :destroy
    add_foreign_key :coding_region_localisations, :coding_regions, :dependent => :delete
    #  has_many :curated_top_level_localisations, :dependent => :destroy
    add_foreign_key :curated_top_level_localisations, :coding_regions, :dependent => :delete
    #  has_many :orthomcl_gene_coding_regions, :dependent => :destroy
    add_foreign_key :orthomcl_gene_coding_regions, :coding_regions, :dependent => :delete
    #  has_many :microarray_measurements, :dependent => :destroy
    add_foreign_key :microarray_measurements, :coding_regions, :dependent => :delete
    #  has_many :expression_contexts, :dependent => :destroy
    add_foreign_key :expression_contexts, :coding_regions, :dependent => :delete
    #  has_many :localisation_annotations, :dependent => :destroy
    add_foreign_key :localisation_annotations, :coding_regions, :dependent => :delete
    #  has_many :integer_coding_region_measurements, :dependent => :destroy
    add_foreign_key :integer_coding_region_measurements, :coding_regions, :dependent => :delete
    #  has_many :proteomic_experiment_results, :dependent => :destroy
    add_foreign_key :proteomic_experiment_results, :coding_regions, :dependent => :delete
    #  has_many :proteomic_experiment_peptides, :dependent => :destroy
    add_foreign_key :proteomic_experiment_peptides, :coding_regions, :dependent => :delete
    #  has_many :conserved_domains, :dependent => :destroy
    add_foreign_key :conserved_domains, :coding_regions, :dependent => :delete
    #  has_many :transmembrane_domain_measurements, :dependent => :destroy
    add_foreign_key :transmembrane_domain_measurements, :coding_regions, :dependent => :delete
    #    #  has_many :transmembrane_domain_lengths, :dependent => :destroy
    #    add_foreign_key :transmembrane_domain_lengths, :coding_regions, :dependent => :delete
    #  has_many :coding_region_phenotype_informations, :dependent => :destroy
    add_foreign_key :coding_region_phenotype_informations, :coding_regions, :dependent => :delete
    #  has_many :coding_region_phenotype_observeds, :dependent => :destroy
    add_foreign_key :coding_region_phenotype_observeds, :coding_regions, :dependent => :delete
    #  has_many :coding_region_mouse_phenotypes, :dependent => :destroy
    add_foreign_key :coding_region_mouse_phenotypes, :coding_regions, :dependent => :delete
    #  has_many :coding_region_yeast_pheno_infos, :dependent => :destroy
    add_foreign_key :coding_region_yeast_pheno_infos, :coding_regions, :dependent => :delete
    #  has_many :coding_region_drosophila_allele_genes, :dependent => :destroy
    add_foreign_key :coding_region_drosophila_allele_genes, :coding_regions, :dependent => :delete
    #  has_many :coding_region_drosophila_rnai_lethalities, :dependent => :destroy
    add_foreign_key :coding_region_drosophila_rnai_lethalities, :coding_regions, :dependent => :delete
    #  has_many :blast_hits, :dependent => :destroy
    add_foreign_key :blast_hits, :coding_regions, :dependent => :delete
    #  has_many :microarray_measurements, :dependent => :destroy
    add_foreign_key :microarray_measurements, :microarray_timepoints, :dependent => :delete
    #  has_many :orthomcl_gene_orthomcl_group_orthomcl_runs, :dependent => :destroy
    add_foreign_key :orthomcl_gene_orthomcl_group_orthomcl_runs, :orthomcl_groups, :dependent => :delete
    #  has_many :expression_contexts, :dependent => :destroy
    add_foreign_key :expression_contexts, :publications, :dependent => :delete
    #  has_many :drosophila_allele_phenotype_drosophila_allele_genes, :dependent => :destroy
    add_foreign_key :drosophila_allele_phenotype_drosophila_allele_genes, :drosophila_allele_phenotypes, :dependent => :delete
    #  has_many :coding_region_network_edges, :dependent => :destroy
    add_foreign_key :coding_region_network_edges, :networks, :dependent => :delete
    #  has_many :coding_regions, :dependent => :destroy
    add_foreign_key :coding_regions, :genes, :dependent => :delete
    #  has_many :gene_alternate_names, :dependent => :destroy
    add_foreign_key :gene_alternate_names, :genes, :dependent => :delete
    #  has_many :coding_region_mouse_phenotypes, :dependent => :destroy
    add_foreign_key :coding_region_mouse_phenotypes, :mouse_phenotypes, :dependent => :delete
    #  has_many :mouse_phenotype_mouse_phenotype_dictionary_entries, :dependent => :destroy
    add_foreign_key :mouse_phenotype_mouse_phenotype_dictionary_entries, :mouse_phenotypes, {:dependent => :delete, :name => 'fk1'}
  end

  def self.down
  end
end
