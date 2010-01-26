class AddSourceToCodingRegionAlternateStringId < ActiveRecord::Migration
  def self.up
    add_column :coding_region_alternate_string_ids, :source, :string
  end

  def self.down
    remove_column :coding_region_alternate_string_ids, :source
  end
end
