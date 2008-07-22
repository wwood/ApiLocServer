class AddApidbId < ActiveRecord::Migration
  def self.up
    add_column :coding_regions, :string_id, :string
  end

  def self.down
    remove_column :coding_regions, :string_id
  end
end
