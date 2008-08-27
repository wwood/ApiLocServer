class CodingRegion < ActiveRecord::Base
  #  validates_presence_of :orientation
  
  has_one :coding_region_go_term, :dependent => :destroy
  has_many :go_terms, 
    {:through => :coding_region_go_term}
  belongs_to :gene
  has_many :cds, :dependent => :destroy
  has_many :coding_region_alternate_string_ids, :dependent => :destroy
  has_many :derisi20063d7_logmeans
  has_many :plasmodb_gene_list_entries
  has_many :plasmodb_gene_lists, :through => :plasmodb_gene_list_entries
  has_many :localisations, :through => :coding_region_localisations
  has_many :coding_region_localisations, :dependent => :destroy
  has_many :orthomcl_gene_coding_regions, :dependent => :destroy
  has_many :orthomcl_genes, :through => :orthomcl_gene_coding_regions
  has_one :annotation, :dependent => :destroy
  has_one :amino_acid_sequence, :dependent => :destroy
  has_many :microarray_measurements, :dependent => :destroy
  
  
  # transmembrane domain things
  has_many :transmembrane_domain_measurements, :dependent => :destroy
  has_one :toppred_min_transmembrane_domain_length, :dependent => :destroy
  has_one :toppred_average_transmembrane_domain_length, :dependent => :destroy
  has_one :min_transmembrane_domain_length, :dependent => :destroy
  has_one :memsat_min_transmembrane_domain_length, :dependent => :destroy
  has_one :memsat_average_transmembrane_domain_length, :dependent => :destroy
  has_one :memsat_transmembrane_domain_count, :dependent => :destroy
  has_one :memsat_max_transmembrane_domain_length, :dependent => :destroy
  
  has_many :membrain_transmembrane_domains
  
  # Worm project
  # elegans
  has_many :coding_region_phenotype_informations, :dependent => :destroy
  has_many :phenotype_informations, :through => :coding_region_phenotype_informations
  has_many :coding_region_phenotype_observeds, :dependent => :destroy
  has_many :phenotype_observeds, :through => :coding_region_phenotype_observeds
  #mouse
  has_many :coding_region_mouse_phenotype_information, :dependent => :destroy
  has_many :mouse_phenotype_informations, :through => :coding_region_mouse_phenotype_information, :dependent => :destroy
  
  named_scope :species_name, lambda{ |species_name|
    ActiveRecord::Base.logger.debug ';yessiree'
    {
      :joins => {:gene => {:scaffold => :species}},
      :conditions => ['species.name = ?', species_name]
    }
  }
  
  POSITIVE_ORIENTATION = '+'
  NEGATIVE_ORIENTATION = '-'
  UNKNOWN_ORIENTATION = 'U'
  
  def calculate_upstream_region
    
    scaffold_id = gene.scaffold_id
    
    # If positive orientation
    if positive_orientation?
      first = first_base_scaffold_wise
      
      # find the nearest upstream cds of this coding region
      # that is on the same scaffold
      butting = Cd.find(:first, {:order => 'Cds.stop desc', 
          :include => [:coding_region => {:gene => :scaffold}],
          :conditions => "stop < #{first} and genes.scaffold_id=#{scaffold_id}"})

      if !butting
        return nil
      end
     
      return first_base_scaffold_wise - butting.stop
    elsif negative_orientation?
      last = last_base_scaffold_wise
      butting = Cd.find(:first, {:order => 'Cds.stop', 
          :include => [:coding_region => {:gene => :scaffold}],
          :conditions => "start > #{last} and scaffold_id=#{scaffold_id}"})
      
      if !butting
        return nil
      end

      return butting.start - last
    end
    
    raise Exception, "No proper orientation found so couldn't calculate upstream distance"
  end

  
  def positive_orientation?
    return orientation === POSITIVE_ORIENTATION
  end
  
  def negative_orientation?
    return orientation === NEGATIVE_ORIENTATION
  end


  def first_base_scaffold_wise
    cs = cds_scaffold_wise
    if cs
      return cs[0].start
    else
      return nil
    end
  end
  
  def last_base_scaffold_wise
    cs = cds_scaffold_wise
    if cs
      return cs[cs.length-1].stop
    else
      return nil
    end
  end
  
  def cds_scaffold_wise
    if !cds or cds.empty?
      return nil
    else
      return cds.sort { |a,b|  a.start <=> b.start }
    end
  end
  
  
  # Return the coding region associated with the string id. The string_id
  # can be either a real id, or an alternate id.
  def self.find_by_name_or_alternate(string_id)
    simple = CodingRegion.find_by_string_id string_id
    if simple
      return simple
    else
      alt = CodingRegionAlternateStringId.find_by_name string_id
      if alt
        return alt.coding_region
      else
        return nil
      end
    end
  end
  
  # Return the coding region associated with the string id. The string_id
  # can be either a real id, or an alternate id.
  def self.find_all_by_name_or_alternate(string_id)
    simple = CodingRegion.find_all_by_string_id string_id
    if simple
      return simple
    else
      alts = CodingRegionAlternateStringId.find_all_by_name string_id
      if alts
        return alts.pick(:coding_region)
      else
        return []
      end
    end
  end
  
  def self.find_by_name_or_alternate_and_organism(string_id, organism_common_name)
    simple = CodingRegion.find(:first,
      :include => {:gene => {:scaffold => :species}},
      :conditions => ["species.name=? and coding_regions.string_id=?", 
        organism_common_name, string_id
      ]
    )
    if simple
      return simple
    else
      alt = CodingRegionAlternateStringId.find(:first,
        :include => {:coding_region => {:gene => {:scaffold => :species}}},
        :conditions => ["species.name= ? and coding_region_alternate_string_ids.name= ?", 
          organism_common_name, string_id
        ]
      )
      if alt
        return alt.coding_region
      else
        return nil
      end
    end    
  end
  
  def self.unknown_orientation_char
    UNKNOWN_ORIENTATION
  end
  
  
  # return the sequence without a signal peptide
  def sequence_without_signal_peptide
    if !amino_acid_sequence
      raise CodingRegionNotFoundException, "No amino acid sequence found for coding region #{string_id}"
    end
    seq = amino_acid_sequence.sequence
    sp_result = SignalP.calculate_signal(seq)
    return sp_result.cleave(seq)
  end
  
  
  
  def self.transmembrane_data_columns
    [
      'ID',
      'Annotation',
      'TMHMM2 Min',
      'TMHMM2 Average',
      'TMHMM2 Max',
      'TMHMM2 Count',
      'MEMSAT Min',
      'MEMSAT Average',
      'MEMSAT Max',
      'MEMSAT Count'
    ]
  end
  
  # return all the transmembrane data for this coding region
  def transmembrane_data
    to_print = []
    
    to_print.push [
      string_id,
      annotation ? "\"#{annotation.annotation}\"" : nil #no annotation if I don't have any
    ]
      
      
    # print tmhmm2 stuff
    minus_sp = sequence_without_signal_peptide
    tmhmm_result = TmHmmWrapper.new.calculate(minus_sp)
    if tmhmm_result.transmembrane_domains.length > 0
      to_print.push [
        tmhmm_result.minimum_length,
        tmhmm_result.average_length,
        tmhmm_result.maximum_length,
        tmhmm_result.transmembrane_domains.length
      ]
    else
      (1..4).each do to_print.push '' end
    end
      
    #print memsat stuff
    if memsat_min_transmembrane_domain_length
      to_print.push [
        memsat_min_transmembrane_domain_length.measurement,
        memsat_average_transmembrane_domain_length.measurement,
        memsat_max_transmembrane_domain_length.measurement,
        memsat_transmembrane_domain_count.measurement
      ]
    else
      (1..4).each do to_print.push '' end
    end
    
    return to_print
  end
  
  
  # Given a coding region, return the orthologs in another species, as given
  # by orthomcl
  def orthomcls(species_common_name)
    CodingRegion.all(
      :joins => [
        {:gene => {:scaffold => :species}},
        {:orthomcl_genes => {:orthomcl_group => [
              :orthomcl_run,
              {:orthomcl_genes => :coding_regions}
            ]
          }}
      ],
      :conditions => ['species.name = ? and orthomcl_runs.name = ? and coding_regions_orthomcl_genes.id = ?',
        species_common_name, 
        OrthomclRun.official_run_v2_name,
        id
      ]
    )
  end
  
  
  
  # return all the names (string_id and alternate string_ids) of this record
  def names
    [string_id, coding_region_alternate_string_ids.collect{|s| s.name}].flatten
  end
  
  def self.negative_orientation
    NEGATIVE_ORIENTATION
  end
  
  def self.positive_orientation
    POSITIVE_ORIENTATION
  end
  
  def set_negative_orientation
    self.orientation = NEGATIVE_ORIENTATION
  end
  
  def set_positive_orientation
    self.orientation = POSITIVE_ORIENTATION
  end
end

class CodingRegionNotFoundException < Exception
end
