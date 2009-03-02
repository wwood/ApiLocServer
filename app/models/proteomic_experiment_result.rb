class ProteomicExperimentResult < ActiveRecord::Base
  belongs_to :proteomic_experiment
  belongs_to :coding_region
end
