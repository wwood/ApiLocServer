class CreateGeneNetworkEdges < ActiveRecord::Migration
  def self.up
    create_table :gene_network_edges do |t|
      t.integer :gene_network_id, :null => false
      t.integer :gene_id_first, :null => false
      t.integer :gene_id_second, :null => false
      t.decimal :strength

      t.timestamps
    end
    
    add_index :gene_network_edges, [:gene_network_id, :gene_id_first, :gene_id_second], :unique => true
  end

  def self.down
    drop_table :gene_network_edges
  end
end
