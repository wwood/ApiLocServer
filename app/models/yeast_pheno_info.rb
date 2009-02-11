class YeastPhenoInfo < ActiveRecord::Base
  has_many :coding_region_yeast_pheno_infos, :dependent => :destroy
  has_many :coding_regions, :through => :coding_region_yeast_pheno_infos
  
  def lethal?
    phenotype === 'inviable'
#    phenotype.match(/inviable/i)
  end
  
  def trusted?
    %w(null
repressible
reduction of function).include?(mutant_type)
  end
end
