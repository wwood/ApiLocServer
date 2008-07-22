class CreateClusterEntries < ActiveRecord::Migration
  def self.up
    create_table :cluster_entries do |t|
      t.integer :coding_region_id
      t.integer :cluster_id
      t.timestamps
    end
  end

  def self.down
    drop_table :cluster_entries
  end
end
