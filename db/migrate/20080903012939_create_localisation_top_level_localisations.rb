class CreateLocalisationTopLevelLocalisations < ActiveRecord::Migration
  def self.up
    create_table :localisation_top_level_localisations do |t|
      t.integer :localisation_id
      t.integer :top_level_localisation_id
      t.string :type

      t.timestamps
    end
    
    add_index :localisation_top_level_localisations, [:localisation_id, :type]
    add_index :localisation_top_level_localisations, [:top_level_localisation_id, :type]
    add_index :localisation_top_level_localisations, [:type, :localisation_id, :top_level_localisation_id]
    
    remove_column :localisations, :top_level_localisation_id
  end

  def self.down
    drop_table :localisation_top_level_localisations
    
    add_column :localisations, :top_level_localisation_id, :integer
  end
end
