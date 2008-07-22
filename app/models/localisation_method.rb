class LocalisationMethod < ActiveRecord::Base
  has_many :coding_region_localisations
  
  def self.yeast_gfp_description
    'Yeast GFP'
  end
  
  def self.esldb_experimental
    'eSLDB Experimental'
  end
  
  def self.esldb_all
    'eSLDB Consensus'
  end
end
