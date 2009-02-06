class Microarray < ActiveRecord::Base
  has_many :microarray_timepoints, :dependent => :destroy
  
  WINZELER_2003_NAME = "Winzeler Cell Cycle 2003"
  WINZELER_2005_GAMETOCYTE_NAME = "Winzeler Gametocyte 2005"
  
  def self.yeast_alpha_arrest_name
    'Yeast Spellman Alpha Arrest'
  end
  
  def self.derisi_2006_3D7_default
    'DeRisi 2006 3D7 Quality Control Published'
  end
end
