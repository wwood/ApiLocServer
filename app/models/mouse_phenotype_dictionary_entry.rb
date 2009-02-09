class MousePhenotypeDictionaryEntry < ActiveRecord::Base
  has_many :mouse_phenotype_mouse_phenotype_dictionary_entries, :dependent => :destroy
  has_many :mouse_phenotypes, :through => :mouse_phenotype_mouse_phenotype_dictionary_entries
end
