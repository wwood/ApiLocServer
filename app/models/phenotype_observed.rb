class PhenotypeObserved < ActiveRecord::Base
  has_many :coding_region_phenotype_observeds, :dependent => :destroy
  has_many :coding_regions, :through =>:coding_region_phenotype_observeds
  
  named_scope :lethal, {:conditions => ['phenotype like ?', '%lethal%']}
end
