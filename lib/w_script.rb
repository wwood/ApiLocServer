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
end
