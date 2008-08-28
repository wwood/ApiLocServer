class CreateDrosophilaAllelePhenotypeDrosophilaAlleleGenes < ActiveRecord::Migration
  def self.up
    create_table :drosophila_allele_phenotype_drosophila_allele_genes do |t|
      t.integer :drosophila_allele_gene_id, :null => false
      t.integer :drosophila_allele_phenotype_id, :null => false
      t.timestamps
    end
    
    add_index :drosophila_allele_phenotype_drosophila_allele_genes, :drosophila_allele_gene_id, :name => :drosophila_allele_phenotype_dag_dag
    add_index :drosophila_allele_phenotype_drosophila_allele_genes, :drosophila_allele_phenotype_id, :name => :drosophila_allele_phenotype_dag_dap
    
    remove_column :drosophila_allele_phenotypes, :drosophila_allele_gene_id
  end

  def self.down
    drop_table :drosophila_allele_phenotype_drosophila_allele_genes
    
    add_column :drosophila_allele_phenotypes, :drosophila_allele_gene_id, :integer, :null => false
  end
end
