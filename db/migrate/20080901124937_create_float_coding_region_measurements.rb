class CreateFloatCodingRegionMeasurements < ActiveRecord::Migration
  def self.up
    create_table :float_coding_region_measurements do |t|
      t.string :type
      t.integer :coding_region_id
      t.float :value

      t.timestamps
    end
    
    add_index :float_coding_region_measurements, [:type, :coding_region_id]
  end

  def self.down
    drop_table :float_coding_region_measurements
  end
end
