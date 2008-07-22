class ChangeGenesColumns < ActiveRecord::Migration
  def self.up
#    remove_column :genes, :upstream_distance
    add_column :genes, :go_id, :integer
  end

  def self.down
#    add_column :genes, :upstream_distance, :integer
    remove_column :genes, :go_id
  end
end
