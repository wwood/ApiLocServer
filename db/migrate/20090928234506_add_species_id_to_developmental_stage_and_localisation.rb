class AddSpeciesIdToDevelopmentalStageAndLocalisation < ActiveRecord::Migration
  def self.up
    add_column :localisations, :species_id, :integer, :null => false
    add_column :developmental_stages, :species_id, :integer, :null => false

    add_index :localisations, [:name, :species_id], :unique => true
    add_index :developmental_stages, [:name, :species_id], :unique => true
  end

  def self.down
    remove_column :localisations, :species_id
    remove_column :developmental_stages, :species_id
  end
end
