class Scaffold < ActiveRecord::Base
  has_many :genes, :dependent => :destroy
  has_many :chromosomal_features, :dependent => :destroy
  belongs_to :species
  
  named_scope :species_name, lambda {|species_common_name|
    {
      :joins => :species, 
      :conditions => {:species => {:name => species_common_name}}
    }
  }
  
  def self.find_falciparum_chromosome(chromosome_number)
    scaffs = Scaffold.species_name(Species::FALCIPARUM_NAME).find_all_by_name("apidb\|MAL#{chromosome_number}")
    raise Exception, "Unexpected number of falciparum scaffolds found: #{scaffs}" unless scaffs.length == 1
    return scaffs[0]
  end
end
