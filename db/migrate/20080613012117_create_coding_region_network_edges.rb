class CreateCodingRegionNetworkEdges < ActiveRecord::Migration
  def self.up
    create_table :coding_region_network_edges do |t|
      t.integer :network_id, :null => false
      t.integer :coding_region_id_first, :null => false
      t.integer :coding_region_id_second, :null => false
      t.decimal :strength

      t.timestamps
    end
    
    add_index :coding_region_network_edges, [:network_id, :coding_region_id_first, :coding_region_id_second], :unique => true
  end

  def self.down
    drop_table :coding_region_network_edges
  end
end
