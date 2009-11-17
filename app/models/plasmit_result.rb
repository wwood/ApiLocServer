class PlasmitResult < ActiveRecord::Base
  belongs_to :coding_region

  def predicted?
    !prediction_string.match(/non/)
  end
end
