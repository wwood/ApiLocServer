# Methods used in the ApiLoc publication
class BScript
  def how_many_falciparum_genes_have_toxo_orthologs
    puts ".. all according to orthomcl v2"
      
    
    all_orthomcl_groups_with_falciparum = OrthomclRun.official_run_v2.orthomcl_groups.select {|group|
        group.orthomcl_genes.code('pfa').count > 0
    }
    puts "How many P. falciparum orthomcl groups?"
    puts all_orthomcl_groups_with_falciparum.length
    
    numbers_of_orthologs = all_orthomcl_groups_with_falciparum.each do |group|
      group.orthomcl_genes.code('tgo').count
    end

    puts
    puts "How many P. falciparum genes have any toxo orthomcl orthologs?"
    puts numbers_of_orthologs.reject {|num|
      num == 0
    }.length

    puts
    puts "How many P. falciparum genes have 1 to 1 mapping with toxo?"
    puts all_orthomcl_groups_with_falciparum.select {|group|
      group.orthomcl_genes.code('pfa') == 1 and group.orthomcl_genes.code('tgo') == 1
    }

    
  end
end
