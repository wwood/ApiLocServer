require 'array_pair'

class MousePhenotype < ActiveRecord::Base
  has_many :coding_region_mouse_phenotypes, :dependent => :destroy
  has_many :coding_regions, :through => :coding_region_mouse_phenotypes
  
  has_many :mouse_phenotype_mouse_phenotype_dictionary_entries, :dependent => :destroy
  has_many :mouse_phenotype_dictionary_entries, :through => :mouse_phenotype_mouse_phenotype_dictionary_entries
  
  # Tests if the pheno_desc attribute says lethal, and that the
  # phenotyp_information is of a valid type
  def lethal?
    return false unless by_mutation?
    mouse_phenotype_dictionary_entries.each do |dick|
      return true if /.*lethal.*/i.match(dick.pheno_desc)
    end
    return false
  end
  
  TRUSTED_ALLELE_TYPES = [
    'Chemically and radiation induced',
    'Chemically induced (ENU)',
    'Chemically induced (other)',
    'Gene trapped',
    'Radiation induced',
    'Spontaneous',
    'Targeted (knock-out)',
    'Targeted (Reporter)',
    'Targeted (Floxed/Flt)',
    'Transgenic (random, gene disruption)'
  ]
  named_scope :trusted, {
    :conditions => "allele_type in #{TRUSTED_ALLELE_TYPES.to_sql_in_string}"
  }
  
  # Only certain sources of data are interesting to us, and this method
  # returns if this phenotype_information is one of those.
  def by_mutation?
    return true unless MousePhenotype.trusted.find_by_id(id).nil?
    return false
  end
end
