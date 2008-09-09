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
  has_many :microarray_timepoints, :through => :microarray_measurements
  has_many :expression_contexts, :dependent => :destroy
  has_many :expressed_localisations, :through => :expression_contexts, :source => :localisation
  has_many :integer_coding_region_measurements, :dependent => :destroy
  
  
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
  
  # Measurements
  has_one :nucleo_nls
  has_one :nucleo_non_nls
  has_one :pats_prediction
  has_one :pats_score
  has_one :pprowler_mtp_score
  has_one :pprowler_other_score
  has_one :pprowler_signal_score
  
  #snp
  has_one :it_synonymous_snp
  has_one :it_non_synonymous_snp
  has_one :pf_clin_synonymous_snp
  has_one :pf_clin_non_synonymous_snp
  
  # Worm project
  # elegans
  has_many :coding_region_phenotype_informations, :dependent => :destroy
  has_many :phenotype_informations, :through => :coding_region_phenotype_informations
  has_many :coding_region_phenotype_observeds, :dependent => :destroy
  has_many :phenotype_observeds, :through => :coding_region_phenotype_observeds
  #mouse
  has_many :coding_region_mouse_phenotype_information, :dependent => :destroy
  has_many :mouse_phenotype_informations, :through => :coding_region_mouse_phenotype_information, :dependent => :destroy
  #yeast
  has_many :coding_region_yeast_pheno_infos, :dependent => :destroy
  has_many :yeast_pheno_infos, :through => :coding_region_yeast_pheno_infos
  #drosophila
  has_many :coding_region_drosophila_allele_genes, :dependent => :destroy
  has_many :drosophila_allele_genes, :through => :coding_region_drosophila_allele_genes
  
  named_scope :species_name, lambda{ |species_name|
    {
      :joins => {:gene => {:scaffold => :species}},
      :conditions => ['species.name = ?', species_name]
    }
  }
  named_scope :top, lambda {|top_name|
    {
      :joins => {:expressed_localisations => :malaria_top_level_localisation},
      :conditions => ['top_level_localisations.name = ?', top_name]
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
  
  def get_species
    gene.scaffold.species
  end
  
  # Based on which species this coding region belongs to, return true if it has any phenotypes that
  # are classified as lethal. Return false if not, and nil if no phenotypes were found at all
  def lethal?
    if get_species.name == Species.elegans_name
      obs = phenotype_observeds
      return nil if obs.empty?
      obs.each do |ob|
        return true if ob.lethal?
      end
      return false
    elsif get_species.name == Species.mouse_name
      obs = mouse_phenotype_informations
      return nil if obs.empty?
      obs.each do |ob|
        return true if ob.mouse_pheno_desc.lethal?
      end
      return false
    elsif get_species.name == Species.yeast_name
      obs = yeast_pheno_infos
      return nil if obs.empty?
      obs.each do |ob|
        return true if ob.lethal?
      end
      return false
    elsif get_species.name == Species.fly_name
      obs = drosophila_allele_genes.pick(:drosophila_allele_phenotypes).flatten
      return nil if obs.empty?
      obs.each do |ob|
        return true if ob.lethal?
      end
      return false
    else
      raise Exception, "Don't know how to handle lethality for coding region: #{inspect}"
    end
    
  end
  
  
  def name_with_localisation
    "#{string_id} - #{localisations.join(' ')}"
  end
  
  class << self
    alias_method(:f, :find_by_name_or_alternate)
    alias_method(:fs, :find_by_name_or_alternate_and_organism)
  end
  
  # convenience method for falciparum
  def self.ff(string_id)
    find_by_name_or_alternate_and_organism(string_id, Species.falciparum_name)
  end
  
  # Print a coding region out like it is in my other localisation spreadsheet
  def localisation_english
    contexts = expression_contexts
    return contexts.pick(:english).sort.join(', ')    
  end
  
  # return true if there is only 1 top level localisation associated with this coding region
  def uniq_top?
    tops.pick(:id).uniq.length == 1
  end
  
  def tops
    TopLevelLocalisation.all(
      :joins => {:malaria_localisations => :expression_contexts},
      :conditions => ['expression_contexts.coding_region_id = ?', id]
    )
  end
  
  # convenience method for getting the single orthomcl gene associated with this coding region.
  # optional argument run_name is the name of the orthomcl_run to be searched for.
  def single_orthomcl(run_name = OrthomclRun.official_run_v2_name, options = {})
    genes = orthomcl_genes.run(run_name).all(options)
    if genes.length != 1
      raise UnexpectedOrthomclGeneCount, "Unexpected number of orthomcl genes found for #{inspect}: #{genes.inspect}"
    else
      return genes[0]
    end
  end
end




class CodingRegionNotFoundException < Exception; end
class UnexpectedOrthomclGeneCount < Exception; end