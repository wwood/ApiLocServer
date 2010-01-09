class MaybeFasterCodingRegionAlternates < ActiveRecord::Migration
  def self.up
    add_index :coding_region_alternate_string_ids, [:coding_region_id, :name, :source]
  end

  def self.down
    remove_index :coding_region_alternate_string_ids, [:coding_region_id, :name, :source]
  end
end
