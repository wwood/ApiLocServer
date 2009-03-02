class CreateProteomicsExperiments < ActiveRecord::Migration
  def self.up
    create_table :proteomics_experiments do |t|
      t.string :name, :null => false

      t.timestamps
    end

    ProteomicExperimentResult.destroy_all

    add_column :proteomic_experiment_results, :proteomic_experiment_id, :integer, :null => false
    remove_column :proteomic_experiment_results, :type
  end

  def self.down
    ProteomicExperimentResult.destroy_all
    remove_column :proteomic_experiment_results, :proteomic_experiment_id
    add_column :proteomic_experiment_results, :type, :string, :null => false
    drop_table :proteomic_experiments
  end
end
