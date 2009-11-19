class PlasmitResult < ActiveRecord::Base
  belongs_to :coding_region

  # There is only 2 different outputs used here
  PLASMIT_MITOCHONDRIA_PREDICTED_STRING = 'mito (91%)'
  PLASMIT_NOT_MITOCHONDRIA_PREDICTED_STRING = 'non-mito (99%)'

  named_scope :positive, {
    :conditions => {:prediction_string => PLASMIT_MITOCHONDRIA_PREDICTED_STRING}
  }
  named_scope :negative, {
    :conditions => {:prediction_string => PLASMIT_NOT_MITOCHONDRIA_PREDICTED_STRING}
  }

  def predicted?
    prediction_string == PLASMIT_MITOCHONDRIA_PREDICTED_STRING
  end
end
