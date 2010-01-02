class CreateCuratedTopLevelLocalisations < ActiveRecord::Migration
  def self.up
    create_table :curated_top_level_localisations do |t|
      t.integer :coding_region_id, :null => false
      t.integer :top_level_localisation_id, :null => false

      t.timestamps
    end

    add_index :curated_top_level_localisations, :coding_region_id
    add_index :curated_top_level_localisations, [:coding_region_id, :top_level_localisation_id], {:unique => true, :name => 'curated_all'}
  end

  def self.down
    drop_table :curated_top_level_localisations
  end
end
