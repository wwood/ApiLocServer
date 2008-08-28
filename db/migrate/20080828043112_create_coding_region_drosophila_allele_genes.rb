class CreateCodingRegionDrosophilaAlleleGenes < ActiveRecord::Migration
  def self.up
    create_table :coding_region_drosophila_allele_genes do |t|
      t.integer :coding_region_id, :null => false
      t.integer :drosophila_allele_gene_id, :null => false

      t.timestamps
    end
    
    add_index :coding_region_drosophila_allele_genes, :coding_region_id
    add_index :coding_region_drosophila_allele_genes, :drosophila_allele_gene_id
    
    remove_column :drosophila_allele_genes, :gene_id
    
    add_index :drosophila_allele_phenotypes, :drosophila_allele_gene_id
  end

  def self.down
    drop_table :coding_region_drosophila_allele_genes
    
    add_column :drosophila_allele_genes, :gene_id, :integer, :null => false
    
    remove_index :drosophila_allele_phenotypes, :drosophila_allele_gene_id
  end
end
