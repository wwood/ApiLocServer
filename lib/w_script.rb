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
    lc.groups_count = orthomcl_groups.length
    
    lethal_count = 0
    total = 0
    phenotype_count = 0
    missing_count = 0
    orthomcl_groups.each do |group|
      
      # for each cel gene in the group, count if it is lethal or not
      # We exclude genes don't correspond between othomcl and our IDs
      group.orthomcl_genes.code(species_orthomcl_code).all(:select => 'distinct(id)').each do |og|
        total += 1
        
        
        
        begin
          # returns true, false or nil
          lethal = og.single_code.lethal?
          if lethal
            phenotype_count += 1
            lethal_count += 1
          elsif lethal.nil?
          else
            phenotype_count += 1
          end
        rescue UnexpectedCodingRegionCount => e #if it doesn't match to a single coding region then count - other errors will filter through
          missing_count += 1
        end
      end
    end
    
    lc.lethal_count = lethal_count
    lc.phenotype_count = phenotype_count
    lc.total_count = total
    lc.missing_count = missing_count
    return lc
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
  
  
  def lethal_orthology
    overlaps = [
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
      puts compute_lethal_count(groups, arrays[1]).to_s
    end    
  end
  
  
  def mouse_test
    overlaps = [
      #      [['cel','sce'],['sce']]
      [['cel','mmu'],['mmu']]
    ]
    overlaps.each do |arrays|
      groups = OrthomclGroup.all_overlapping_groups(arrays[0])
      p arrays
      puts compute_lethal_count(groups, arrays[1]).to_s
    end    
  end

end


class LethalCount
  attr_accessor :lethal_count, :total_count, :phenotype_count, :groups_count, :missing_count
  
  def to_s
    "Genes found to be lethal: #{@lethal_count} of #{@total_count} genes (#{@phenotype_count} had recorded phenotypes) from #{@group_count} orthomcl groups. #{@missing_count} didn't have matching coding regions"
  end
end