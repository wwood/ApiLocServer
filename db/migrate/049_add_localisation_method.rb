class AddLocalisationMethod < ActiveRecord::Migration
  def self.up
    # Everything already uploaded is yeast GFP - so make this the temporary
    # default, then take away the default do not to cause problems later
    m = LocalisationMethod.find_or_create_by_description("Yeast GFP");
    
    add_column :coding_region_localisations, 
      :localisation_method_id, 
      :integer,
      {
      :default => m.id, 
      :null => false
    }
    
    change_column :coding_region_localisations, :localisation_method_id, :integer, :default => nil
  end

  def self.down
    remove_column :coding_region_localisations, :localisation_method_id
  end
end
