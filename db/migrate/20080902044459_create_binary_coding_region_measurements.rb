class CreateBinaryCodingRegionMeasurements < ActiveRecord::Migration
  def self.up
    create_table :binary_coding_region_measurements do |t|
      t.integer :coding_region_id, :null => false
      t.boolean :value
      t.string :type

      t.timestamps
    end
    add_index :binary_coding_region_measurements, :coding_region_id
    add_index :binary_coding_region_measurements, [:coding_region_id, :type]
  end

  def self.down
    drop_table :binary_coding_region_measurements
  end
end
