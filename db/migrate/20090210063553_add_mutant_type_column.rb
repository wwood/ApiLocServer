class AddMutantTypeColumn < ActiveRecord::Migration
  def self.up
    add_column :yeast_pheno_infos, :mutant_type, :string, :null => false
  end

  def self.down
    remove_column :yeast_pheno_infos, :mutant_type
  end
end
