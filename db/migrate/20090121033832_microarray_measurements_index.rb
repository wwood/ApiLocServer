class MicroarrayMeasurementsIndex < ActiveRecord::Migration
  def self.up
    add_index :microarray_measurements, [:microarray_timepoint_id, :measurement]
    add_index :microarray_measurements, [:microarray_timepoint_id]
  end

  def self.down
    remove_index :microarray_measurements, [:microarray_timepoint_id, :measurement]
    remove_index :microarray_measurements, [:microarray_timepoint_id]
  end
end
