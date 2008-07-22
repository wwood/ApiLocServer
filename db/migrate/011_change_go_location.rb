class ChangeGoLocation < ActiveRecord::Migration
  def self.up
    remove_column :genes, :go_id
    add_column :coding_regions, :go_term_id, :integer
  end

  def self.down
    add_column :genes, :go_id, :integer
    remove_column :coding_regions, :go_term_id
  end
end
