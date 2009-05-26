class AddCdsOrder < ActiveRecord::Migration
  def self.up
    add_column :cds, :order, :integer
    add_index :cds, :order
    add_index :cds, [:order, :coding_region_id] # would be uniq except it can be null
  end

  def self.down
    remove_column :cds, :order, :integer
  end
end
