class DrosophilaAlleleSpeedup < ActiveRecord::Migration
  def self.up
    add_index :drosophila_allele_genes, :allele, :unique => true
  end

  def self.down
    add_index :drosophila_allele_genes, :allele
  end
end
