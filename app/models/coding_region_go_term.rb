# A join model (1 to N) between coding region and go term
class CodingRegionGoTerm < ActiveRecord::Base
  validates_presence_of :coding_region_id
  validates_presence_of :go_term_id
  
  belongs_to :coding_region
  belongs_to :go_term
end
