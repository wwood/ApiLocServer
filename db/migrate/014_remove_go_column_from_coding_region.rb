class RemoveGoColumnFromCodingRegion < ActiveRecord::Migration
  def self.up
    remove_column :coding_regions, :go_term_id
  end

  def self.down
    add_column :coding_regions, :go_term_id, :integer
  end
end
