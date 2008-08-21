class CreateDevelopmentalStageLocalisations < ActiveRecord::Migration
  def self.up
    create_table :developmental_stage_localisations do |t|
      t.integer :localisation_id
      t.integer :developmental_stage

      t.timestamps
    end
  end

  def self.down
    drop_table :developmental_stage_localisations
  end
end
