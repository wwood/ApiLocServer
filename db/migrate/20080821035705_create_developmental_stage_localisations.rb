class CreateDevelopmentalStageLocalisations < ActiveRecord::Migration
  def self.up
    create_table :developmental_stage_localisations do |t|
      t.integer :localisation_id, :null => false
      t.integer :developmental_stage_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :developmental_stage_localisations
  end
end
