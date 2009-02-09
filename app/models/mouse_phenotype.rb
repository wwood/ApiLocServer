class MousePhenotype < ActiveRecord::Base
  has_many :coding_region_mouse_phenotypes
  has_many :coding_regions, :through => :coding_region_mouse_phenotypes
  
  has_many :mouse_phenotype_mouse_phenotype_dictionary_entries
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
  
  # Only certain sources of data are interesting to us, and this method
  # returns if this phenotype_information is one of those.
  def by_mutation?
    [
      'Chemically and radiation induced',
      'Chemically induced (ENU)',
      'Chemically induced (other)',
      'Gene trapped',
      'Radiation induced',
      'Spontaneous',
      'Targeted (knock-out)',
      'Targeted (Reporter)',
      'Transgenic (random, gene disruption)'
    ].include?(allele_type)
  end
end
