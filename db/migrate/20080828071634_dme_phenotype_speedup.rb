class DmePhenotypeSpeedup < ActiveRecord::Migration
  def self.up
    add_index :drosophila_allele_phenotypes, :phenotype
  end

  def self.down
    remove_index :drosophila_allele_phenotypes, :phenotype
  end
end
