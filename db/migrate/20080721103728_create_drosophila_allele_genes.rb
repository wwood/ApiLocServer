class CreateDrosophilaAlleleGenes < ActiveRecord::Migration
  def self.up
    create_table :drosophila_allele_genes do |t|
      t.string :allele, {:null => false}
      t.integer :gene_id

      t.timestamps
    end
  end

  def self.down
    drop_table :drosophila_allele_genes
  end
end
