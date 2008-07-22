class AddOrientation < ActiveRecord::Migration
  def self.up
    add_column :coding_regions, :orientation, :string, {:length => 1}
  end

  def self.down
    remove_column :coding_regions, :orientation
  end
end
