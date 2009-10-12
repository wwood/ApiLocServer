class LocalisationAnnotation < ActiveRecord::Base
  belongs_to :coding_region

  has_many :expression_contexts
  has_many :comments
end
