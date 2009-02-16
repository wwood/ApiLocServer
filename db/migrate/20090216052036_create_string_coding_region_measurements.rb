class CreateStringCodingRegionMeasurements < ActiveRecord::Migration
  def self.up
    create_table :string_coding_region_measurements do |t|
      t.string :measurement
      t.integer :coding_region_id, :null => false
      t.string :type, :null => false

      t.timestamps
    end
    
    add_index :string_coding_region_measurements, [:coding_region_id, :type]
    add_index :string_coding_region_measurements, [:coding_region_id, :type, :measurement], :name => 'strind_code_ctm'
  end

  def self.down
    drop_table :string_coding_region_measurements
  end
end
