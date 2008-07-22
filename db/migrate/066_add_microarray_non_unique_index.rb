class AddMicroarrayNonUniqueIndex < ActiveRecord::Migration
  def self.up
    add_index :microarray_measurements, [:microarray_timepoint_id,:coding_region_id, :measurement]
  end

  def self.down
    remove_index :microarray_measurements, [:microarray_timepoint_id,:coding_region_id, :measurement]
  end
end
