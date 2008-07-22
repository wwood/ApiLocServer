class CreateProbeMapEntries < ActiveRecord::Migration
  def self.up
    create_table :probe_map_entries do |t|
      t.integer :probe_map_id, :null => false
      t.integer :probe_id, :null => false
      t.integer :coding_region_id, :null => false

      t.timestamps
    end
    
    #No indexes wanted here because duplicates are possible
  end

  def self.down
    drop_table :probe_map_entries
  end
end
