class SpeedUpGeneNetworkEdges < ActiveRecord::Migration
  def self.up
    add_index :gene_network_edges, :gene_id_first
    add_index :gene_network_edges, :gene_id_second
  end

  def self.down
    remove_index :gene_network_edges, :gene_id_first
    remove_index :gene_network_edges, :gene_id_second
  end
end
