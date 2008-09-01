class CreateIntegerCodingRegionMeasurements < ActiveRecord::Migration
  def self.up
    create_table :integer_coding_region_measurements do |t|
      t.string :type
      t.integer :coding_region_id
      t.integer :value

      t.timestamps
    end
    
    add_index :integer_coding_region_measurements, [:type, :coding_region_id]
  end

  def self.down
    drop_table :integer_coding_region_measurements
  end
end
