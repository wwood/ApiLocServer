class DrosophilaRnaiLethality < ActiveRecord::Base
  has_many :coding_region_drosophila_rnai_lethalities, :dependent => :destroy
  has_many :coding_regions, :through => :coding_region_drosophila_rnai_lethalities
    
    
  LETHALITY = [
    'Adult',
    'Pupal',
    'Before Pupal',
    'Eclosion'
  ]  
   
  def lethal?
    LETHALITY.include?(lethality)
  end
end

   
 
