class DevelopmentalStage < ActiveRecord::Base
  has_many :expression_contexts, :dependent => :destroy
  
  # Unknown developmental stage
  UNKNOWN_NAME = 'unknown'
end
