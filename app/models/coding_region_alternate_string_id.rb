class CodingRegionAlternateStringId < ActiveRecord::Base
  belongs_to :coding_region

  UNIPROT_SOURCE_NAME = 'UniProt'
  
  named_scope :s, lambda{ |species_name|
    {
      :joins => {:coding_region => {:gene => {:scaffold => :species}}},
      :conditions => ['species.name = ?', species_name]
    }
  }
  named_scope :source, lambda { |source_name|
    {:conditions => ['source = ?', source_name]}
  }
end
