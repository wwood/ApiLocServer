class UniqueGeneListNames < ActiveRecord::Migration
  def self.up
    change_column :plasmodb_gene_lists, :description, :string, :unique => true
  end

  def self.down
    change_column :plasmodb_gene_lists, :description, :string, :unique => false
  end
end
