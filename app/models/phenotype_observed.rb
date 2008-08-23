class PhenotypeObserved < ActiveRecord::Base
  has_many :coding_region_phenotype_observeds, :dependent => :destroy
  has_many :coding_regions, :through =>:coding_region_phenotype_observeds
  
  named_scope :lethal, {:conditions => ['phenotype like ?', '%lethal%']}
  
  # Is this observation classified as lethal? See also lethal named scope
  # this method and that should do the same thing.
  def lethal?
    /.*lethal.*/i.match(phenotype)
  end
end
