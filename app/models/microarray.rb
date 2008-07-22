class Microarray < ActiveRecord::Base
  has_many :microarray_timepoints, :dependent => :destroy
  
  def self.yeast_alpha_arrest_name
    'Yeast Spellman Alpha Arrest'
  end
  
  def self.derisi_2006_3D7_default
    'DeRisi 2006 3D7 Quality Control Published'
  end
end
