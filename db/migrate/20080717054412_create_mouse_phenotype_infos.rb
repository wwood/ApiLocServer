class CreateMousePhenotypeInfos < ActiveRecord::Migration
  def self.up
    create_table :mouse_phenotype_infos do |t|
      t.string :mgi
      t.string :gene
      t.string :phenotype

      t.timestamps
    end
  end

  def self.down
    drop_table :mouse_phenotype_infos
  end
end
