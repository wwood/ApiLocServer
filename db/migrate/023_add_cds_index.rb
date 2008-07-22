class AddCdsIndex < ActiveRecord::Migration
  def self.up
    add_index :cds, :coding_region_id
  end

  def self.down
    remove_index :cds, :coding_region_id
  end
end
