class CreatePlasmodbGeneLists < ActiveRecord::Migration
  def self.up
    create_table :plasmodb_gene_lists do |t|
      t.string :description
      t.timestamps
    end

    create_table :plasmo_db_gene_list_entries do |t|
      t.integer :plasmo_db_gene_list_id
      t.integer :gene_id
      t.timestamps
    end
  end

  def self.down
    drop_table :plasmodb_gene_lists
    drop_table :plasmo_db_gene_list_entries
  end
end
