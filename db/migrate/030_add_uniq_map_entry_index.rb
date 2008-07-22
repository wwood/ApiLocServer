class AddUniqMapEntryIndex < ActiveRecord::Migration
  def self.up
    # Add the index so no duplicates are allowed.
    add_index :go_map_entries, [:go_map_id, :parent_id, :child_id], :unique => true
  end

  def self.down
    remove_index :go_map_entries, [:go_map_id, :parent_id, :child_id]
  end
end
