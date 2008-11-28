class AddProperSignalpColumns < ActiveRecord::Migration
  def self.up
    add_column :signal_ps, :coding_region_id, :integer, :null => false
    
    # e.g.
    # # name                Cmax  pos ?  Ymax  pos ?  Smax  pos ?  Smean ?  D     ? 	# name      !  Cmax  pos ?  Sprob ?
    # 526.m04658            0.734  19 Y  0.686  19 Y  0.933   6 Y  0.760 Y  0.723 Y	526.m04658  Q  0.037  19 N  0.004 N
    add_column :signal_ps, :nn_Cmax, :decimal, :null => false
    add_column :signal_ps, :nn_Cmax_position, :integer, :null => false
    add_column :signal_ps, :nn_Cmax_prediction, :boolean, :null => false
    add_column :signal_ps, :nn_Ymax, :decimal, :null => false
    add_column :signal_ps, :nn_Ymax_position, :integer, :null => false
    add_column :signal_ps, :nn_Ymax_prediction, :boolean, :null => false
    add_column :signal_ps, :nn_Smax, :decimal, :null => false
    add_column :signal_ps, :nn_Smax_position, :integer, :null => false
    add_column :signal_ps, :nn_Smax_prediction, :boolean, :null => false
    add_column :signal_ps, :nn_Smean, :decimal, :null => false
    add_column :signal_ps, :nn_Smean_prediction, :boolean, :null => false
    add_column :signal_ps, :nn_D, :decimal, :null => false
    add_column :signal_ps, :nn_D_prediction, :boolean, :null => false
    add_column :signal_ps, :hmm_result, :decimal, :null => false
    add_column :signal_ps, :hmm_Cmax, :decimal, :null => false
    add_column :signal_ps, :hmm_Cmax_position, :integer, :null => false
    add_column :signal_ps, :hmm_Cmax_prediction, :boolean, :null => false
    add_column :signal_ps, :hmm_Sprob, :decimal, :null => false
    add_column :signal_ps, :hmm_Sprob_prediction, :boolean, :null => false

    #        @@nn_results = 
    #      [:nn_Cmax, :nn_Cmax_position, :nn_Cmax_prediction, 
    #      :nn_Ymax, :nn_Ymax_position, :nn_Ymax_prediction, 
    #      :nn_Smax, :nn_Smax_position, :nn_Smax_prediction, 
    #      :nn_Smean, :nn_Smean_prediction,
    #      :nn_D, :nn_D_prediction]
    #    @@hmm_results = [
    #      :hmm_result, :hmm_Cmax, :hmm_Cmax_position, :hmm_Cmax_prediction, :hmm_Sprob, :hmm_Sprob_prediction]
    add_index :signal_ps, :coding_region_id, :unique => true
  end

  def self.down
    raise
  end
end
