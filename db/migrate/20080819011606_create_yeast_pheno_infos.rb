class CreateYeastPhenoInfos < ActiveRecord::Migration
  def self.up
    create_table :yeast_pheno_infos do |t|
      t.integer :coding_region_id, {:null => false} #is deleted later on in migrations
      t.string :experiment_type, :null => false
      t.string :phenotype, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :yeast_pheno_infos
  end
end
