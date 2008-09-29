class ChangeSequenceIndices < ActiveRecord::Migration
  def self.up
    remove_index :sequences, :coding_region_id
    remove_index :sequences, [:coding_region_id, :type]
    add_index :sequences, [:coding_region_id, :type], :unique => true
  end

  def self.down
    remove_index :sequences, [:coding_region_id, :type], :unique => true
    add_index :sequences, [:coding_region_id, :type]
    add_index :sequences, :coding_region_id, :unique => true
  end
end
