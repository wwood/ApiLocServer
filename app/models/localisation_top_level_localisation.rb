class LocalisationTopLevelLocalisation < ActiveRecord::Base
  belongs_to :localisation
  belongs_to :top_level_localisation
end
