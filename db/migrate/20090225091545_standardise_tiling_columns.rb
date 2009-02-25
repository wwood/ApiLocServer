class StandardiseTilingColumns < ActiveRecord::Migration
  def self.up
rename_column :pfalciparum_tiling_arrays, :HB3_1, :hb3_1
rename_column :pfalciparum_tiling_arrays, :HB3_2, :hb3_2
rename_column :pfalciparum_tiling_arrays, :ThreeD7_1, :three_d7_1
rename_column :pfalciparum_tiling_arrays, :ThreeD7_2, :three_d7_2
rename_column :pfalciparum_tiling_arrays, :Dd2_1, :dd2_1
rename_column :pfalciparum_tiling_arrays, :Dd2_2, :dd2_2
rename_column :pfalciparum_tiling_arrays, :Dd2_FosR_1, :dd2_fosr_1
rename_column :pfalciparum_tiling_arrays, :Dd2_FosR_2, :dd2_fosr_2
rename_column :pfalciparum_tiling_arrays, :threeD7_attB, :three_d7_attb
  end

  def self.down
raise
rename_column :pfalciparum_tiling_arrays, :hb3_1, :HB3_1
  end
end
