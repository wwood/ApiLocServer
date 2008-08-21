class CreateDevelopmentalStageLocalisationPublications < ActiveRecord::Migration
  def self.up
    create_table :developmental_stage_localisation_publications do |t|
      t.integer :developmental_stage_localisations_id, :null => false
      t.integer :publication_id, :null => false

      t.timestamps
    end
    
    add_index :developmental_stage_localisation_publications, [:developmental_stage_localisations_id, :publication_id], :unique => true
  end

  def self.down
    drop_table :developmental_stage_localisation_publications
  end
end
