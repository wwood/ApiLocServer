class ClusterIndices < ActiveRecord::Migration
  def self.up
    add_index(:cluster_entries, [:cluster_id, :coding_region_id], :unique => true)
  end

  def self.down
    remove_index :cluster_entries, [:cluster_id, :coding_region_id]
  end
end
