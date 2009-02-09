class SpeedUpMousePhenotypeLookup < ActiveRecord::Migration
  def self.up
    add_index :mouse_phenotype_mouse_phenotype_dictionary_entries, [:mouse_phenotype_id, :mouse_phenotype_dictionary_entry_id], :unique => true
  end

  def self.down
    remove_index :mouse_phenotype_mouse_phenotype_dictionary_entries, [:mouse_phenotype_id, :mouse_phenotype_dictionary_entry_id]
  end
end
