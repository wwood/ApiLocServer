class CreateYeastPhenoInfos < ActiveRecord::Migration
  def self.up
    create_table :yeast_pheno_infos do |t|
      t.integer :coding_region_id, {:null => false}
      t.string :experiment_type
      t.string :phenotype

      t.timestamps
    end
  end

  def self.down
    drop_table :yeast_pheno_infos
  end
end
