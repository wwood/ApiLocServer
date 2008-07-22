class ChangeCodingRegionLocalisationIndex < ActiveRecord::Migration
  def self.up
    remove_index :coding_region_localisations, 
      [:coding_region_id, :localisation_id]
    add_index :coding_region_localisations, 
      [:coding_region_id, :localisation_id, :localisation_method_id],
      :unique => true
  end

  def self.down
    remove_index :coding_region_localisations, 
      [:coding_region_id, :localisation_id, :localisation_method_id]
    add_index :coding_region_localisations, 
      [:coding_region_id, :localisation_id],
      :unique => true
  end
end
