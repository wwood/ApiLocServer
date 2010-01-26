class AddCodingRegionDoubleIndex < ActiveRecord::Migration
  def self.up
    add_index :coding_regions, [:string_id, :gene_id], :unique => true
  end

  def self.down
  end
end
