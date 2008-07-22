class CreateCodingRegionAlternateStringIds < ActiveRecord::Migration
  def self.up
    create_table :coding_region_alternate_string_ids do |t|
      t.integer :coding_region_id
      t.string :name
      t.timestamps
    end
    
    add_index :coding_region_alternate_string_ids, :name
    add_index :coding_region_alternate_string_ids, [:coding_region_id, :name], :unique =>true
  end

  def self.down
    drop_table :coding_region_alternate_string_ids
  end
end
