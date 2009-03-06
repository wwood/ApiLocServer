class CreatePfalciparumTilingArrays < ActiveRecord::Migration
  def self.up
    create_table :pfalciparum_tiling_arrays do |t|
      t.string :probe, :null => false
      t.string :sequence, :null => false
      t.decimal :HB3_1, :null => false
      t.decimal :HB3_2, :null => false
      t.decimal :ThreeD7_1, :null => false
      t.decimal :ThreeD7_2, :null => false
      t.decimal :Dd2_1, :null => false
      t.decimal :Dd2_2, :null => false
      t.decimal :Dd2_FosR_1, :null => false
      t.decimal :Dd2_FosR_2, :null => false
    end

    add_index :pfalciparum_tiling_arrays, :probe, :unique => true
    add_index :pfalciparum_tiling_arrays, :sequence
  end

  def self.down
    drop_table :pfalciparum_tiling_arrays
  end
end
