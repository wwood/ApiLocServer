class CreatePlasmodbGeneListEntries < ActiveRecord::Migration
  def self.up
    create_table :plasmodb_gene_list_entries do |t|
      t.integer :plasmodb_gene_list_id
      t.integer :coding_region_id
      t.timestamps
    end
    
    add_index :plasmodb_gene_list_entries, 
      [:plasmodb_gene_list_id, :coding_region_id],
      :unique => true
  end

  def self.down
    drop_table :plasmodb_gene_list_entries
  end
end
