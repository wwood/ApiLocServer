class YetAnotherMicroarraySpeedup < ActiveRecord::Migration
  def self.up
    add_index :microarray_measurements, [:coding_region_id, :microarray_timepoint_id]
  end

  def self.down
    remove_index :microarray_measurements, [:coding_region_id, :microarray_timepoint_id]
  end
end
