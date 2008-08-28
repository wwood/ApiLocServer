class DeleteOldMouseTables < ActiveRecord::Migration
  def self.up
    drop_table :mouse_pheno_infos
    drop_table :mouse_phenotype_infos
  end

  def self.down
    raise Exception
  end
end
