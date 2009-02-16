require 'bio'
require 'gmars'
require 'n_c_b_i'
require 'go'

class CodingRegion < ActiveRecord::Base
  
  #  validates_presence_of :orientation
  
  has_many :coding_region_go_terms, :dependent => :destroy
  has_many :go_terms, 
    {:through => :coding_region_go_terms}
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
  has_one :transcript_sequence, :dependent => :destroy
  has_many :microarray_measurements, :dependent => :destroy
  has_many :microarray_timepoints, :through => :microarray_measurements
  has_many :expression_contexts, :dependent => :destroy
  has_many :expressed_localisations, :through => :expression_contexts, :source => :localisation
  has_many :integer_coding_region_measurements, :dependent => :destroy
  
  
  # transmembrane domain things
  has_many :transmembrane_domain_measurements, :dependent => :destroy
  has_many :transmembrane_domain_lengths, :dependent => :destroy
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
  
  has_many :wolf_psort_predictions
  
  #snp
  has_one :it_synonymous_snp
  has_one :it_non_synonymous_snp
  has_one :pf_clin_synonymous_snp
  has_one :pf_clin_non_synonymous_snp
  has_one :neafsey_intronic_snp
  has_one :neafsey_synonymous_snp
  has_one :neafsey_non_synonymous_snp
  has_one :mu_bp_surveyed
  has_one :mu_synonymous_snp
  has_one :mu_non_coding_snp
  has_one :mu_non_synonymous_snp
  has_one :mu_pi
  has_one :mu_theta

  # Worm project
  # elegans
  has_many :coding_region_phenotype_informations, :dependent => :destroy
  has_many :phenotype_informations, :through => :coding_region_phenotype_informations
  has_many :coding_region_phenotype_observeds, :dependent => :destroy
  has_many :phenotype_observeds, :through => :coding_region_phenotype_observeds
  #mouse
  has_many :coding_region_mouse_phenotypes, :dependent => :destroy
  has_many :mouse_phenotypes, :through => :coding_region_mouse_phenotypes, :dependent => :destroy
  #yeast
  has_many :coding_region_yeast_pheno_infos, :dependent => :destroy
  has_many :yeast_pheno_infos, :through => :coding_region_yeast_pheno_infos
  #drosophila
  has_many :coding_region_drosophila_allele_genes, :dependent => :destroy
  has_many :drosophila_allele_genes, :through => :coding_region_drosophila_allele_genes
  
  acts_as_signalp :sequence_method => :aaseq
  
  # cached results
  has_one :export_pred_cache, :dependent => :destroy
  has_one :signal_p_cache, :dependent => :destroy
  has_one :segmasker_low_complexity_percentage, :dependent => :destroy
  
  # website stuff
  has_many :user_comments
  
  named_scope :species_name, lambda{ |species_name|
    {
      :joins => {:gene => {:scaffold => :species}},
      :conditions => ['species.name = ?', species_name]
    }
  }
  named_scope :s, lambda{ |species_name|
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
  named_scope :orthomcl_three_letter, lambda {|orthomcl_three_letter|
    {
      :joins => {:gene => {:scaffold => :species}},
      :conditions => ['species.orthomcl_three_letter = ?', orthomcl_three_letter]
    }   
  }
  named_scope :apicomplexan, {
    :joins => {:gene => {:scaffold => :species}},
    :conditions => ['species.name in (?)', Species.apicomplexan_names]
  }
  # This named scope slows down queries by a lot (in the order of a second), and
  # I'm not sure how to fix this. In the meantime use find_by_name_or_alternate - it is much faster
  # # explain ANALYZE SELECT "coding_regions".* FROM "coding_regions" INNER JOIN "coding_region_alternate_string_ids" ON coding_region_alternate_string_ids.coding_region_id = coding_regions.id WHERE (coding_regions.string_id = E'PF01_0013' or coding_region_alternate_string_ids.name = E'PF01_0013') LIMIT 1;
  #  QUERY PLAN                                                                                                          
  #  ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  #  Limit  (cost=7.24..19614.11 rows=1 width=41) (actual time=1151.973..1151.973 rows=0 loops=1)
  #  ->  Merge Join  (cost=7.24..39220.98 rows=2 width=41) (actual time=1151.971..1151.971 rows=0 loops=1)
  #  Merge Cond: (coding_regions.id = coding_region_alternate_string_ids.coding_region_id)
  #  Join Filter: (((coding_regions.string_id)::text = 'PF01_0013'::text) OR ((coding_region_alternate_string_ids.name)::text = 'PF01_0013'::text))
  #  ->  Index Scan using coding_regions_pkey on coding_regions  (cost=0.00..16080.44 rows=486531 width=41) (actual time=0.043..278.063 rows=486531 loops=1)
  #  ->  Index Scan using index_coding_region_alternate_string_ids_on_coding_region_id on coding_region_alternate_string_ids  (cost=0.00..14172.58 rows=442950 width=15) (actual time=0.058..264.951 rows=442950 loops=1)
  #  Total runtime: 1152.022 ms
  #  (7 rows)
  named_scope :name_or_alternate, lambda {|name_or_alternate|
    {
      :joins => :coding_region_alternate_string_ids,
      :conditions => ['coding_regions.string_id = ? or coding_region_alternate_string_ids.name = ?' , name_or_alternate, name_or_alternate]
    }   
  }
  named_scope :falciparum, {
    :joins => {:gene => {:scaffold => :species}},
    :conditions => ['species.name = ?', Species.falciparum_name]
  }
  named_scope :list, lambda {|gene_list_name|
    {
      :joins => :plasmodb_gene_lists,
      :conditions => ['plasmodb_gene_lists.description = ?', gene_list_name]
    }
  }
  named_scope :localised, {
    :joins => :expressed_localisations
  }
  
  POSITIVE_ORIENTATION = '+'
  NEGATIVE_ORIENTATION = '-'
  UNKNOWN_ORIENTATION = 'U'
  
  concerned_with :machine_learning
  
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
    if !simple.empty?
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
  
  # Return the coding region associated with the string id. The string_id
  # can be either a real id, or an alternate id.
  def self.find_all_by_name_or_alternate_and_species(string_id, species_common_name)
    simple = CodingRegion.s(species_common_name).find_all_by_string_id string_id
    if !simple.empty?
      return simple
    else
      alts = CodingRegionAlternateStringId.s(species_common_name).find_all_by_name string_id
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
  
  
  def find_by_name_or_alternate_and_orthomcl_three_letter(name, orthomcl_three_letter)
    simple = CodingRegion.find(:first,
      :joins => {:gene => {:scaffold => :species}},
      :conditions => ["species.orthomcl_three_letter=? and coding_regions.string_id=?", 
        orthomcl_three_letter, name
      ]
    )
    if simple
      return simple
    else
      alt = CodingRegionAlternateStringId.find(:first,
        :joins => {:coding_region => {:gene => {:scaffold => :species}}},
        :conditions => ["species.orthomcl_three_letter=? and coding_regions.string_id=?", 
          orthomcl_three_letter, name
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
    sp_result = signalp_however
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
  
  def tmhmm
    minus_sp = sequence_without_signal_peptide
    TmHmmWrapper.new.calculate(minus_sp)
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
  
  def alternate_names
    coding_region_alternate_string_ids.collect{|s| s.name}.uniq.select{|n| n}
  end
  
  # all the names with null and repeats taken out
  def nice_names
    names.uniq.select{|n| n}
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
    return nil unless phenotype_information?
    
    if get_species.name == Species.elegans_name
      obs = phenotype_observeds
      # It is ok that it has no phenotype_observeds, if it has phenotype_informations,
      # which it does according to CodingRegion#phenotype_information?
      obs.each do |ob|
        return true if ob.lethal?
      end
      return false
    elsif get_species.name == Species.mouse_name
      obs = mouse_phenotypes.trusted.all(:include => :mouse_phenotype_dictionary_entries)
      raise Exception, "Unexpected lack of phenotype information for #{inspect}" if obs.empty?
      obs.each do |ob|
        if ob.lethal?
          return true
        end
      end
      return false
    elsif get_species.name == Species.yeast_name
      obs = yeast_pheno_infos.trusted.all
      raise Exception, "Unexpected lack of phenotype information for #{inspect}" if obs.empty?
      obs.each do |ob|
        return true if ob.lethal?
      end
      return false
    elsif get_species.name == Species.fly_name
      obs = drosophila_allele_genes.pick(:drosophila_allele_phenotypes).flatten
      raise Exception, "Unexpected lack of phenotype information for #{inspect}" if obs.empty?
      obs.each do |ob|
        return true if ob.lethal?
      end
      return false
    else
      raise Exception, "Don't know how to handle lethality for coding region: #{inspect}"
    end
    
  end
  
  # Returns true iff there is sufficient data available for this coding region
  # to be classified as lethal? or not
  def phenotype_information?
    if get_species.name == Species.elegans_name
      return coding_region_phenotype_informations.count > 0
    elsif get_species.name == Species.mouse_name
      return mouse_phenotypes.trusted.count > 0
    elsif get_species.name == Species.yeast_name
      return yeast_pheno_infos.trusted.count > 0
    elsif get_species.name == Species.fly_name
      return !drosophila_allele_genes.pick(:drosophila_allele_phenotypes).flatten.empty?
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
  
  def single_top_level_localisation
    stuffs = tops.uniq
    raise Exception, "Unexpected number of top level localisations for #{string_id}: #{stuffs.inspect}" if stuffs.length != 1
    return stuffs[0]
  end
  
  # convenience method for getting the single orthomcl gene associated with this coding region.
  # optional argument run_name is the name of the orthomcl_run to be searched for.
  def single_orthomcl(run_name = OrthomclRun.official_run_v2_name, options = {})
    genes = orthomcl_genes.run(run_name).all(options)
    if genes.length != 1
      raise CodingRegion::UnexpectedOrthomclGeneCount, "Unexpected number of orthomcl genes found for #{inspect}: #{genes.inspect}"
    else
      return genes[0]
    end
  end
  
  
  # annotation of the species with babesia orthologs
  def babesia_ortholog_anntoations
    results = [
      string_id,
      nice_names.join(', '),
      annotation.annotation,
      expressed_localisations.known.pick(:name).uniq.join(', '),
      expression_contexts.all.reach.publication.definition.uniq.join(', ')
    ]
    babesias = []
    begin
      group = single_orthomcl(OrthomclRun.seven_species_name).orthomcl_group
      babesias = group.orthomcl_genes.all(
        :conditions => ['orthomcl_name like ?', 'BB%']
      )
          
      falciparums = CodingRegion.falciparum.all(
        :joins => :orthomcl_genes,
        :conditions => {:orthomcl_genes => {:orthomcl_group_id => group.id}}
      )

      if !babesias.empty?
        results.push babesias.pick(:orthomcl_name).join(', ')
        results.push babesias.collect{|b| b.single_code.annotation.annotation}.join(' || ')
        results.push falciparums.reach.reject{|f| f.id == id}.reach.string_id.join(', ')
      else
        return nil
      end
    rescue UnexpectedOrthomclGeneCount => e
      return nil
    end
    return results
  end
  
  # convenience method to reduce typing
  def species
    gene.scaffold.species
  end
  
  # Calculate/retrieve the winning WoLF_PSORT localisation for this coding
  # region, given the sequence is already associated with this coding region
  def wolf_psort_localisation(psort_organism_type)
    # Check if they have already been cached
    preds = wolf_psort_predictions.all(:conditions => ['organism_type =?', psort_organism_type], :order => 'score desc')
    if preds.length > 0
      # cached
      return preds[0].localisation
    else # not cached, run from scratch
      cache_wolf_psort_predictions
      preds = wolf_psort_predictions.all(:conditions => ['organism_type =?', psort_organism_type], :order => 'score desc')
      if preds.length > 0
        # cached
        return preds[0].localisation
      else
        return nil
      end
    end
  end
  
  # All the highest localisations, including those that came second that really
  # have the same score as the top one. If a dual localisation is there, then both are returned
  def wolf_psort_localisations(psort_organism_type)
    # Check if they have already been cached
    preds = wolf_psort_predictions.all(:conditions => ['organism_type =?', psort_organism_type], :order => 'score desc')
    locs = nil
    if preds.length > 0
      newpreds = wolf_psort_predictions.all(:conditions => ['organism_type =? and score = ?', psort_organism_type, preds[0].score])
      # cached
      locs = newpreds.reach.localisation
    else # not cached, run from scratch
      Bio::PSORT::WoLF_PSORT.exec_local_from_sequence(amino_acid_sequence.sequence, psort_organism_type).highest_predicted_localization
    end
  end
  
  # Read only from the cache, don't run it if no cache exists
  def cached_wolf_psort_localisation(psort_organism_type)
    # Check if they have already been cached
    preds = wolf_psort_predictions.all(:conditions => ['organism_type =?', psort_organism_type], :order => 'score desc')
    if preds.length > 0
      # cached
      return preds[0].localisation
    else # not cached, run from scratch
      return nil
    end    
  end
  
  def cache_wolf_psort_predictions
    if !amino_acid_sequence
      $stderr.puts "Unable to run WoLF_PSORT because there is no amino acid sequence for #{inspect}"
      return
    end
    
    Bio::PSORT::WoLF_PSORT::ORGANISM_TYPES.each do |organism_type|
      logger.warn "Running WoLF_PSORT using organism type '#{organism_type}' on #{string_id}"
      result = Bio::PSORT::WoLF_PSORT.exec_local_from_sequence(amino_acid_sequence.sequence, organism_type)
      next if !result #skip sequences that are too short
      
      result.score_hash.each do |loc, score|
        w = WolfPsortPrediction.find_or_create_by_coding_region_id_and_organism_type_and_localisation_and_score(id, organism_type, loc, score)
        self.wolf_psort_predictions << w
      end  
    end
    
    self.wolf_psort_predictions
  end
  
  def wolf_psort_localisations_line(organism_type)
    wolf_psort_predictions.all(:conditions => {:organism_type => organism_type}, :order => 'score desc').collect{ |pred|
      "#{pred.localisation} #{pred.score}"
    }.join(", ")
  end
  
  # The sum of the linkages emanating from this coding region in
  # wormnet core
  def wormnet_core_total_linkage_scores
    CodingRegionNetworkEdge.coding_region_id(id).wormnet_core.all.reach.strength.sum
  end
  
  # The number of the linkages emanating from this coding region in
  # wormnet core
  def wormnet_core_number_interactions
    CodingRegionNetworkEdge.coding_region_id(id).wormnet_core.count
  end
  
  def wormnet_full_total_linkage_scores
    CodingRegionNetworkEdge.coding_region_id(id).wormnet.all.reach.strength.sum
  end
 

  def wormnet_full_number_interactions
    CodingRegionNetworkEdge.coding_region_id(id).wormnet.count
  end

  # determine whether this coding region is classified as an enzyme
  # according to the associated GO terms.
  # WARNING: This method is not thread-safe due
  # to the static variables
  def is_enzyme?
    @@go_object ||= Bio::Go.new
    @@go_enzyme_subsumer ||= @@go_object.subsume_tester(GoTerm::ENZYME_GO_TERM)
    
    go_terms.all.reach.go_identifier.select{|go_id| 
      @@go_enzyme_subsumer.subsume?(go_id)
    }.length > 0
  end
  
  # determine whether this coding region is classified as gpcr 
  # according to the associated GO terms.
  # WARNING: This method is not thread-safe due
  # to the static variables
  def is_gpcr?
    @@go_object ||= Bio::Go.new
    @@go_gpcr_subsumer ||= @@go_object.subsume_tester(GoTerm::GPCR_GO_TERM)
    
    go_terms.all.reach.go_identifier.select{|go_id|
      @@go_gpcr_subsumer.subsume?(go_id)
    }.length > 0
  end
  
  def aaseq
    amino_acid_sequence ? amino_acid_sequence.sequence : nil
  end
  
  class UnexpectedOrthomclGeneCount < StandardError; end
  
  # Return the golgi consensus sequences that the amino acid
  # sequence of this coding region is attached to. Return [] if none
  # are found or if there is no amino acid sequence attached
  def golgi_consensi
    return [] if !aaseq
    
    consensi = []
    
    [GolgiNTerminalSignal, GolgiCTerminalSignal].each do |model|
      model.all.each do |s|
        consensi.push s if aaseq.match(s.regex)
      end
    end
    consensi
  end
  
  # Return true iff this coding region is either a pseudogene
  # or rifin, stevor, surfin, PfEMP1, etc.
  # This method is probably not perfect because it only calculates
  # the returned value based on the annotation.
  # Manually checked the results for PlasmoDB v5.5 and there was no
  # false positives at least, though.
  def falciparum_cruft?
    return false unless annotation # ignore unannotated sequences
    
    a = annotation.annotation
    [/var /i,/pfemp1/i, /pseudogene/i, /rifin/i, /stevor/i, /surfin/i, /RESA/].each do |crap|
      if annotation.annotation.match(crap)
        return true
      end
    end
    return false
  end
  
  # Return the saved exportpred result, or calculate
  # it if this does not exist
  def export_pred_however
    return nil if aaseq.nil?
    
    return export_pred_cache unless export_pred_cache.nil? #returned cached if possible
    
    # otherwise just calculate the bastard
    result = Bio::ExportPred::Wrapper.new.calculate(aaseq)
    self.export_pred_cache = ExportPredCache.create_from_result(id, result)
    return export_pred_cache
  end
  
  # Return the saved signalp result, or calculate
  # it if this does not exist
  def signalp_however
    return nil if aaseq.nil?
    return signal_p_cache if signal_p_cache #returned cached if possible

    # otherwise just calculate the bastard
    logger.debug "Running SignalP on #{string_id}"
    result = SignalSequence::SignalPWrapper.new.calculate(aaseq)
    res = SignalPCache.create_from_result(id, result)
    self.signal_p_cache = res
    return res
  end
  
  def signal?
    signalp_however.signal?
  end
  
  # Return the saved signalp result, or calculate
  # it if this does not exist
  def segmasker_low_complexity_percentage_however
    return nil if aaseq.nil?
    return segmasker_low_complexity_percentage.value if segmasker_low_complexity_percentage #returned cached if possible

    # otherwise just calculate the bastard
    logger.debug "Running Segmasker on #{string_id}"
    result = Bio::SegmaskerWrapper.new.calculate(aaseq)
    res = SegmaskerLowComplexityPercentage.new(:value => (result.total_masked_length.to_f/aaseq.length.to_f))
    self.segmasker_low_complexity_percentage = res
    return res.value
  end
  
  def hypothetical_by_annotation?
    annotation.annotation.match(/hypothetical/i)
  end
  
  def plasmo_a_p
    amino_acid_sequence.plasmo_a_p
  end
  
  # Comments on http://railscasts.com/episodes/35 says this is the way to make
  # coding regions RESTful. Comes into play when coding_region_path(code)
  # is called from a controller or action.
  def to_param
    "#{string_id}"
  end
end




class CodingRegionNotFoundException < Exception; end
#class UnexpectedOrthomclGeneCount < Exception; end