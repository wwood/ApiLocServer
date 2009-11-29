class CuratedTopLevelLocalisation < ActiveRecord::Base
  belongs_to :top_level_localisation
  belongs_to :coding_region
end
