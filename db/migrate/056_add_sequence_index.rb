class AddSequenceIndex < ActiveRecord::Migration
  def self.up
    add_index :sequences, [:coding_region_id, :type]
  end

  def self.down
    remove_index :sequences, [:coding_region_id, :type]
  end
end
