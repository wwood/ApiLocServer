class AddTypesToCodingRegionAlternateStringId < ActiveRecord::Migration
  def self.up
    add_column :coding_region_alternate_string_ids, :type, :string
    add_index :coding_region_alternate_string_ids, [:coding_region_id, :type], :name => 'index1'
    add_index :coding_region_alternate_string_ids, [:coding_region_id, :type, :name], :name => 'index2'
  end

  def self.down
    remove_column :coding_region_alternate_string_ids, :type
  end
end
