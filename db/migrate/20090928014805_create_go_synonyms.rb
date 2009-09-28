class CreateGoSynonyms < ActiveRecord::Migration
  def self.up
    create_table :go_synonyms do |t|
      t.text :synonym, :null => false
      t.integer :go_term_id, :null => false

      t.timestamps
    end

    add_index :go_synonyms, [:synonym, :go_term_id], :unique => true
    add_index :go_synonyms, :go_term_id
    add_index :go_synonyms, :synonym
  end

  def self.down
    drop_table :go_synonyms
  end
end
