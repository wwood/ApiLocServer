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
      #      if group.id == 57981
      # code is a named_scope defined in OrthomclGene class
      total += group.orthomcl_genes.code('cel').count
      #      end
    end
    puts "Number of cel members in these groups: #{total}"
  end
  
  
  def q1b
    # collect all the groups
    groups = OrthomclGroup.all_overlapping_groups(['cel','dme'])
    
    # print the number of genes individually
    # more annoying - have to count all the groups individually
    lethal_count = 0
    total = 0
    groups.each do |group|
      # for each cel gene in the group, count if it is lethal or not
      # We exclude genes don't correspond between othomcl and our IDs
      group.orthomcl_genes.code('cel').all(:include => {:coding_regions => :phenotype_observeds}).each do |og|
        total += 1
        
        begin
          lethal = false
          
          og.single_code.phenotype_observeds.each do |info|
            if info.lethal?
              lethal = true
            end
          end
          
          if lethal
            lethal_count += 1
          end
        rescue Exception => e #if it doesn't match to a single coding region then advise
          $stderr.puts e
        end
      end
      total += group.orthomcl_genes.code('cel').count
    end
    puts "Genes found to be lethal: #{lethal_count} of #{total}"
  end
end
