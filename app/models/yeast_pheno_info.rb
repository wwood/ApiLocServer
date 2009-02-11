require 'array_pair'

class YeastPhenoInfo < ActiveRecord::Base
  has_many :coding_region_yeast_pheno_infos, :dependent => :destroy
  has_many :coding_regions, :through => :coding_region_yeast_pheno_infos
  
  def lethal?
    phenotype === 'inviable'
    #    phenotype.match(/inviable/i)
  end
  
  TRUSTED_MUTANT_TYPES = %w(null
repressible
reduction of function)
  named_scope :trusted, {
    :conditions => "mutant_type in #{TRUSTED_MUTANT_TYPES.to_sql_in_string}"
  }
  
  def trusted?
    return true unless MousePhenotype.trusted.find_by_id(id).nil?
    return false
  end
end
