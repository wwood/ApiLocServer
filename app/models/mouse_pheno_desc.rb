class MousePhenoDesc < ActiveRecord::Base
  has_many :mouse_phenotype_informations
  
  # Commented out named scope because lethal? method changed, leaving this
  # one inaccurate
  #  named_scope :lethal, {:conditions => ['pheno_desc like ?', '%lethal%']}
  
  # Tests if the pheno_desc attribute says lethal, and that the 
  # phenotyp_information is of a valid type
  def lethal?
    return false if /.*lethal.*/i.match(pheno_desc).nil?
    mouse_phenotype_informations.each do |info|
      return true if [
        'Chemically and radiation induced',
        'Chemically induced (ENU)',
        'Chemically induced (other)',
        'Gene trapped',
        'Radiation induced',
        'Spontaneous',
        'Targeted (knock-out)',
        'Targeted (Reporter)',
        'Transgenic (random, gene disruption)'
      ].include?(info.allele_type)
    end
    return false
  end
end
