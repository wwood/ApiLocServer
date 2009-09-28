class AlternateCodingRegionsShouldHaveNotNullCodignRegionId < ActiveRecord::Migration
  def self.up
    change_column :coding_region_alternate_string_ids, :coding_region_id, :integer, :null => false
  end

  def self.down
    change_column :coding_region_alternate_string_ids, :coding_region_id, :integer
  end
end
