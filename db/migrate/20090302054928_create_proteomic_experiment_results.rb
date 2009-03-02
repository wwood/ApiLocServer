class CreateProteomicExperimentResults < ActiveRecord::Migration
  def self.up
    create_table :proteomic_experiment_results do |t|
      t.integer :coding_region_id, :null => false
      t.string :type, :null => false
      t.integer :number_of_peptides
      t.float :spectrum

      t.timestamps
    end

    add_index :proteomic_experiment_results, [:coding_region_id, :type], :unique => true
  end

  def self.down
    drop_table :proteomic_experiment_results
  end
end
