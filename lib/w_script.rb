# Methods associated with worm informatics written by Ben and Maria
class WScript
  # How many cel genes have dme orthologs, according to orthomcl?
  def q1a
    # collect all the groups
    groups = OrthomclGroup.all_overlapping_groups(['cel','dme'])
    
    # print the number of groups
    puts "Number of (Official v2) OrthoMCL groups have both dme and cel members: #{groups.length}"
    
    # print the number of genes individually
    # more annoying - have to count all the groups individually
    total = 0
    groups.each do |group|
      # code is a named_scope defined in OrthomclGene class
      total += group.orthomcl_genes.code('cel').count
    end
    puts "Number of cel members in these groups: #{total}"
  end
  
  
  def q1b
    # collect all the groups
    groups = OrthomclGroup.all_overlapping_groups(['cel','dme'])
    
    # print the number of genes individually
    # more annoying - have to count all the groups individually
    lc = compute_lethal_count(groups, 'cel')
    
    puts lc.to_s
  end
  
  
  def compute_lethal_count(orthomcl_groups, species_orthomcl_code)
    lc = LethalCount.new
    lc.groups_count += orthomcl_groups.length

    orthomcl_groups.each do |group|
      
      # for each cel gene in the group, count if it is lethal or not
      # We exclude genes don't correspond between othomcl and our IDs
      group.orthomcl_genes.code(species_orthomcl_code).all(:select => 'distinct(orthomcl_genes.id)').each do |og|
        add_orthomcl_gene_to_lethal_count(og, lc)
      end
    end
    return lc
  end
  
  def compute_lethal_count_using_essential_orthologues(orthomcl_groups, species_orthomcl_code)
    #this method doesn't work yet, just testing
    lc = LethalCount.new
    lc.groups_count += orthomcl_groups.length

    orthomcl_groups.each do |group|

      #identify the groups that have essential orthologues for the query species       
       
      # for each cel gene in the group, count if it is lethal or not
      # We exclude genes don't correspond between othomcl and our IDs
      group.orthomcl_genes.code(species_orthomcl_code).all(:select => 'distinct(orthomcl_genes.id)').each do |og|
        add_orthomcl_gene_to_lethal_count(og, lc)
      end
    end
    return lc
  end
  
  
  def add_orthomcl_gene_to_lethal_count(orthomcl_gene, lethal_count)
    begin
      # returns true, false or nil
      lethal = orthomcl_gene.single_code.lethal?
      
      lethal_count.total_count += 1
      
      if lethal
        lethal_count.phenotype_count += 1
        lethal_count.lethal_count += 1
        lethal_count.lethal_genes.push orthomcl_gene
      elsif lethal.nil?
      else
        lethal_count.phenotype_count += 1
      end
    rescue OrthomclGene::UnexpectedCodingRegionCount => e #if it doesn't match to a single coding region then count - other errors will filter through
      lethal_count.missing_count += 1
      $stderr.puts "Couldn't find coding region for orthomcl gene: #{OrthomclGene.find(orthomcl_gene.id).orthomcl_name}"
    end
    return lethal_count #for convenience
  end

  
  
  def lethal_gene_comparisons(orthomcl_groups, species_orthomcl_code)
    
    lethalgroups = nil
    lethalgroups = Array.new
     
    orthomcl_groups.each do |group|
      
      # select genes that are lethal
      # We exclude genes don't correspond between othomcl and our IDs
      group.orthomcl_genes.code(species_orthomcl_code).all(:select => 'distinct(id)').each do |og|
       
        begin
          #returns true, false or nil
          lethal = og.single_code.lethal? 
          if lethal 
            lethalgroups << group
          end
        rescue UnexpectedCodingRegionCount => e #if it doesn't match to a single coding region then count - other errors will filter through
          print e, "\n"
        end
      end
    end
    p lethalgroups.length
    p lethalgroups
    return lethalgroups
  end
  
  def lethal_gene_comparisons_multiple_spp(orthomcl_groups, species_orthomcl_codes)
        
    missing_count = 0
    lethal_groups = orthomcl_groups.select do |g|
      answer = true   
      # select groups where genes are lethal for all species
      species_orthomcl_codes.each do |species_code|
     
        #for each species reject group if genes aren't lethal
        g.orthomcl_genes.code(species_code).all(:select  => 'distinct(id)').each do |og|
          begin
            if !og.single_code.lethal?
              answer = false
            end
          rescue UnexpectedCodingRegionCount => e
            missing_count += 1
            answer = false #ignore?
          end
        end
      
      end
      answer                  
    end
       
    p lethal_groups.length
    puts "missing_count = #{missing_count}"
    return lethal_groups
  end

  def cel_lethal_and_other_species(orthomcl_groups, species_orthomcl_codes)
        
    #identify groups that a gene with a lethal phenotype in elegans and at least one other species 
    missing_count = 0 
    
    # select groups where elegans genes are lethal 
    elegans_lethal = orthomcl_groups.select do |g|
      answer = true   
     
      g.orthomcl_genes.code('cel').all(:select  => 'distinct(id)').each do |og|
        begin
          if !og.single_code.lethal?
            answer = false
          end
        rescue UnexpectedCodingRegionCount => e
          missing_count += 1
          answer = false #ignore?
        end
      end
    
      answer                  
    end
   
      
      
    # then for the other species i.e. not cel keep group if gene is lethal in any

    other_spp_lethal = elegans_lethal.select do |g|
      answer = true   
      species_orthomcl_codes.each do |species_code|      

        g.orthomcl_genes.code(species_code).all(:select  => 'distinct(id)').each do |og|
          begin
            if og.single_code.lethal?
              answer = true
            end
          rescue UnexpectedCodingRegionCount => e
            missing_count += 1
            answer = false #ignore?
          end
        end
      
      end
      answer                  
    end
       
    p other_spp_lethal.length
    puts "missing_count = #{missing_count}"
    return other_spp_lethal
  end
  
  def count_observations_for_elegans
    count = 0
    first = true

    filename = "/home/ben/phd/data/elegans/essentiality/cel_wormbase_pheno.tsv"
    require 'csv'
    CSV.open(filename,
      'r', "\t") do |row|
      if first
        first = false
        next
      end
      
      next if !row[4]
      count += row[4].split(' | ').length
    end
    p count
  end
  
  
  def mouse_vs_elegans
    groups = OrthomclGroup.all_overlapping_groups(['cel','mmu'])
    puts compute_lethal_count(groups, 'cel').to_s
  end
  
  
  def cel_vs_all
    overlaps = [
      ['cel','dme'],
      ['cel','mmu'],
      ['cel','sce'],
      ['cel','dme','mmu'],
      ['cel','mmu','sce'],
      ['cel','dme','sce'],
      ['cel','dme','mmu','sce']
    ]
    
    overlaps.each do |species|
      groups = OrthomclGroup.all_overlapping_groups(species)
      p species
      puts compute_lethal_count(groups, 'cel').to_s
    end
  end
  
  def all_genes_including_genes_not_in_orthomclgroups
    arrays = [
      ['cel'],  
      ['mmu'], 
      ['dme'],
      ['sce']
    ]
    
    arrays.each do |species|
      #made new LethalCount class for genes not in groups as the other LethalCount class prints out info for groups
      lc = LethalCount2.new
      lc.total_count = OrthomclGene.code(species).count
         
      lethal_count = 0
      phenotype_count = 0
      missing_count = 0
      OrthomclGene.code(species).each do |og|       
          
        begin
          lethal = og.single_code.lethal?
          if lethal
            phenotype_count += 1
            lethal_count += 1
          elsif lethal.nil?
          else
            phenotype_count += 1
          end
        rescue OrthomclGene::UnexpectedCodingRegionCount => e #if it doesn't match to a single coding region then count - other errors will filter through
          puts e
          missing_count += 1
        end
      end
    
      lc.lethal_count = lethal_count
      lc.phenotype_count = phenotype_count
      lc.missing_count = missing_count
      puts lc.to_s
    end
  end
  
  def elegans_all_genes_including_genes_not_in_orthomclgroups_excluding_mammalian
    
    overlaps = [
      [['cel'],['cel']]  
    ]
    overlaps.each do |arrays|
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      puts "Found #{groups.length} orthomcl groups with at least one #{arrays[0]} gene in them"
        
      #find groups without mammalian orthologues
      groups.reject! do |g|
        g.orthomcl_genes.codes(OrthomclGene::MAMMALIAN_THREE_LETTER_CODES).count > 0
      end
      
      #count the lethal ones
      lethal_count = compute_lethal_count(groups, arrays[1])
      puts "LethalCount of genes with an orthomcl group: #{lethal_count}"
      OrthomclGene.code(arrays[1]).no_group.all.each do |orthomcl_gene|
        add_orthomcl_gene_to_lethal_count(orthomcl_gene, lethal_count)
      end
      puts "LethalCount of genes with and without an orthomcl group: #{lethal_count}"
    end    
  end 
   
   
  
  
  def lethal_orthology
    overlaps = [
      [['cel'],['cel']],
      [['cel','mmu'],['cel']],
      [['cel','sce'],['cel']],
      [['cel','dme','mmu'],['cel']],
      [['cel','mmu','sce'],['cel']],
      [['cel','dme','sce'],['cel']],
      [['cel','dme','mmu','sce'],['cel']],
      [['dme'],['dme']],
      [['dme','cel'],['dme']],
      [['dme','mmu'],['dme']],
      [['dme','sce'],['dme']],
      [['dme','mmu','sce'],['dme']],
      [['dme','sce','cel'],['dme']],
      [['dme','mmu','cel'],['dme']],
      [['dme','mmu','sce','cel'],['dme']],
      [['mmu'],['mmu']],
      [['mmu','cel'],['mmu']],
      [['mmu','dme'],['mmu']],
      [['mmu','sce'],['mmu']],
      [['mmu','dme','sce'],['mmu']],
      [['mmu','sce','cel'],['mmu']],
      [['mmu','dme','cel'],['mmu']],
      [['mmu','dme','sce','cel'],['mmu']],
      [['sce'],['sce']],
      [['sce','cel'],['sce']],
      [['sce','dme'],['sce']],
      [['sce','mmu'],['sce']],
      [['sce','dme','mmu'],['sce']],
      [['sce','mmu','cel'],['sce']],
      [['sce','dme','cel'],['sce']],
      [['sce','dme','mmu','cel'],['sce']]
    ]
    overlaps.each do |arrays|
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      puts compute_lethal_count(groups, arrays[1]).to_s
    end    
  end
  
  def yeast_only_lethal_orthology
    overlaps = [
      [['sce'],['sce']],
      [['sce','cel'],['sce']],
      [['sce','dme'],['sce']],
      [['sce','mmu'],['sce']],
      [['sce','dme','mmu'],['sce']],
      [['sce','mmu','cel'],['sce']],
      [['sce','dme','cel'],['sce']],
      [['sce','dme','mmu','cel'],['sce']]
    ]
    overlaps.each do |arrays|
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      puts compute_lethal_count(groups, arrays[1]).to_s
    end    
  end
  
  
  def lethal_orthology_no_human
    overlaps = [
      [['cel','bma'],['cel']],
      #[['cel'],['cel']],
      [['cel','dme'],['cel']],      
      [['cel','mmu'],['cel']],
      [['cel','sce'],['cel']],
      [['cel','dme','mmu'],['cel']],
      [['cel','mmu','sce'],['cel']],
      [['cel','dme','sce'],['cel']],
      [['cel','dme','mmu','sce'],['cel']],
      [['dme'],['dme']],
      [['dme','cel'],['dme']],
      [['dme','mmu'],['dme']],
      [['dme','sce'],['dme']],
      [['dme','mmu','sce'],['dme']],
      [['dme','sce','cel'],['dme']],
      [['dme','mmu','cel'],['dme']],
      [['dme','mmu','sce','cel'],['dme']],
      [['mmu'],['mmu']],
      [['mmu','cel'],['mmu']],
      [['mmu','dme'],['mmu']],
      [['mmu','sce'],['mmu']],
      [['mmu','dme','sce'],['mmu']],
      [['mmu','sce','cel'],['mmu']],
      [['mmu','dme','cel'],['mmu']],
      [['mmu','dme','sce','cel'],['mmu']],
      [['sce'],['sce']],
      [['sce','cel'],['sce']],
      [['sce','dme'],['sce']],
      [['sce','mmu'],['sce']],
      [['sce','dme','mmu'],['sce']],
      [['sce','mmu','cel'],['sce']],
      [['sce','dme','cel'],['sce']],
      [['sce','dme','mmu','cel'],['sce']]
    ]
    overlaps.each do |arrays|
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      
      #next reject groups with human orthologs
      groups.reject! do |n|
        n.orthomcl_genes.code('hsa').count > 0
      end  
       
      puts compute_lethal_count(groups, arrays[1]).to_s
    end    
  end
  
  
  
  def lethal_orthology_nematode
    overlaps = [
      [['cel'],['cel']],
      [['cel','cbr','bma'],['cel']],
      [['cel','cbr'],['cel']],
      [['cel','bma'],['cel']],
    ]
    overlaps.each do |arrays|
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      puts compute_lethal_count(groups, arrays[1]).to_s
    end    
  end
  
    
  def lethal_no_paralogues
    
    overlaps = [
      [['cel'],['cel']],
      [['mmu'],['mmu']],
      [['dme'],['dme']],
      [['sce'],['sce']]   
    ]
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      puts "Found #{groups.length} orthomcl groups with at least one #{arrays[0]} gene in them"
      groups.each do |g|
        #get all genes without paralogues
        if g.orthomcl_genes.code(arrays[1]).official.count ==1
          nopara << g
        end
      end
      #count the lethal ones
      lethal_count = compute_lethal_count(nopara, arrays[1])
      puts "LethalCount of genes with an orthomcl group: #{lethal_count}"
      OrthomclGene.code(arrays[1]).no_group.all.each do |orthomcl_gene|
        add_orthomcl_gene_to_lethal_count(orthomcl_gene, lethal_count)
      end
      puts "LethalCount of genes with and without an orthomcl group: #{lethal_count}"
    end    
  end
    
  def lethal_no_paralogues_excluding_mammalian
    
    overlaps = [
      [['cel'],['cel']],
      [['mmu'],['mmu']],
      [['dme'],['dme']],
      [['sce'],['sce']]   
    ]
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      puts "Found #{groups.length} orthomcl groups with at least one #{arrays[0]} gene in them"
      groups.each do |g|
        #get all genes without paralogues
        if g.orthomcl_genes.code(arrays[1]).official.count ==1
          nopara << g
        end
      end
      
      #find groups without mammalian orthologues
      nopara.reject! do |g|
        g.orthomcl_genes.codes(OrthomclGene::MAMMALIAN_THREE_LETTER_CODES).count > 0
      end
      
      #count the lethal ones
      lethal_count = compute_lethal_count(nopara, arrays[1])
      puts "LethalCount of genes with an orthomcl group: #{lethal_count}"
      OrthomclGene.code(arrays[1]).no_group.all.each do |orthomcl_gene|
        add_orthomcl_gene_to_lethal_count(orthomcl_gene, lethal_count)
      end
      puts "LethalCount of genes with and without an orthomcl group: #{lethal_count}"
    end    
  end
 
  
  def lethal_no_paralogues_multiple_spp
    
    overlaps = [
    
      [['cel'],['cel']],
      [['cel','mmu'],['cel']], 
      [['cel','dme'], ['cel']],
      [['cel','sce'],['cel']],
      [['cel','dme','mmu'],['cel']],
      [['cel','mmu','sce'],['cel']],
      [['cel','dme','sce'],['cel']],
      [['cel','dme','mmu','sce'],['cel']],
      [['dme'],['dme']],
      [['dme','cel'],['dme']],
      [['dme','mmu'],['dme']],
      [['dme','sce'],['dme']],
      [['dme','mmu','sce'],['dme']],
      [['dme','sce','cel'],['dme']],
      [['dme','mmu','cel'],['dme']],
      [['dme','mmu','sce','cel'],['dme']],
      [['mmu'],['mmu']],
      [['mmu','cel'],['mmu']],
      [['mmu','dme'],['mmu']],
      [['mmu','sce'],['mmu']],
      [['mmu','dme','sce'],['mmu']],
      [['mmu','sce','cel'],['mmu']],
      [['mmu','dme','cel'],['mmu']],
      [['mmu','dme','sce','cel'],['mmu']],
      [['sce'],['sce']],
      [['sce','cel'],['sce']],
      [['sce','dme'],['sce']],
      [['sce','mmu'],['sce']],
      [['sce','dme','mmu'],['sce']],
      [['sce','mmu','cel'],['sce']],
      [['sce','dme','cel'],['sce']],
      [['sce','dme','mmu','cel'],['sce']]      
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      #count the lethal genes in these groups
      puts compute_lethal_count(nopara, arrays[1]).to_s
    end    
  end
  
  def lethal_no_paralogues_multiple_spp_mouse_only
    
    overlaps = [
      [['mmu'],['mmu']],
      [['mmu','cel'],['mmu']],
      [['mmu','dme'],['mmu']],
      [['mmu','sce'],['mmu']],
      [['mmu','dme','sce'],['mmu']],
      [['mmu','sce','cel'],['mmu']],
      [['mmu','dme','cel'],['mmu']],
      [['mmu','dme','sce','cel'],['mmu']]    
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      #count the lethal genes in these groups
      puts compute_lethal_count(nopara, arrays[1]).to_s
    end    
  end
  
  
  
  
  def lethal_no_paralogues_in_test_species_only
    
    # want to calculate probabilities of lethality for genes that have no paralogues in the species we're predicting lethal in but there can be paralogues in the species we're comparing 
    #e.g. for elegans we want to calculate the probaility of lethality for all elegans genes with no paralgoues but we don't care if the species we identifying orthoolgues in e.g. mouse has paralogues
    overlaps = [
    
      [['cel'],['cel']],
      [['cel','mmu'],['cel']], 
      [['cel','dme'], ['cel']],
      [['cel','sce'],['cel']],
      [['cel','dme','mmu'],['cel']],
      [['cel','mmu','sce'],['cel']],
      [['cel','dme','sce'],['cel']],
      [['cel','dme','mmu','sce'],['cel']],
      [['dme'],['dme']],
      [['dme','cel'],['dme']],
      [['dme','mmu'],['dme']],
      [['dme','sce'],['dme']],
      [['dme','mmu','sce'],['dme']],
      [['dme','sce','cel'],['dme']],
      [['dme','mmu','cel'],['dme']],
      [['dme','mmu','sce','cel'],['dme']],
      [['mmu'],['mmu']],
      [['mmu','cel'],['mmu']],
      [['mmu','dme'],['mmu']],
      [['mmu','sce'],['mmu']],
      [['mmu','dme','sce'],['mmu']],
      [['mmu','sce','cel'],['mmu']],
      [['mmu','dme','cel'],['mmu']],
      [['mmu','dme','sce','cel'],['mmu']],
      [['sce'],['sce']],
      [['sce','cel'],['sce']],
      [['sce','dme'],['sce']],
      [['sce','mmu'],['sce']],
      [['sce','dme','mmu'],['sce']],
      [['sce','mmu','cel'],['sce']],
      [['sce','dme','cel'],['sce']],
      [['sce','dme','mmu','cel'],['sce']]      
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there no paralogues for the species we're predicting lethality in
      groups.reject! do |g|
        g.orthomcl_genes.code(arrays[1]).count > 1
      end      

      #count the lethal genes in these groups
      puts compute_lethal_count(groups, arrays[1]).to_s
    end    
  end
  
  def brugia_no_paralogues_no_human
    
    # want to calculate probabilities of lethality for genes that have no paralogues in the species we're predicting lethal in but there can be paralogues in the species we're comparing 
    #e.g. for elegans we want to calculate the probaility of lethality for all elegans genes with no paralgoues but we don't care if the species we identifying orthoolgues in e.g. mouse has paralogues
    overlaps = [
    
      [['cel','bma'],['bma'],['cel']]
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there no paralogues in brugia
      groups.reject! do |g|
        g.orthomcl_genes.code(arrays[1]).count > 1
      end      

      #reject groups if they contain a human orthologue
      groups.reject! do |n|
        n.orthomcl_genes.code('hsa').count > 0
      end
       
      #count the lethal genes in these groups
      puts compute_lethal_count(groups, arrays[2]).to_s
    end    
  end
  
  
  def lethal_no_paralogues_multiple_spp_no_human
    
    overlaps = [
      [['cel','bma'], ['cel']],     
      [['cel'],['cel']],
      [['cel','mmu'],['cel']], 
      [['cel','dme'], ['cel']],
      [['cel','sce'],['cel']],
      [['cel','dme','mmu'],['cel']],
      [['cel','mmu','sce'],['cel']],
      [['cel','dme','sce'],['cel']],
      [['cel','dme','mmu','sce'],['cel']],
      [['dme'],['dme']],
      [['dme','cel'],['dme']],
      [['dme','mmu'],['dme']],
      [['dme','sce'],['dme']],
      [['dme','mmu','sce'],['dme']],
      [['dme','sce','cel'],['dme']],
      [['dme','mmu','cel'],['dme']],
      [['dme','mmu','sce','cel'],['dme']],
      [['mmu'],['mmu']],
      [['mmu','cel'],['mmu']],
      [['mmu','dme'],['mmu']],
      [['mmu','sce'],['mmu']],
      [['mmu','dme','sce'],['mmu']],
      [['mmu','sce','cel'],['mmu']],
      [['mmu','dme','cel'],['mmu']],
      [['mmu','dme','sce','cel'],['mmu']],
      [['sce'],['sce']],
      [['sce','cel'],['sce']],
      [['sce','dme'],['sce']],
      [['sce','mmu'],['sce']],
      [['sce','dme','mmu'],['sce']],
      [['sce','mmu','cel'],['sce']],
      [['sce','dme','cel'],['sce']],
      [['sce','dme','mmu','cel'],['sce']]      
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      
      #next reject groups with human orthologs
      nopara.reject! do |n|
        n.orthomcl_genes.code('hsa').count > 0
      end
      
      #count the lethal genes in these groups
      puts compute_lethal_count(nopara, arrays[1]).to_s
    end    
  end
  
  def lethal_no_paralogues_multiple_spp_excluding_one_species
    
    overlaps = [     
      #[['cel'],['cel'], ['hsa']], 
      #[['cel'],['cel'], ['mmu']],
      #[['cel'],['cel'], ['dme']], 
      #[['cel'],['cel'], ['sce']],
      #[['mmu'],['mmu'], ['hsa']],
      #[['mmu'],['mmu'], ['cel']], 
      #[['mmu'],['mmu'], ['dme']],
      #[['mmu'],['mmu'], ['sce']],
      #[['dme'],['dme'], ['hsa']],
      #[['dme'],['dme'], ['mmu']],
      #[['dme'],['dme'], ['cel']],
      #[['dme'],['dme'], ['sce']],
      #[['sce'],['sce'], ['hsa']],
      #[['sce'],['sce'], ['cel']],
      #[['sce'],['sce'], ['mmu']],
      #[['sce'],['sce'], ['dme']],
      # including brugia orthologues
      # [['cel','bma'],['cel'], ['hsa']], 
      #[['cel','bma'],['cel'], ['mmu']],
      #[['cel','bma'],['cel'], ['dme']], 
      # [['cel','bma'],['cel'], ['sce']]    
      #[['mmu','bma'],['mmu'], ['hsa']],
      #[['mmu','bma'],['mmu'], ['cel']], 
      #[['mmu','bma'],['mmu'], ['dme']],
      #[['mmu','bma'],['mmu'], ['sce']],
      #[['dme','bma'],['dme'], ['hsa']],
      #[['dme','bma'],['dme'], ['mmu']],
      #[['dme','bma'],['dme'], ['cel']],
      #[['dme','bma'],['dme'], ['sce']],
      #[['sce','bma'],['sce'], ['hsa']],
      #[['sce','bma'],['sce'], ['cel']],
      #[['sce','bma'],['sce'], ['mmu']],
      #[['sce','bma'],['sce'], ['dme']],  
      [['cel','bma'],['cel']],
      [['mmu','bma'],['mmu']],
      [['dme','bma'],['dme']],
      [['sce','bma'],['sce']]     
        
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      
      #next reject groups with human orthologs
      if arrays[2]
        nopara.reject! do |n|
          n.orthomcl_genes.code(arrays[2]).count > 0
        end
      end
      
      #count the lethal genes in these groups
      puts compute_lethal_count(nopara, arrays[1]).to_s
    end    
  end
  
  
  
  def brugia_genes_lethal_cel_no_paralogues_no_human
    
    #method to get the ids for the brugia gene that have a lethal elegans orthologoue with no paralogues in either spp and no human orthologues 
    
    overlaps = [
      [['cel','bma'], ['cel']]
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      
      #reject groups with human orthologs
      nopara.reject! do |n|
        n.orthomcl_genes.code('hsa').count > 0
      end
      
      #get groups that have lethal genes for query species i.e. species in arrays[1]
      lethalgroups = lethal_gene_comparisons_multiple_spp(nopara, arrays[1])
     
      #for each group print the brugia gene     
      lethalgroups.each do |lg|
        lg.orthomcl_genes.code('bma').all(:select  => 'distinct(orthomcl_name)').each do |og|
          puts og.orthomcl_name
        end
      end
    end    
     
  end   
  
  def lethal_cel_no_human
    
    #method to get the ids for the cel genes with lethal phenotypes with no human orthologues 
    
    overlaps = [
      [['cel'], ['cel']]
    ]
           
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      
      #reject groups with human orthologs
      groups.reject! do |g|
        g.orthomcl_genes.code('hsa').count > 0
      end
        
      #for each group if elegans gene has lethal phenotype print id   
      groups.each do |lg|         
        lg.orthomcl_genes.code('cel').all(:select  => 'distinct(id)').each do |og|
          begin
            if og.single_code.lethal?
              name = OrthomclGene.find(og)
              puts name.orthomcl_name
            end
          rescue UnexpectedCodingRegionCount => e
          end
        end            
      end
    end    
     
  end   
  
  
  def lethal_no_paralogues_get_genes
    
    overlaps = [
      [['cel','dme'],['cel']]      
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      #get groups that have lethal genes for query species i.e. species in arrays[0][1]
      lethalgroups = lethal_gene_comparisons(nopara, arrays[0][1])
      puts compute_lethal_count(lethalgroups, arrays[1]).to_s
    end    
  end
  

  def lethal_no_paralogues_get_genes_multiple_spp
    
    overlaps = [
      [['cel','mmu'],['mmu'],['cel']], 
      [['cel','dme'],['dme'],['cel']],
      [['cel','sce'],['sce'],['cel']],
      [['cel','dme','mmu'],['dme','mmu'],['cel']],
      [['cel','mmu','sce'],['mmu','sce'],['cel']],
      [['cel','dme','sce'],['dme','sce'],['cel']],
      [['cel','dme','mmu','sce'],['dme','mmu','sce'],['cel']],
      [['dme','cel'],['cel'],['dme']],
      [['dme','mmu'],['mmu'],['dme']],
      [['dme','sce'],['sce'],['dme']],
      [['dme','mmu','sce'],['mmu','sce'],['dme']],
      [['dme','sce','cel'],['sce','cel'],['dme']],
      [['dme','mmu','cel'],['mmu','cel'],['dme']],
      [['dme','mmu','sce','cel'],['mmu','sce','cel'],['dme']],
      [['mmu','cel'],['cel'],['mmu']],
      [['mmu','dme'],['dme'],['mmu']],
      [['mmu','sce'],['sce'],['mmu']],
      [['mmu','dme','sce'],['dme','sce'],['mmu']],
      [['mmu','sce','cel'],['sce','cel'],['mmu']],
      [['mmu','dme','cel'],['dme','cel'],['mmu']],
      [['mmu','dme','sce','cel'],['dme','sce','cel'],['mmu']],
      [['sce','cel'],['cel'],['sce']],
      [['sce','dme'],['dme'],['sce']],
      [['sce','mmu'],['mmu'],['sce']],
      [['sce','dme','mmu'],['dme','mmu'],['sce']],
      [['sce','mmu','cel'],['mmu','cel'],['sce']],
      [['sce','dme','cel'],['dme','cel'],['sce']],
      [['sce','dme','mmu','cel'],['dme','mmu','cel'],['sce']]          
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      #get groups that have lethal genes for query species i.e. species in arrays[1]
      lethalgroups = lethal_gene_comparisons_multiple_spp(nopara, arrays[1])
      puts compute_lethal_count(lethalgroups, arrays[2]).to_s
    end    
  end
  
  
  def lethal_in_at_least_one_spp_no_paralogues_no_human
    
    overlaps = [
      [['cel','mmu'],['mmu'],['cel']], 
      [['cel','dme'],['dme'],['cel']],
      [['cel','sce'],['sce'],['cel']],
      [['cel','dme','mmu'],['dme','mmu'],['cel']],
      [['cel','mmu','sce'],['mmu','sce'],['cel']],
      [['cel','dme','sce'],['dme','sce'],['cel']],
      [['cel','dme','mmu','sce'],['dme','mmu','sce'],['cel']],
      [['dme','cel'],['cel'],['dme']],
      [['dme','mmu'],['mmu'],['dme']],
      [['dme','sce'],['sce'],['dme']],
      [['dme','mmu','sce'],['mmu','sce'],['dme']],
      [['dme','sce','cel'],['sce','cel'],['dme']],
      [['dme','mmu','cel'],['mmu','cel'],['dme']],
      [['dme','mmu','sce','cel'],['mmu','sce','cel'],['dme']],
      [['mmu','cel'],['cel'],['mmu']],
      [['mmu','dme'],['dme'],['mmu']],
      [['mmu','sce'],['sce'],['mmu']],
      [['mmu','dme','sce'],['dme','sce'],['mmu']],
      [['mmu','sce','cel'],['sce','cel'],['mmu']],
      [['mmu','dme','cel'],['dme','cel'],['mmu']],
      [['mmu','dme','sce','cel'],['dme','sce','cel'],['mmu']],
      [['sce','cel'],['cel'],['sce']],
      [['sce','dme'],['dme'],['sce']],
      [['sce','mmu'],['mmu'],['sce']],
      [['sce','dme','mmu'],['dme','mmu'],['sce']],
      [['sce','mmu','cel'],['mmu','cel'],['sce']],
      [['sce','dme','cel'],['dme','cel'],['sce']],
      [['sce','dme','mmu','cel'],['dme','mmu','cel'],['sce']]       
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      
      #next reject groups with human orthologs
      nopara.reject! do |n|
        n.orthomcl_genes.code('hsa').count > 0
      end
      
      #get groups that have lethal genes for query species i.e. species in arrays[1]
      lethalgroups = lethal_gene_comparisons_multiple_spp(nopara, arrays[1])
      puts compute_lethal_count(lethalgroups, arrays[2]).to_s
    end    
  end

  def predict_essentiality_brugia_test
    
    overlaps = [
      #[['bma','cel'],['cel']],
      [['bma','cel','mmu'],['cel','mmu']],
      #[['bma','cel','sce'],['cel','sce']],
      [['bma','cel','dme'],['cel','dme']]    
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      
      #next reject groups with human orthologs
      nopara.reject! do |n|
        n.orthomcl_genes.code('hsa').count > 0
      end
      
      #get groups that have lethal genes for query species i.e. species in arrays[1]
      lethalgroups = lethal_gene_comparisons_multiple_spp(nopara, arrays[1])
      #for each group print the brugia gene
      arrays[0].each do |species_code|
        lethalgroups.each do |lg|
          lg.orthomcl_genes.code(species_code).all(:select  => 'distinct(orthomcl_name)').each do |og|
            puts og.orthomcl_name
          end
        end
      end    
    end
  end
  
  def brugia_lethal_elegans_and_one_other_spp_no_human
    
    overlaps = [
      [['bma','cel','mmu','dme'],['mmu','dme']],
      [['bma','cel','mmu','sce'],['mmu','sce']],
      [['bma','cel','dme','sce'],['dme','sce']]    
    ]
    nopara = nil
       
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      
      #next reject groups with human orthologs
      nopara.reject! do |n|
        n.orthomcl_genes.code('hsa').count > 0
      end
      
      #get groups that have lethal genes for query species i.e. species in arrays[1]
      lethalgroups = cel_lethal_and_other_species(nopara, arrays[1])
    end    
  end
   
  def improving_essentiality_after_excluding_human_orthologues
   
    overlaps = [  
      #[['cel'],['cel']],
      #[['cel','sce'],['cel']],  
      #[['cel','mmu'],['cel']],  
      #[['cel','dme'],['cel']],
      #[['cel','bma'], ['cel']],
      #[['cel','bma','cbr'], ['cel']],        
      [['sce'],['sce']],
      [['sce','cel'],['sce']], 
      [['sce','mmu'],['sce']],
      [['sce','dme'],['sce']],
      [['dme'],['dme']],
      [['dme','cel'],['dme']],
      [['dme','mmu'],['dme']],
      [['dme','sce'],['dme']],
      [['mmu'],['mmu']],
      [['mmu','cel'],['mmu']], 
      [['mmu','dme'],['mmu']], 
      [['mmu','sce'],['mmu']]
        
    ]
  
    #find the groups with genes from all species
    overlaps.each do |arrays|
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      
      puts compute_lethal_count(groups, arrays[1]).to_s
      
      #find groups without human orthologues
      puts 'Excluding human:'
      groups.reject! do |g|
        g.orthomcl_genes.code('hsa').count > 0
      end
    
      puts compute_lethal_count(groups, arrays[1]).to_s
  
    
    
      #find groups without human orthologues AND without paralogues in species that we're predicting essentiality in 
    
      puts "Without paralogues in #{arrays[1]} and excluding human:"
      groups.reject! do |g|
        g.orthomcl_genes.code(arrays[1]).count > 1
      end
        
      puts compute_lethal_count(groups, arrays[1]).to_s
 
    
      #find groups without human orthologues AND without paralogues in all species
      puts 'Without paralogues in all species and excluding human:'
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end 
    
      puts compute_lethal_count(groups, arrays[1]).to_s  
    
    end
    
  end
  
  def get_cel_genes_ids
    # get the ids for cel genes lethal in another species AND in cel
      
    overlaps = [
      # [['cel','sce'],['cel']] 
      [['cel','dme'],['cel']]
     
    ]
    nopara = nil
    #find the groups with genes from all species
  
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      
      #next reject groups with human orthologs
      nopara.reject! do |n|
        n.orthomcl_genes.code('hsa').count > 0
      end
      
      #get groups that have lethal genes for query species 
      lethalgroups = lethal_gene_comparisons_multiple_spp(nopara, arrays[0])
      #for each group print the cel gene id
      lethalgroups.each do |lg|
        lg.orthomcl_genes.code(arrays[1]).all(:select  => 'distinct(orthomcl_name)').each do |og|
          puts og.orthomcl_name
        end
      end    
    end
  end

  def get_cel_genes_ids2
    # get the ids for cel genes lethal in another species 
   
    overlaps = [
      [['cel','sce'],['sce'],['cel']],
      #[['cel','dme'],['dme'],['cel']]
    ]
    nopara = nil
    #find the groups with genes from all species
  
    overlaps.each do |arrays|
      nopara = Array.new
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
       
      #only keep groups where there are 1 to 1 orthologues i.e no paralogues for the selected species
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end      
 
      nopara = groups
      
      #next reject groups with human orthologs
      nopara.reject! do |n|
        n.orthomcl_genes.code('hsa').count > 0
      end
      
      #get groups that have lethal genes for query species 
      lethalgroups = lethal_gene_comparisons_multiple_spp(nopara, arrays[1])
      #for each group print the cel gene id
      lethalgroups.each do |lg|
        lg.orthomcl_genes.code(arrays[2]).all(:select  => 'distinct(orthomcl_name)').each do |og|
          puts og.orthomcl_name
        end
      end    
    end
  end
  

  def comparisons_of_presence_and_essentiality_of_orthologues_for_model_organisms
   
    overlaps = [  
      [['cel','dme'],['dme'],['cel']],       
      [['cel','mmu'],['mmu'],['cel']],  
      [['cel','sce'],['sce'],['cel']],   
      [['cel','dme','mmu'],['dme','mmu'],['cel']],
      [['cel','dme','sce'],['dme','sce'],['cel']], 
      [['cel','mmu','sce'],['mmu','sce'],['cel']],
      [['cel','dme','mmu','sce'],['dme','mmu','sce'],['cel']],
      [['dme','cel'],['cel'],['dme']],
      [['dme','mmu'],['mmu'],['dme']],
      [['dme','sce'],['sce'],['dme']],
      [['dme','mmu','sce'],['mmu','sce'],['dme']],
      [['dme','sce','cel'],['sce','cel'],['dme']],
      [['dme','mmu','cel'],['mmu','cel'],['dme']],
      [['dme','mmu','sce','cel'],['mmu','sce','cel'],['dme']],
      [['mmu','cel'],['cel'],['mmu']],
      [['mmu','dme'],['dme'],['mmu']],
      [['mmu','sce'],['sce'],['mmu']],
      [['mmu','dme','sce'],['dme','sce'],['mmu']],
      [['mmu','sce','cel'],['sce','cel'],['mmu']],
      [['mmu','dme','cel'],['dme','cel'],['mmu']],
      [['mmu','dme','sce','cel'],['dme','sce','cel'],['mmu']],
      [['sce','cel'],['cel'],['sce']],
      [['sce','dme'],['dme'],['sce']],
      [['sce','mmu'],['mmu'],['sce']],
      [['sce','dme','mmu'],['dme','mmu'],['sce']],
      [['sce','mmu','cel'],['mmu','cel'],['sce']],
      [['sce','dme','cel'],['dme','cel'],['sce']],
      [['sce','dme','mmu','cel'],['dme','mmu','cel'],['sce']]             
    ]
  
    #find the groups with genes from all species
    overlaps.each do |arrays|
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      
           
      #find groups with no paralogues in all species
      puts 'Effect of presence of orthologue (no paralogues in all species):'
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end
      puts compute_lethal_count(groups, arrays[2]).to_s 

      #test whether ESSENTIAL orthologue predicts essentiality - get groups that have lethal genes for query species i.e. species in arrays[1]
      puts 'Effect of presence of ESSENTIAL orthologue (no paralogues in all species):'

      # narrow down the genes to those that are lethal in the species arrays[1]
      arrays[1].each do |species_code|
        groups.reject! {|group|
          lethal = false
          ogeez = group.orthomcl_genes.codes(species_code)
          raise Exception, "Violated assumption" if ogeez.length != 1
          ogeez.each do |orthomcl_gene|
            begin
              lethal = true if orthomcl_gene.single_code.lethal?
            rescue OrthomclGene::UnexpectedCodingRegionCount => e #if it doesn't match to a single coding region then count - other errors will filter through
              $stderr.puts "Couldn't find coding region for orthomcl gene: #{OrthomclGene.find(orthomcl_gene.id).orthomcl_name}"
            end
          end
          !lethal
         
        }
      end
      puts compute_lethal_count(groups, arrays[2])
    end
    
  end
  
  
  def elegans_essentiality_after_excluding_mammalian
   
    overlaps = [ 
      [['cel'],['cel'],['cel']], 
      [['cel','sce'],['sce'],['cel']],  
      [['cel','dme'],['dme'],['cel']],      
      [['cel','dme','sce'],['sce','dme'],['cel']]  
    ]
  
    #find the groups with genes from all species
    overlaps.each do |arrays|
      p arrays
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      
      #find groups without mammalian orthologues
      groups.reject! do |g|
        g.orthomcl_genes.codes(OrthomclGene::MAMMALIAN_THREE_LETTER_CODES).count > 0
      end
           
      #find groups without mammalian orthologues AND without paralogues in all species
      puts 'Excluding mammalian and without paralogues in all species:'
      arrays[0].each do |species_code|
        groups.reject! do |g|
          g.orthomcl_genes.code(species_code).count > 1
        end
      end
      puts compute_lethal_count(groups, arrays[2]).to_s 

      #test whether ESSENTIAL orthologue predicts essentiality - get groups that have lethal genes for query species i.e. species in arrays[1]
      puts 'Excluding mammalian, with essential orthologue and without paralogues in all species:'

      # narrow down the genes to those that are lethal in the species arrays[1]
      arrays[1].each do |species_code|
        groups.reject! {|group|
          lethal = false
          ogeez = group.orthomcl_genes.codes(species_code)
          raise Exception, "Violated assumption" if ogeez.length != 1
          ogeez.each do |orthomcl_gene|
            begin
              lethal = true if orthomcl_gene.single_code.lethal?
            rescue OrthomclGene::UnexpectedCodingRegionCount => e #if it doesn't match to a single coding region then count - other errors will filter through
              $stderr.puts "Couldn't find coding region for orthomcl gene: #{OrthomclGene.find(orthomcl_gene.id).orthomcl_name}"
            end
          end
          !lethal
         
        }
      end
      puts compute_lethal_count(groups, arrays[2])
    end
    
  end

  
  
  
end

class LethalCount
  attr_accessor :lethal_count, :total_count, :phenotype_count, :groups_count, :missing_count, :lethal_genes
  
  def initialize
    @lethal_count = 0
    @total_count = 0
    @phenotype_count = 0
    @groups_count = 0
    @missing_count = 0
    @lethal_genes = []
  end
  
  def to_s
    "Genes found to be lethal: #{@lethal_count} of #{@total_count} genes (#{@phenotype_count} had recorded phenotypes) from #{@group_count} orthomcl groups. #{@missing_count} didn't have matching coding regions"
  end
end

class LethalCount2
  attr_accessor :lethal_count, :total_count, :phenotype_count, :missing_count
  
  def to_s
    "Genes found to be lethal: #{@lethal_count} of #{@total_count} genes (#{@phenotype_count} had recorded phenotypes). #{@missing_count} didn't have matching coding regions"
  end
end
