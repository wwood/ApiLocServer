class BScript
  # Print out a list of all the P. falciparum proteins that are in the same
  # OrthoMCL group as another a IDA annotated nucleolus protein from any other 
  # species
  def nucleolar_proteome_prediction_by_fungi_orthology
    nucleolus_go_id = 'GO:0005730'
    
    # first find all the descendants of the nucleolus GO term in amigo
    go = Bio::Go.new
    descendents = go.go_offspring(nucleolus_go_id).uniq
    descendents.push nucleolus_go_id
    
    # find all coding regions that have the nucleolus term
    groups = OrthomclGroup.official.all(
    :select => 'distinct(orthomcl_groups.*)',
    :joins => {:orthomcl_genes => {:coding_regions => :go_terms}}, 
    :conditions => [
      "go_terms.go_identifier in #{descendents.to_sql_in_string} and coding_region_go_terms.evidence_code = ?",
      'IDA'
    ])
    
    groups.each do |group|
      puts
      puts "#{group.orthomcl_name}================="
      # find all the annotations from that group that have nucleolus annotations
      CodingRegion.all(
      :select => 'distinct(coding_regions.*)',
      :joins => {:orthomcl_genes => :orthomcl_groups},
      :conditions => {:orthomcl_groups => {:id => group.id}}).each do |code|
        go_terms = code.coding_region_go_terms.useful.cc.all.reach.go_term.retract.uniq
        next unless go_terms.length > 0
        
        nucleolus_terms = go_terms.select do |g|
          descendents.include? g.go_identifier
        end
        non_nucleolus_terms = go_terms.reject do |g|
          descendents.include? g.go_identifier
        end
        compartments = code.compartments
        
        puts [
          code.species.name,
          code.string_id,
          nucleolus_terms.length > 0 ? 'nucleolus' : 'non_nucleolus',
          compartments,
          non_nucleolus_terms.reach.term.join(", ")
        ].join("\t")
      end
      
      # Find all the associated P. falciparum genes
      puts
      group.orthomcl_genes.code('pfal').each do |g|
        code = g.single_code
        puts [
          code.string_id,
          code.annotation.annotation,
          code.compartments,
          code.localisation_english,
          code.expression_contexts.reach.publication.pubmed_id.join(",")
        ].join("\t")
      end
    end
  end
end