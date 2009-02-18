class AddLengthToScaffolds < ActiveRecord::Migration
  def self.up
    add_column :scaffolds, :length, :integer
  end

  def self.down
    remove_column :scaffolds, :length
  end
end
