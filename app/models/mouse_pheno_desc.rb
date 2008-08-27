class MousePhenoDesc < ActiveRecord::Base
  belongs_to :mouse_phenotype_information
  
  named_scope :lethal, {:conditions => ['pheno_desc like ?', '%lethal%']}
  
  def lethal?
    /.*lethal.*/i.match(pheno_desc)
  end
end
