class DrosophilaAllelePhenotype < ActiveRecord::Base
  has_many :drosophila_allele_phenotype_drosophila_allele_genes, :dependent => :destroy
  has_many :drosophila_allele_genes, :through => :drosophila_allele_phenotype_drosophila_allele_genes
  
  def lethal?
    phenotype.match(/lethal/i)
  end
end
