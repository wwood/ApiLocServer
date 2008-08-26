class AddOrientationIndex < ActiveRecord::Migration
  def self.up
    add_index :coding_regions, :orientation
  end

  def self.down
    remove_index :coding_regions, :orientation
  end
end
