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
    #check for sce genes in orthomcl groups   
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
    
    #check sce gene in orthomcl no_group is linked correctly
    sce = OrthomclGene.find_by_orthomcl_name('sce|YDL223C')
    if !sce
      puts "Yeast not uploaded properly"
    else
      g = sce.coding_regions
      if !g
        puts "No coding region for orthomcl sce"
      else
        if g.length != 1
          puts "Sce orthomcl gene not linked in properly - nil"
        elsif g[0].string_id != 'YDL223C'
          puts "Sce orthomcl gene falsy linked in properly BAD BAD BAD - wrong code #{g[0].id}"
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
    
    #check an elegans gene in Orthomcl no_group is correctly linked to lethal phenotype
    name = 'cel|WBGene00000461'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association for gene in orthomcl no_group, should be true for lethal phenotype: #{name}"
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
    
    #Counting is hard by awk, grep so skpping
    
    # check to make sure the coding regions are linked as expected
    code = CodingRegion.find_by_name_or_alternate_and_organism('ENSMUSG00000053286', Species.mouse_name)
    raise if !code or code.orthomcl_genes.empty?

    raise if OrthomclGene.find_by_orthomcl_name('mmu|ENSMUSP00000010241').single_code.lethal?
    
    # check only trusted phenotypes are being counted i.e.:1)correct expt type + lethal = true; 2)correct expt type + not lethal = false; 3) incorrect expt type + lethal = nil 
    
    #1)check correct expt type + lethal = true
    #MGI:2180115	Aebp1<tm1Mdl>	targeted mutation 1, Matthew D Layne	Targeted (knock-out)	11438679	MGI:1197012	Aebp1	NM_009636	ENSMUSG00000020473	MP:0005370,MP:0005371,MP:0005374,MP:0005376,MP:0005380,MP:0005381
    #ENSMUSG00000020473 =mmu|ENSMUSP00000020766
    name = 'mmu|ENSMUSP00000020766'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association, should be true for lethal phenotype: #{name}"
    end
    
    #2)check correct expt type + not lethal = false
    #MGI:3702935	1190005F20Rik<Gt(W027A02)Wrst>	gene trap W027A02, Wolfgang Wurst	Gene trapped	17198746	MGI:1916185	1190005F20Rik	XM_355244	ENSMUSG00000053286	MP:0005386,MP:0005389
    #ENSMUSG00000053286 = mmu|ENSMUSP00000068309
    name = 'mmu|ENSMUSP00000068309'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != false
      puts "Bad lethal phenotype association, should be false as not lethal phenotype: #{name}"
    end
        
    #3)check incorrect expt type + lethal = nil 
    #MGI:3774413	Avil<tm1(ALPP)Fawa>	targeted mutation 1, Fan Wang	Targeted (knock-in)	18160648	MGI:1333798	Avil	NM_009635	ENSMUSG00000025432	MP:0003631,MP:0005372,MP:0005374
    #ENSMUSG00000025432 =mmu|ENSMUSP00000026500 
    name = 'mmu|ENSMUSP00000026500'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != nil
      puts "Bad lethal phenotype association, should be nil as incorrect expt type: #{name}"
    end
    
    #check a mouse gene in Orthomcl no_group is correctly linked to lethal phenotype
    name = 'mmu|ENSMUSP00000000031'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association for gene in orthomcl no_group, should be true for lethal phenotype: #{name}"
    end
  end

  def fly_pheno_info
    #first
    code = CodingRegion.find_by_name_or_alternate_and_organism('CG1977', Species.fly_name)
    raise if !code
    raise if code.drosophila_allele_genes.count != 42
    dag = code.drosophila_allele_genes.first(:conditions => "allele = 'FBal0000001'")
    raise if !dag
    raise if dag.drosophila_allele_phenotypes.count != 1
    raise if !dag.drosophila_allele_phenotypes.pick(:phenotype).include?('lethal | larval stage | recessive')
    
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
    raise if DrosophilaAllelePhenotype.count != 30607
    
    
    # check gene with known lethal phenotype is linked correctly. CG3095 is a gene that has a lethal phenotype according to flybase but is Not lethal according to the RNAi screen so because it is lethal from one of the sources (flybase/RNAi) it should be found to be lethal by our analysis
    name = 'dme|CG3095-PA'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association for gene, should be true for lethal phenotype: #{name}"
    end
    
    #check a drosophila gene in Orthomcl no_group is correctly linked to lethal phenotype. CG3096 is a gene that has a lethal phenotype according to flybase but is not present in RNAi screen dataset
    name = 'dme|CG3096-PA'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association for gene in orthomcl no_group, should be true for lethal phenotype: #{name}"
    end 
    
    #check a drosophila gene lethal by RNAi screen (lethality = Adult) is found to be lethal. This gene has no phenotype info in flybase.
    name = 'dme|CG6461-PA'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association for gene from RNAi screen, should be true for lethal phenotype: #{name}"
    end 
   
    #check a drosophila gene lethal by RNAi screen (lethality = Before Pupal) is found to be lethal. This gene is lethal in flybase.
    name = 'dme|CG10484-PA'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association for gene from RNAi screen, should be true for lethal phenotype: #{name}"
    end 
    
    #check a drosophila gene lethal by RNAi screen (lethality = Pupal) is found to be lethal. This gene is lethal in flybase.
    name = 'dme|CG18412-PA'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association for gene from RNAi screen, should be true for lethal phenotype: #{name}"
    end 
    
    #check a drosophila gene lethal by RNAi screen (lethality = Eclosion) is found to be lethal. This gene is not lethal in flybase.
    name = 'dme|CG3810-PA'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association for gene from RNAi screen, should be true for lethal phenotype: #{name}"
    end  
    
    # check a drosophila gene with RNAi info that says not lethal and no flybase info returns as false for not lethal
    name = 'dme|CG8927-PA'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != false
      puts "Bad phenotype association for gene from RNAi screen, should be false for lethal phenotype: #{name}"
    end  
    
  end
  
  def yeast_pheno_info
  
    name = 'YOR350C'
    code = CodingRegion.find_by_name_or_alternate(name)
    if !code
      puts "#{name} not uploaded correctly."; return
    end
    
    #count no .of phenotypes for this gene: $ grep 'YOR350C'  phenotype_data.tab | cut -f1,6,7,10 |sort -u| wc -l = 6
    if code.yeast_pheno_infos.length != 6
      puts "Unexpected number of observations for gene #{name}: #{code.yeast_pheno_infos.inspect}"; return
    end
    
    # repeat for gene not in orthomcl no_group
    name = 'YDL223C'
    code = CodingRegion.find_by_name_or_alternate(name)
    if !code
      puts "#{name} not uploaded correctly - you aren't even close."; return
    end
    
    # count no .of phenotypes for this gene: grep 'YDL223C' phenotype_data.tab | cut -f1,6,7,10 |sort -u| wc -l
    if code.yeast_pheno_infos.length != 3
      puts "Unexpected number of observations for gene #{name}: #{code.yeast_pheno_infos.inspect}"; return
    end
    
    #check phenotype, experiment type and mutant type are loaded correctly
    if code.yeast_pheno_infos.pick(:phenotype).sort[0] != 'chitin deposition: normal'
      puts "Bad phenotype phenotype name: #{code.yeast_pheno_infos.pick(:phenotype).sort[0]}"
    end
    if code.yeast_pheno_infos.pick(:experiment_type).sort[0] != 'systematic mutation set'
      puts "Bad phenotype experiment type: #{code.yeast_pheno_infos.pick(:experiment_type).sort[0]}"
    end
    if code.yeast_pheno_infos.pick(:mutant_type).sort[0] != 'null'
      puts "Bad phenotype mutant type: #{code.yeast_pheno_infos.pick(:mutant_type).sort[0]}"
    end
    
    #count no of unique phenotype entries: grep 'ORF' /home/maria/data/Essentiality/Yeast/phenotype_data.tab | cut -f6,7,10 | sort -u|wc -l = 1155
    raise if YeastPhenoInfo.count != 1155
    
    
    #check only genes with "trusted" phenotypes are included in analysis (i.e those from knockout/mutation and not overexpression)
    
    # check that a gene with correct expt type + lethal returns true
    # e.g YAL001C ORF     TFC3    S000000001      PMID: 12140549|SGD_REF: S000071347      systematic mutation set null            S288C   inviable 
    name = 'sce|YAL001C'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association, should be true for lethal phenotype: #{name}"
    end
    
    # check that a gene with correct expt type + not lethal returns false
    #YAL022C	ORF	FUN26	S000000020	PMID: 12140549|SGD_REF: S000071347	systematic mutation set	null		S288C	viable				
    #YAL022C	ORF	FUN26	S000000020	PMID: 16582425|SGD_REF: S000114750	systematic mutation set	null		S288C	chemical compound excretion: increased	inositols	synthetic medium lacking inositol and choline	Opi- phenotype; overproduction and excretion of inositol in the absence of inositol and choline	
    name = 'sce|YAL022C'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != false
      puts "Bad lethal phenotype association, should be false for lethal phenotype, not correct phenotype #{name}"
    end

    # check that a gene with incorrect expt type + lethal returns nil
    #YHR027C	ORF	RPN1	S000001069	PMID: 8970163|SGD_REF: S000048185	classical genetics	unspecified	hrd2-1	Other	resistance to chemicals: decreased	canavanine (1.5 ug/mL)			
    #YHR027C	ORF	RPN1	S000001069	PMID: 8970163|SGD_REF: S000048185	classical genetics	unspecified	hrd2-1	Other	resistance to chemicals: increased	lovastatin	
    name = 'sce|YHR027C'
    if  OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != nil
      puts "Bad phenotype inclusion, should be nil as not correct expt type #{name}"
    end
      
    #check a yeast gene in Orthomcl no_group is correctly linked to lethal phenotype
    name = 'sce|YPR177C'
    if OrthomclGene.find_by_orthomcl_name(name).single_code.lethal? != true
      puts "Bad lethal phenotype association for gene in orthomcl no_group, should be true for lethal phenotype: #{name}"
    end  
  end
  
  def testttt
    CSV.open(filename, 'r') do |gene|
      $stderr.puts gene.inspect
      ogenes = OrthomclGene.find_by_orthomcl_name(gene).orthomcl_group.orthomcl_genes

      if ogenes.code('sce').count = 1
        puts "sce"
        puts ogenes.code('sce').lethal?
      end
      if ogenes.code('dme').count = 1
        puts "dme"
        puts ogenes.code('dme').lethal?

        if ogenes.code('mmu').count = 1
          puts mmu
          puts ogenes.code('mmu').lethal?

        end
      end
    end
  
  
  
  
  end
end
