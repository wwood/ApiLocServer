class MousePhenotypeMousePhenotypeDictionaryEntry < ActiveRecord::Base
  belongs_to :mouse_phenotype
  belongs_to :mouse_phenotype_dictionary_entry
end
