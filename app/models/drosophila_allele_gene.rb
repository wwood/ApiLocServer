class DrosophilaAlleleGene < ActiveRecord::Base
  #phenotypes
  has_many :drosophila_allele_phenotype_drosophila_allele_genes
  has_many :drosophila_allele_phenotypes, :through => :drosophila_allele_phenotype_drosophila_allele_genes
  #coding_regions
  has_many :coding_region_drosophila_allele_genes
  has_many :coding_regions, :through => :coding_region_drosophila_allele_genes
end
