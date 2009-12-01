class BlastHit < ActiveRecord::Base
  belongs_to :coding_region
  belongs_to :hit,
    :foreign_key => 'hit_coding_region_id',
    :class_name => 'CodingRegion'
  belongs_to :query, # there is already a belongs_to but I felt like being lenient
    :foreign_key => 'coding_region_id',
    :class_name => 'CodingRegion'
end
