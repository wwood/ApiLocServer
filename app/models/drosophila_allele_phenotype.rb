class DrosophilaAllelePhenotype < ActiveRecord::Base
  has_many :drosophila_allele_phenotype_drosophila_allele_genes, :dependent => :destroy
  has_many :drosophila_allele_genes, :through => :drosophila_allele_phenotype_drosophila_allele_genes

  named_scope :trusted, {
    :conditions => ['phenotype !~ ?',"GAL4"]
  }
  
  def lethal?
    phenotype.match(/lethal/i)
  end
end
