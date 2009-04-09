class CreateMetaMicroarrayMeasurements < ActiveRecord::Migration
  def self.up
    create_table :meta_microarray_measurements do |t|
      t.string :type, :null => false
      t.integer :microarray_timepoint_id, :null => false
      t.decimal :measurement, :null => false

      t.timestamps
    end
    
    # may not be unique, but is at least for median localisations measurements
    add_index :meta_microarray_measurements, [:type, :microarray_timepoint_id] 
  end

  def self.down
    drop_table :meta_microarray_measurements
  end
end
