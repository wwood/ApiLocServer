class CreateDevelopmentalStageSynonyms < ActiveRecord::Migration
  def self.up
    create_table :developmental_stage_synonyms do |t|
      t.integer :developmental_stage_id
      t.string :name

      t.timestamps
    end
    
    add_index :developmental_stage_synonyms, :name
    add_index :developmental_stage_synonyms, :developmental_stage_id
  end

  def self.down
    drop_table :developmental_stage_synonyms
  end
end
