class MousePhenotypeInformation < ActiveRecord::Base
  has_many :coding_region_mouse_phenotype_informations
  has_many :coding_regions, :through => :coding_region_mouse_phenotype_informations
  
  belongs_to :mouse_pheno_desc
  
  # Tests if the pheno_desc attribute says lethal, and that the
  # phenotyp_information is of a valid type
  def lethal?
    if [
        'Chemically and radiation induced',
        'Chemically induced (ENU)',
        'Chemically induced (other)',
        'Gene trapped',
        'Radiation induced',
        'Spontaneous',
        'Targeted (knock-out)',
        'Targeted (Reporter)',
        'Transgenic (random, gene disruption)'
      ].include?(allele_type) and 
        /.*lethal.*/i.match(mouse_pheno_desc.pheno_desc)
      return true
    end
    return false
  end
end
