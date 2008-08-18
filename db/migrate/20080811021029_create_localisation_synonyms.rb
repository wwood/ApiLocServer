class CreateLocalisationSynonyms < ActiveRecord::Migration
  def self.up
    create_table :localisation_synonyms do |t|
      t.string :name
      t.integer :localisation_id

      t.timestamps
    end
  end

  def self.down
    drop_table :localisation_synonyms
  end
end
