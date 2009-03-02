class AddPercentageToMassSpec < ActiveRecord::Migration
  def self.up
    add_column :proteomic_experiment_results, :percentage, :float
  end

  def self.down
    remove_column :proteomic_experiment_results, :percentage
  end
end
