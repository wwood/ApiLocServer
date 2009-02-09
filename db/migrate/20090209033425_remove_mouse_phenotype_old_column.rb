class RemoveMousePhenotypeOldColumn < ActiveRecord::Migration
  def self.up
    remove_column :mouse_phenotypes, :mouse_pheno_desc_id
  end

  def self.down
    add_column :mouse_phenotypes, :mouse_pheno_desc_id, :integer, :null => false
  end
end
