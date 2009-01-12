class CodingRegionAlternateStringId < ActiveRecord::Base
  belongs_to :coding_region
  
  named_scope :s, lambda{ |species_name|
    {
      :joins => {:coding_region => {:gene => {:scaffold => :species}}},
      :conditions => ['species.name = ?', species_name]
    }
  }
end
