class AddOrientationToTmd < ActiveRecord::Migration
  def self.up
    add_column :transmembrane_domains, :orientation, :string
  end

  def self.down
    remove_column :transmembrane_domains, :orientation
  end
end
