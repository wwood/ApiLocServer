class CodingRegion < ActiveRecord::Base
  # compare this coding region to another, and record whether it
  # 1. agrees perfectly
  # 2. agrees but complex (one coding region has 2 organelles, the other has only 1 of these)
  # 3. disagree
  # 4. not known (no organellar annotation for one of them)
  def compare_localisation(coding_region2)
    compare_localisation_to_list(coding_region2.compartments)
  end
  
  # compare this coding region to an array of localisations, and record whether it
  # 1. agrees perfectly
  # 2. agrees but complex (one coding region has 2 organelles, the other has only 1 of these)
  # 3. disagree
  # 4. not known (no organellar annotation for one of them)
  def compare_localisation_to_list(localisations_to_compare_to)
    # gather each of the organelle ontologies for both coding regions
    organelles1 = compartments
    
    
    # compare the organelles, recording which ones are in common
    c = OntologyComparison.new
    
    # First get the unknowns out of the way
    if organelles1.nil? or localisations_to_compare_to.nil? or
      organelles1.empty? or localisations_to_compare_to.empty?
      c.agreement = OntologyComparison::UNKNOWN_AGREEMENT
    else
      commons = []
      disagreements = []
      all_organelles = [organelles1,localisations_to_compare_to].flatten
      all_organelles.each do |o|
        if organelles1.include?(o) and localisations_to_compare_to.include?(o)
          commons.push o
        elsif !organelles1.include?(o) and !localisations_to_compare_to.include?(o)
          raise Exception, "Programming problem"
        else
          disagreements.push o
        end
      end
      
      c.common_ontologies = commons.uniq
      c.disagreeing_ontologies = disagreements.uniq
    end
    
    # Apply domain-specific information here
    # 1. If nucleus is common, and only 1 has cytoplasm, then that is complete agreement
    c.apply_nucleus_cytoplasm_modification
    
    return c.agreement #agreement is calculated on the fly
  end
  
  
  def compartments
    if species.apicomplexan?
      #return high level localisations mapped to the organelles that I'm interested in - shouldn't be too hard
      return gather_compartments_by_high_level_localisations
    else
      return gather_organelles_by_go_terms
    end
  end
  
  
  # An organelle is one of cytoplasm, nucleus, mitochondrion, ER, golgi, lysosome, vacuole, 
  def gather_organelles_by_go_terms
    mappers = create_organelle_go_term_mappers
    goes = coding_region_go_terms.cc.useful.all.reach.go_term
    organelles = []
    goes.each do |go|
      g = go.go_identifier
      subsume_count = 0
      mappers.each do |map|
        begin
          if map.subsume?(g)
            term = GoTerm.find_by_go_identifier(map.master_go_id).term
            organelles.push term
            $stderr.puts "#{term} subsumed #{go.term}"
            subsume_count += 1
          end
        rescue RException => e
          $stderr.puts "Unknown GO identifier #{g}. Potentially GO.db could be updated.."
        end
      end
      # advise of subsume counters
      if subsume_count == 0
        $stderr.puts "Didn't subsume #{go.go_identifier} #{go.term}"
      elsif subsume_count > 1
        $stderr.puts "Subsumed #{g} #{subsume_count} times. Not good"
      end
    end
    
    # Sometimes a multiple GO terms for a single gene will map to the same compartment.
    # Only count each compartment once for each gene.
    organelles.uniq!
    
    return organelles
  end
  
  class << self
    attr_accessor :compartment_go_term_subsumers
  end
  
  def create_organelle_go_term_mappers
    if CodingRegion.compartment_go_term_subsumers.nil?
      require 'go'
      mappers = OntologyComparison::RECOGNIZED_LOCATIONS.collect do |loc|
        go_entry = GoTerm.find_by_term(loc)
        raise Exception, "Unable to find GO term in database: #{loc}" unless go_entry
        Bio::Go.new.subsume_tester(go_entry.go_identifier)
      end
      CodingRegion.compartment_go_term_subsumers = mappers
    end
    
    CodingRegion.compartment_go_term_subsumers
  end
  
  def gather_compartments_by_high_level_localisations
    updates = {
    'exported' => 'host cell',
    'apical' => 'apical complex',
    'cytoplasm' => 'cytosol',
    'apicoplast' => 'plastid',
    'golgi apparatus' => 'Golgi apparatus',
    'food vacuole' => 'lysosome',
    'parasite plasma membrane' => 'plasma membrane'
    }
    
    highs = TopLevelLocalisation.positive.all(
    :joins => {:apiloc_localisations => :expression_contexts},
    :conditions => ['coding_region_id = ?', id]
    ).reach.name.uniq.reject {|n| n == 'other'}.collect do |top|
      if updates[top]
        updates[top]
      else
        top
      end
    end
    
    highs.each do |l|
      unless OntologyComparison::RECOGNIZED_LOCATIONS.include?(l)
        raise Exception, "ApiLoc high level localisation '#{l}' is not a recognized primary GO term name"
      end
    end
    highs
  end
  
  # Predict localisation for an apicomplexan protein by choosing the most common
  # localisation from IDA CC GO term annotated non-apicomplexan genomes
  def apicomplexan_localisation_prediction_by_most_common_localisation
    raise unless species.apicomplexan?
    return nil if single_orthomcl.official_group.nil? #ignore genes that do not have an OrthoMCL group
    
    localisation_counts = {}
    
    CodingRegion.all(
    :select => 'distinct(coding_regions.*)',
    :joins => [
    :go_terms,
    {:gene => {:scaffold => :species}},
    {:orthomcl_genes => :orthomcl_groups}
    ],
    :conditions => [
    'orthomcl_groups.id = ? and go_terms.aspect = ? and evidence_code = ? and species.name not in (?)',
    single_orthomcl.official_group.id, GoTerm::CELLULAR_COMPONENT, 'IDA', Species::APICOMPLEXAN_NAMES
    ] 
    ).each do |code|
      code.compartments.each do |l|
        localisation_counts[l] ||= 0
        localisation_counts[l] += 1
      end
    end
    
    return nil if localisation_counts.empty?
    
    localisation_counts.max {|a,b|
      if a.nil? or b.nil?
        $stderr.puts 'nil found in #{string_id}'
        0
      else
        a[1] <=> b[1]
      end
    }[0]
  end
end
