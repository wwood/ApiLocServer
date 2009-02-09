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
    name = 'WBGene00000004'
    code = CodingRegion.find_by_name_or_alternate(name)
    if !code
      puts "#{name} not uploaded correctly - you aren't even close."; return
    end
    
    if code.phenotype_observeds.length != 1
      puts "Unexpected number of observations for gene #{name}: #{code.phenotype_observeds.inspect}"; return
    end
    
    # repeat for middle case to be surer
    name = 'WBGene00000018'
    code = CodingRegion.find_by_name_or_alternate(name)
    if !code
      puts "#{name} not uploaded correctly - you aren't even close."; return
    end
    
    if code.phenotype_observeds.length != 3
      puts "Unexpected number of observations for gene #{name}: #{code.phenotype_observeds.inspect}"; return
    end
    
    if code.phenotype_observeds.pick(:phenotype).sort[0] != 'germ_cell_hypersensitive_ionizing_radiation'
      puts "Bad phenotype phenotype name: #{code.phenotype_observeds.pick(:phenotype).sort[0]}"
    end
  end
  
  
  def mouse_phenotype_dictionary_entries
    if MousePhenotypeDictionaryEntry.count != 6370
      puts "Unexpected number of descriptions: #{MousePhenotypeDictionaryEntry.count}"
    end
    
    d = MousePhenotypeDictionaryEntry.first(:order => :pheno_id)
    if d.pheno_id != 'MP:0000001' or d.pheno_desc != 'Phenotype Ontology'
      puts "first phenotype unexpected attributes: #{d.inspect}"
    end
    
    d = MousePhenotypeDictionaryEntry.find_by_pheno_id('MP:0000035')
    if !d or d.pheno_desc != 'abnormal membranous labyrinth'
      puts "one in the middle failed: #{d.inspect}"
    end
  end
  
  
  def mouse_phenotypes
    code = CodingRegion.find_by_name_or_alternate_and_organism('ENSMUSG00000053094', Species.mouse_name)
    raise if !code
    infos = code.mouse_phenotypes
    raise if infos.length != 0

    code = CodingRegion.find_by_name_or_alternate_and_organism('ENSMUSG00000053286', Species.mouse_name)
    raise if !code
    infos = code.mouse_phenotypes
    raise if infos.length != 1
    raise if ['MP:0005386','MP:0005389'].sort !=
      infos[0].mouse_phenotype_dictionary_entries.pick(:pheno_id).sort
    
    # This is misleading if more genes than just the mouse pheno are uploaded. If
    # 5812 is found, that is a mistake - one with no ensembl has been uploaded
    # ben@ben:~/phd/data/Essentiality/Mouse$ awk -F'  ' '{print $9}' MGI_PhenotypicAllele.rpt |sort |uniq |grep . |wc -l
    # 5811
    raise if CodingRegion.species_name(Species.mouse_name).count != 5811
    
    #ben@ben:~/phd/data/Essentiality/Mouse$ awk -F'  ' '{print $10}' MGI_PhenotypicAllele.rpt |sed -e 's/\,/\n/g' |grep . |wc -l
    #53968
    raise Exception, "Count was bad: #{MousePhenotype.count}"if MousePhenotype.count != 53968
    
    
    # check to make sure the coding regions are linked as expected
    code = CodingRegion.find_by_name_or_alternate_and_organism('ENSMUSG00000053286', Species.mouse_name)
    raise if !code or code.orthomcl_genes.empty?

    assert_equal false, OrthomclGene.find_by_orthomcl_name('mmu|ENSMUSP00000010241').single_code.lethal?
  end

  def fly_pheno_info
    #first
    code = CodingRegion.find_by_name_or_alternate_and_organism('CG1977', Species.fly_name)
    raise if !code
    raise if code.drosophila_allele_genes.count != 42
    dag = code.drosophila_allele_genes.first(:conditions => "allele = 'FBal0000001'")
    raise if !dag
    raise if dag.drosophila_allele_phenotypes.count != 3
    raise if !dag.drosophila_allele_phenotypes.pick(:phenotype).include?('lethal')
    
    dag = DrosophilaAlleleGene.find_by_allele('FBal0216717')
    raise if !dag.coding_regions[0].names.include?('CG14016')
    
    #last
    dags = DrosophilaAlleleGene.find_by_allele('FBal0216768')
    raise if dags.drosophila_allele_phenotypes.count != 19
    raise if !dags.drosophila_allele_phenotypes.all.pick(:phenotype).include?('mesothoracic anterior fascicle, with Scer\GAL4[eve.RN2]')
    
    #ben@ben:~/phd/data/Essentiality/Drosophila$ awk -F'     ' '{print $1}' fbal_fbgn_annotation_id.txt |sort |uniq |grep . |wc -l
    #86982
    # minus the first 2 comment lines
    raise if DrosophilaAlleleGene.count != 86980
    #ben@ben:~/phd/data/Essentiality/Drosophila$ grep -v '\#' allele_phenotypic_data_fb_2008_06.tsv |wc -l
    #215805
    raise if DrosophilaAllelePhenotype.count != 24321
  end
end
