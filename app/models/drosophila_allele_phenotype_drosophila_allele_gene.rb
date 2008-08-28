class DrosophilaAllelePhenotypeDrosophilaAlleleGene < ActiveRecord::Base
  belongs_to :drosophila_allele_gene
  belongs_to :drosophila_allele_phenotype
end
