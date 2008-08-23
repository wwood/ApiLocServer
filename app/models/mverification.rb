class Mverification < ActiveRecord::Base
  def orthomcl
    if OrthomclGroup.count(
        :include => :orthomcl_run,
        :conditions => "orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}'"
      ) != 79695
      puts "Incorrect number of gene groups"
    end
    
    # Pick a random gene to make sure it is OK
    g = OrthomclGroup.find_by_orthomcl_name('OG2_102004')
    if !g
      puts "No group found where expected"
    else
      genes = g.orthomcl_genes.collect{ |gene|
        #        puts gene.orthomcl_name
        gene.orthomcl_name
      }.sort
      if genes.sort != 
          ['osa|12004.m08540', 'ath|At5g09820.1', 'cre|145445', 'cme|CMK306C'].sort
        puts "Bad genes for group: #{genes.join(',')}"
      end
    end
    
    # Make sure falciparum and arabidopsis linking is OK
    #arab
    arab = OrthomclGene.find_by_orthomcl_name('ath|At1g01080.1')
    if !arab
      puts "Arabadopsis not uploaded properly"
    else
      g = arab.orthomcl_group
      if !g
        puts "No group for orthomcl arab random"
      elsif g.orthomcl_name != 'OG2_136536'
        puts "Bad group for orthomcl group"
      else
        codes = arab.coding_regions
        if !codes or codes.length != 1
          puts "Arab orthomcl gene not linked in properly - nil"
        elsif codes[0].string_id != 'AT1G01080.1'
          puts "Arab orthomcl gene falsy linked in properly BAD BAD BAD - wrong code #{codes[0].id}"
        end
      end
      
      
    end
  end
 
  def check_cel_links
    cel = OrthomclGene.find_by_orthomcl_name('cel|WBGene00000001')
    if !cel
      puts "Celegans not uploaded properly"
    else
      g = cel.orthomcl_group
      if !g
        puts "No group for orthomcl cel"
      elsif g.orthomcl_name != 'OG2_74360'
        puts "Bad group for orthomcl group"
      else
        codes = cel.coding_regions
        if !codes or codes.length != 1
          puts "Cel orthomcl gene not linked in properly - nil"
        elsif !codes[0].names.include?('WBGene00000001') # The name might be the string_id or the alternate, so check both
          puts "Cel orthomcl gene falsy linked in properly BAD BAD BAD - wrong code #{codes[0].inspect}"
        end
      end
    end
  end
  
  def check_sce_links
    sce = OrthomclGene.find_by_orthomcl_name('sce|YNL214W')
    if !sce
      puts "Yeast not uploaded properly"
    else
      g = sce.orthomcl_group
      if !g
        puts "No group for orthomcl sce"
      elsif g.orthomcl_name != 'OG2_102551'
        puts "Bad group for orthomcl group"
      else
        codes = sce.coding_regions
        if !codes or codes.length != 1
          puts "Sce orthomcl gene not linked in properly - nil"
        elsif codes[0].string_id != 'YNL214W'
          puts "Sce orthomcl gene falsy linked in properly BAD BAD BAD - wrong code #{codes[0].id}"
        end
      end
    end
  end
  
  
  def phenotype_observed
    code = CodingRegion.find_by_name_or_alternate('WBGene00000001')
    if !code
      puts "WBGene00000001 not uploaded correctly - you aren't even close."; return
    end
    
    if code.phenotype_observeds.length != 6
      puts "Unexpected number of observations for gene 1: #{code.phenotype_observeds.inspect}"; return
    end
    
    # repeat for middle case to be surer
    code = CodingRegion.find_by_name_or_alternate('WBGene00000008')
    if !code
      puts "WBGene00000006 not uploaded correctly - you aren't even close."; return
    end
    
    if code.phenotype_observeds.length != 8
      puts "Unexpected number of observations for gene 6: #{code.phenotype_observeds.inspect}"; return
    end
    
    if code.phenotype_observeds.pick(:phenotype).sort[0] != 'slow_growth'
      puts "Bad phenotype phenotype name: #{code.phenotype_observeds.pick(:phenotype).sort[0]}"
    end
  end


end
