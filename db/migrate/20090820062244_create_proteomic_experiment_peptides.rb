class CreateProteomicExperimentPeptides < ActiveRecord::Migration
  def self.up
    create_table :proteomic_experiment_peptides do |t|
      t.integer :coding_region_id
      t.integer :proteomic_experiment_id
      t.string :peptide
      t.string :charge

      t.timestamps
    end

    add_index :proteomic_experiment_peptides, [:coding_region_id, :proteomic_experiment_id, :peptide, :charge], :unique => true
    add_index :proteomic_experiment_peptides, :coding_region_id
  end

  def self.down
    drop_table :proteomic_experiment_peptides
  end
end
