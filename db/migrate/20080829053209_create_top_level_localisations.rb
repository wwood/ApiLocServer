class CreateTopLevelLocalisations < ActiveRecord::Migration
  def self.up
    create_table :top_level_localisations do |t|
      t.string :name

      t.timestamps
    end
    
    add_column :localisations, :top_level_localisation_id, :integer
  end

  def self.down
    drop_table :top_level_localisations
    remove_column :localisations, :top_level_localisation_id
  end
end
