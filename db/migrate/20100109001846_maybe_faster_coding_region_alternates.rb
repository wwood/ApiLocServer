class MaybeFasterCodingRegionAlternates < ActiveRecord::Migration
  def self.up
    add_index :coding_region_alternate_string_ids,
      [:coding_region_id, :name, :source],
      :name => "index_coding_region_alternate_string_ids_on_coding_region_id_an"
  end

  def self.down
    remove_index :coding_region_alternate_string_ids, 
      [:coding_region_id, :name, :source],
      :name => "index_coding_region_alternate_string_ids_on_coding_region_id_an"
  end
end
