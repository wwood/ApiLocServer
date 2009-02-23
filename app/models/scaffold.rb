class Scaffold < ActiveRecord::Base
  has_many :genes, :dependent => :destroy
  has_many :chromosomal_features, :dependent => :destroy
  belongs_to :species
  
  # Jiang et al. Features
  JIANG_SFP_COUNT_STRAINS = %w(7G8 FCR3 Dd2 HB3)
  has_many :jiang_7g8_ten_kb_bin_sfp_counts, :dependent => :destroy
  has_many :jiang_fcr3_ten_kb_bin_sfp_counts, :dependent => :destroy
  has_many :jiang_dd2_ten_kb_bin_sfp_counts, :dependent => :destroy
  has_many :jiang_hb3_ten_kb_bin_sfp_counts, :dependent => :destroy
  
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
  
  def jiang_bin_sfp_counts(chromosome_position)
    JIANG_SFP_COUNT_STRAINS.collect do |strain|
      jiangs = "Jiang#{strain}TenKbBinSfpCount".constantize.find_all_by_scaffold_id(
        id, 
        :conditions => ['start <= ? and stop >= ?', chromosome_position, chromosome_position]
      )
      raise Exception, "Unexpected number of chromosome bins found for #{self.inspect} for strain #{strain}: #{jiangs}" unless jiangs.length == 1
      jiangs[0].value
    end
  end
end
