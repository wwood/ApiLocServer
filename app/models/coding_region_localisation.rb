class CodingRegionLocalisation < ActiveRecord::Base
  belongs_to :coding_region
  belongs_to :localisation
  belongs_to :localisation_method
  
  named_scope :recent, lambda { { :conditions => ['created_at > ?', 1.week.ago] } }
end
