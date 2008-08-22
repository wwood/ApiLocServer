class PhenotypeObserved < ActiveRecord::Base
  belongs_to :coding_region
  
  named_scope :lethal, {:conditions => ['phenotype like ?', '%lethal%']}
end
