class AddCodingRegionToLocalisationAnnotation < ActiveRecord::Migration
  def self.up
    add_column :localisation_annotations, :coding_region_id, :integer, :null => false
  end

  def self.down
    remove_column :localisation_annotations, :coding_region_id
  end
end
