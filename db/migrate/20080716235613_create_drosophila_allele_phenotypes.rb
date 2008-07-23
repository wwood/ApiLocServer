class CreateDrosophilaAllelePhenotypes < ActiveRecord::Migration
  def self.up
    create_table :drosophila_allele_phenotypes do |t|
      t.integer :drosophila_allele_gene_id, {:null => false}
      t.string :phenotype

      t.timestamps
    end
  end

  def self.down
    drop_table :drosophila_allele_phenotypes
  end
end
