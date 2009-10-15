class Scaffold < ActiveRecord::Base
  has_many :genes, :dependent => :destroy
  has_many :chromosomal_features, :dependent => :destroy
  belongs_to :species
  
  # Jiang et al. Features
  JIANG_SFP_COUNT_STRAINS = %w(7G8 FCR3 Dd2 HB3)
  has_many :jiang_7g8_ten_kb_bin_sfp_counts, :dependent => :destroy, :class_name => 'Jiang7G8TenKbBinSfpCount'
  has_many :jiang_fcr3_ten_kb_bin_sfp_counts, :dependent => :destroy, :class_name => 'JiangFCR3TenKbBinSfpCount'
  has_many :jiang_dd2_ten_kb_bin_sfp_counts, :dependent => :destroy, :class_name => 'JiangDd2TenKbBinSfpCount'
  has_many :jiang_hb3_ten_kb_bin_sfp_counts, :dependent => :destroy, :class_name => 'JiangHB3TenKbBinSfpCount'

  # Dummy scaffold name for genes that don't exist yet, when they should
  UNANNOTATED_GENES_DUMMY_SCAFFOLD_NAME = "Dummy scaffold for genes that don't exist"
  
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

  # the first coding region that starts or stops after the cutoff
  def downstreamest_coding_region(cutoff=0)
    # Find the max start and max stop on this scaffold, then
    # give it to the lowest number
    miss_start = Cd.first(
      :order => 'start asc',
      :joins => {:coding_region => {:gene => :scaffold}},
      :conditions =>
        ['scaffolds.id = ? and cds.start > ?', id, cutoff]
    )
    miss_stop = Cd.first(
      :order => 'stop asc',
      :joins => {:coding_region => {:gene => :scaffold}},
      :conditions =>
        ['scaffolds.id = ? and cds.stop > ?', id, cutoff]
    )

    # We have reached the end of the chromosome
    return nil if miss_start.nil? and miss_stop.nil?

    if miss_start.start < miss_stop.stop
      return miss_start.coding_region
    else
      return miss_stop.coding_region
    end
  end
end
