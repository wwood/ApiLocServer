class AddMissedTilingColumn < ActiveRecord::Migration
  def self.up
    add_column :pfalciparum_tiling_arrays, :threeD7_attB, :decimal, :null => false
  end

  def self.down
    remove_column :pfalciparum_tiling_arrays, :threeD7_attB
  end
end
