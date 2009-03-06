class SpeedUpProbeMapEntry < ActiveRecord::Migration
  def self.up
    add_index :probe_map_entries, [:probe_map_id, :probe_id]
  end

  def self.down
    remove_index :probe_map_entries, [:probe_map_id, :probe_id]
  end
end
