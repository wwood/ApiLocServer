class CreateMousePhenotypeMousePhenotypeDictionaryEntries < ActiveRecord::Migration
  def self.up
    create_table :mouse_phenotype_mouse_phenotype_dictionary_entries do |t|
      t.integer :mouse_phenotype_id, :null => false
      t.integer :mouse_phenotype_dictionary_entry_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :mouse_phenotype_mouse_phenotype_dictionary_entries
  end
end
