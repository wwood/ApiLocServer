class LocalisationMethod < ActiveRecord::Base
  has_many :coding_region_localisations
  has_many :localisation_literatures #but only ones that are literature method'd. Maybe could be subclassed but eh
  
  
  def self.yeast_gfp_description
    'Yeast GFP'
  end
  
  def self.esldb_experimental
    'eSLDB Experimental'
  end
  
  def self.esldb_all
    'eSLDB Consensus'
  end
  
  def self.literature
    'literature'
  end
end
