class CreateGoMapEntries < ActiveRecord::Migration
  def self.up
    create_table :go_map_entries do |t|
      t.integer :go_map_id
      t.integer :parent_id
      t.integer :child_id
      t.timestamps
    end
  end

  def self.down
    drop_table :go_map_entries
  end
end
