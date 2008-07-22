class RemoveMicroarrayMeasurementIndex < ActiveRecord::Migration
  def self.up
    remove_index :microarray_measurements, [:microarray_timepoint_id,:coding_region_id]
  end

  def self.down
    # Can fail for legit reasons.
    $stderr.puts "WARNING: index not added correctly in this migration. Needs manual attention if you care"
#    add_index :microarray_measurements, [:microarray_timepoint_id,:coding_region_id], :unique => true
  end
end
