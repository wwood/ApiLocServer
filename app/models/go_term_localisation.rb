class GoTermLocalisation < ActiveRecord::Base
  belongs_to :go_term
  belongs_to :localisation
end
