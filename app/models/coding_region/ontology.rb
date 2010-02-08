class CodingRegion < ActiveRecord::Base
  # compare this coding region to another, and record whether it
  # 1. agrees perfectly
  # 2. agrees but complex (one coding region has 2 organelles, the other has only 1 of these)
  # 3. disagree
  # 4. not known (no organellar annotation for one of them)
  def compare_organelle_ontology(coding_region2)
    require 'ontology_comparison'
    # gather each of the organelle ontologies for both coding regions
    organelles1 = organelles
    organelles2 = coding_region2.organelles
    
    # return unknown if there is nothing suitable
    c = OntologyComparison.new
    if organelles1.empty? or organelles2.empty?
      c.agreement = OntologyComparison::UNKNOWN_AGREEMENT
      
    else # we have something to compare here
      # compare the organelles, recording which ones are in common
      commons = []
      disagreements = []
      organelles1.each do |org1|
        if organelles2.include?(org1)
          commons.push org1
        else
          disagreements.push org1
        end
      end
      
      # if there is a common organelle between these, return 
      c = OntologyComparison.new
      if commons.empty?
        c.agreement = OntologyComparison::DISAGREEMENT
      elsif disagreements.empty?
        c.agreement = OntologyComparison::COMPLETE_AGREEMENT
        c.common_ontologies = commons
      else
        c.agreement = OntologyComparison::INCOMPLETE_AGREEMENT
        c.common_ontologies = commons
        c.disagreeing_ontologies = disagreements
      end
      
      
      # Apply specifics here
      # 1. If nucleus is common, and only 1 has cytoplasm, then that is complete agreement
      raise
      raise make sure of plastid stuff 
    end
    return c
  end
  
  
  def organelles
    if apicomplexan?
      #return high level localisations mapped to the organelles that I'm interested in - shouldn't be too hard
      return gather_organelles_by_high_level_localisations
    else
      return gather_organelles_by_go_terms
    end
  end
  
  
  # An organelle is one of cytoplasm, nucleus, mitochondrion, ER, golgi, lysosome, vacuole, 
  def gather_organelles_by_go_terms
    mappers = create_organelle_go_term_mappers
    goes = coding_region_go_terms.useful.all.reach.go_term.go_identifier
    organelles = []
    subsume_count = 0
    goes.each do |g|
      mappers.each do |map|
        if map.subsume?(g)
          organelles.push mappers.term
          subsume_count += 1
        end
      end
      # advise of subsume counters
      if subsume_count == 0
        $stderr.puts "Didn't subsume #{g}"
      elsif subsume_count > 1
        $stderr.puts "Subsumed #{g} twice. Not good"
      end
      
      
      return organelles
    end
  end
  
  def create_organelle_go_term_mappers
  end
  
  def gather_organelles_by_high_level_localisations
    raise
  end
  
end
