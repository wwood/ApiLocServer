class CreateMicroarrayMeasurements < ActiveRecord::Migration
  def self.up
    create_table :microarray_measurements do |t|
      t.integer :microarray_timepoint_id, :null => false
      t.decimal :measurement, :null => false
      t.integer :coding_region_id, :null => false

      t.timestamps
    end
    
    add_index :microarray_measurements, [:microarray_timepoint_id,:coding_region_id], :unique => true
  end

  def self.down
    drop_table :microarray_measurements
  end
end
