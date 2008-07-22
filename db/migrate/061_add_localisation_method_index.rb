class AddLocalisationMethodIndex < ActiveRecord::Migration
  def self.up
    add_index :coding_region_localisations, [:localisation_id, :coding_region_id, :localisation_method_id], :unique => true
  end

  def self.down
   drop_index :coding_region_localisations, [:localisation_id, :coding_region_id, :localisation_method_id]
  end
end
