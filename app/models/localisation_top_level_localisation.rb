class LocalisationTopLevelLocalisation < ActiveRecord::Base
  validates_presence_of :localisation_id, :top_level_localisation_id

  belongs_to :localisation
  belongs_to :top_level_localisation
end
