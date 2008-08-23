class MorePerformanceIndexes < ActiveRecord::Migration
  def self.up
    add_index :genes, :scaffold_id
    add_index :scaffolds, :species_id
    add_index :coding_regions, :string_id
  end

  def self.down
    remove_index :genes, :scaffold_id
    remove_index :scaffolds, :species_id
    remove_index :coding_regions, :string_id
  end
end
