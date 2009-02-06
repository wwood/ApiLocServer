class MousePhenoDesc < ActiveRecord::Base
  has_one :mouse_phenotype_information
  
  # Commented out named scope because lethal? method changed, leaving this
  # one inaccurate
  #  named_scope :lethal, {:conditions => ['pheno_desc like ?', '%lethal%']}
  
  # Tests if the pheno_desc attribute says lethal, and that the 
  # phenotyp_information is of a valid type
  def lethal?
    # Need information, otherwise just return false
    return false unless mouse_phenotype_information

    return (
      !(/.*lethal.*/i.match(pheno_desc).nil?) and 
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
      ].include?(mouse_phenotype_information.allele_type)
    )
  end
end
