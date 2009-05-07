

# A class for verifying the state of the database is as expected.
class Verification
  def falciparum
    
    # this gene should not exist
    if trna = CodingRegion.find_by_string_id('PFCOMPIRB-tRNA-Thr-1')
      p "tRNA uploaded - bad."
      p trna.upstream_distance
      p trna.calculate_upstream_region
    end
    
    # check the descriptions are correctly input
    pfemp = CodingRegion.find_by_string_id('PFA0005w')
    if !pfemp
      p "Didn't upload PFA0005w correctly"
    else
      if pfemp.annotation
        if pfemp.annotation.annotation != 'erythrocyte membrane protein 1 (PfEMP1)'
          p "Wrong description for PFA0005w: '#{pfemp.annotation.annotation}'"
        end
      else
        p "Didn't upload PFA0005w annotation at all."
      end
    end
    
    # this gene should exist, it is reverse in the GFF file (MAL11 is anyway)
    c = CodingRegion.find_by_string_id 'PF11_0521'
    if !c
      p "PF11_0521 doesn't exist. fail"
    end
    r = c.calculate_upstream_region
    if r != (2025814-2023031)
      p "upstream region PF11_0521 incorrectly calculated: #{c.calculate_upstream_region}"
    end
    
    # After the calculation has taken place, and filled in properly..
    if c.upstream_distance != (2025814-2023031)
      p "upstream region PF11_0521 incorrectly stored: #{c.upstream_distance}"
    end
    
    #check a downstream one
    c = CodingRegion.find_by_string_id 'PF11_0520'
    if !c
      p "PF11_0520 doesn't exist. fail"
    end
    r = c.calculate_upstream_region
    if r != (2025814-2023031)
      p "upstream region PF11_0520 incorrectly calculated: #{r}"
    end
    
    # After the calculation has taken place, and filled in properly..
    if c.upstream_distance != (2025814-2023031)
      p "upstream region PF11_0520 incorrectly stored: #{c.upstream_distance}"
    end
    
    
    
    # Check alternates
    code = CodingRegion.find_by_string_id 'PFL0010c'
    if !code
      p "should have found PFL0010c as a coding region"
    else
      ids = code.coding_region_alternate_string_ids
      if !ids or ids.length != 2
        p "PFL0010c should have 2 alternate ids: 2277.t00002,MAL12P1.2, was #{ids}"
      end
    end
    
    #check derisi data
    #    dees = Derisi20063d7Logmean.find(:all, :include => :coding_region)
    #    if dees.length < 100
    #      p "Derisi data has not been linked into the database properly"
    #    end
    
    alt = CodingRegionAlternateStringId.find_by_name('MAL1P4.03')
    if !alt or alt.coding_region.string_id != 'PFA0015c'
      p "bad alternate id for PFA0015c/MAL1P4.03"
    end
    
    #    d = Derisi20063d7Logmean.find_by_plasmodbid 'PFA0005w'
    #    if !d
    #      p "bad derisi logged meaned 3d7 table"
    #    else
    #      if !d.coding_region
    #        p "derisi data not linked in properly"
    #      elsif d.coding_region.string_id != 'PFA0005w'
    #        p "bad coding_region_id"
    #      end
    #    end
    
    
    # ben@ben:~/phd/data/falciparum/genome/plasmodb/5.4$ grep '       gene    ' *.gff |grep 'apidb|MAL' |wc -l
    # 5532
    # ben@ben:~/phd/data/falciparum/genome/plasmodb/5.4$ grep '>' PfalciparumAnnotatedProteins_plasmoDB-5.4.fasta |wc -l
    # 5460
    count = CodingRegion.species_name(Species.falciparum_name).count
    expected = 5532
    if count  != 5532
      p "Unexpected number of falciparum genes found uploaded: #{count}, expected #{expected}"
    end
    
    # a troublesome one
    raise if !CodingRegion.ff('PFC0890w')
    
    
    raise if CodingRegion.ff('PF14_0043').amino_acid_sequence.sequence != 'MEENLMKLGTLMLLGFGEAGAKIISKNINEQERVNLLINGEIVYSVFSFCDIRNFTEITEVLKEKIMIFINLIAEIIHECCDFYGGTINKNIGDAFLLVWKYQKKEYSNKKMNMFKSPNNNYDEYSEKENINRICDLAFLSTVQTLIKLRKSEKIHIFLNNENMDELIKNNILELSFGLHFGWAIEGAIGSSYKIDLSYLSENVNIASRLQDISKIYKNNIVISGDFYDNMSEKFKVFDDIKKKAERKKRKKEVLNLSYNLYEEYAKNDDIKFIKIHYPKDYLEQFKIALESYLIGKWNESKNILEYLKRNNIFEDEILNQLWNFLSMNNFIAPSDWCGYRKFLQKS'
    raise if CodingRegion.ff('MAL13P1.385').amino_acid_sequence.sequence != 'MKIGDVLHDYKLYDNTKKKSSEMVINENDNKERLLEEFEIRSKVRKVCLGIPTQDIDVKNILRLLKEPICLFGEDSYDKRKRLKNILITKYDRLIIKKKIEEEDDVEEFKNILKRYYIDFSDLYPSGLSEANKINEVHDKHKLKDVHDTKEEQNVHMKTVREEDKDILKEKCYTEGTKDLKKSRIEITIKTLPRIFLYKEMINKFQNGYSKKEYENYITSFNEHIKKESDLYVSQLGDDRPLTMGKFSPDNSVFAISSFNSYINIFNYRNDDYNLIKTLKNGHEEKINCIEWNYPNNYSYYSTMNYKDLSKHDLLLASCSSDKSFCIWKPFYDEYDDTNDNINDNINEYINENINENINENINENINDNISDNTSDTISDNINDNINDNISDSISDNISDNKNNNSHKVDKYNSNKNKLSAQNKNYLLCKVNAHDDRINKICFHPLNKYVLTCSDDETIKMFDIETQQELFYQEGHNTTVYSIAFNPYGNLYISGDSKGGLMLWDIRTGKNVEQIKMAHNNSIMNINFNPFLANMFCTCSTDNTIKIFDLRKFQISCNILAHNKIVTDALFEPTYGRYIVSSSFDTFIKIWDSVNFYCTKILCNNNNKVRNVDIAPDGSFISSTSFDRTWKLYKNKEYTQDNILSHFM'

    # From the GFF file, and confirmed by looking at the genome browser
    # apidb|MAL12	ApiDB	supercontig	1	2271478
    # apidb|MAL13	ApiDB	supercontig	1	2895605
    falciparum = Species.find_by_name(Species::FALCIPARUM_NAME)
    {'apidb|MAL12' => 2271478, 'apidb|MAL13' => 2895605}.each do |scaffold, expected_length|
      l = Scaffold.find_by_name_and_species_id(scaffold, falciparum.id).length
      unless l == expected_length
        $stderr.puts "Scaffold length - found #{l}, expected #{expected_length}"
      end
    end

    # Conserved Domains
    unless CodingRegion.ff('PFC1120c').conserved_domains.reach.identifier.uniq.sort ==
        %w(PF03011 PF05424 SSF46689).sort
      $stderr.puts "Conserved domains: #{CodingRegion.ff('PFC1120c').conserved_domains.reach.identifier.uniq.sort}"
    end
    raise unless CodingRegion.ff('PFC1045c').conserved_domains.count == 18

    # PFC1060c	PFAM	PF03343	SART-1	1	669	   .0E+00
    raise unless CodingRegion.ff('PFC1060c').conserved_domains.first.pick(:identifier, :name, :start, :stop, :score) ==
      ['PF03343', 'SART-1', 1, 669, 0.0]

    #    ben@ben:~/phd/gnr$ awk '{print $1}' /home/ben/phd/data/falciparum/proteomics/FoodVacuole2008/FoodVacuoleProteome.csv |grep '^[PQO][01-9]' |wc -l
    #116
    $stderr.puts "Food Vacuole Proteomics no good" unless FvProteomicExperimentResult.count == 116

    # Whole Cell Proteomics
    
  end
  
  def gene_lists
    alist = PlasmodbGeneList.find_by_description('apicoplast.Stuart.20080215')
    if (alist.plasmodb_gene_list_entries.length != 169)
      p "Gene list size for apicoplast incorrect"
    end
    
    
    code = CodingRegion.find_by_string_id 'PF07_0068'
    e = PlasmodbGeneListEntry.find_by_coding_region_id_and_plasmodb_gene_list_id(
      code.id, alist.id
    )
    if !e
      p "Entry PF07_0068 not uploaded correctly"
    end
    
    if (PlasmodbGeneList.find_by_description('cytosolic.Stuart.20080220').plasmodb_gene_list_entries.length != 27)
      p "Gene list size for apicoplast tRNA cytosolic incorrect"
    end
    
    #make sure all lists have at least 1 entry
    PlasmodbGeneList.find(:all).each do |list|
      entries = list.plasmodb_gene_list_entries
      if !entries or entries.length == 0
        p "Gene list has no entries: #{list.description}"
      else
        codes = CodingRegion.find(:all, 
          :include => :plasmodb_gene_list_entries,
          :conditions => "plasmodb_gene_list_entries.plasmodb_gene_list_id=#{list.id}"
        )
        if !codes or codes.length == 0
          p "Gene list #{list.description} invalid - contains no coding regions"
        else
          puts "#{codes.length} #{list.description}"
        end
      end
    end
    
    
  end
  
  def go
    #    uyen@uyen:~/phd/gnr$ grep '^id:' /home/uyen/phd/data/GO/20080304/gene_ontology_edit.obo |wc -l
    #    26078
    #    uyen@uyen:~/phd/gnr$ grep '^id:' /home/uyen/phd/data/GO/20080304/gene_ontology_edit.obo |sort |head
    #    id: GO:0000001
    #    id: GO:0000002
    #    id: GO:0000003
    #    id: GO:0000005
    #    id: GO:0000006
    #    id: GO:0000007
    #    id: GO:0000008
    #    id: GO:0000009
    #    id: GO:0000010
    #    id: GO:0000011
    #    uyen@uyen:~/phd/gnr$ grep '^id:' /home/uyen/phd/data/GO/20080304/gene_ontology_edit.obo |sort |tail
    #    id: GO:0065002
    #    id: GO:0065003
    #    id: GO:0065004
    #    id: GO:0065005
    #    id: GO:0065006
    #    id: GO:0065007
    #    id: GO:0065008
    #    id: GO:0065009
    #    id: GO:0065010
    #    id: part_of
    #    uyen@uyen:~/phd/gnr$ grep '\[Term\]' /home/uyen/phd/data/GO/20080304/gene_ontology_edit.obo |wc -l
    #    26077


    count = GoTerm.count
    answer = 26077
    if count != answer
      p "Go term count incorrect: #{count}, when it should be #{answer}"
    end
    
    #    uyen@uyen:~/phd/gnr$ grep 'alt_id:' /home/uyen/phd/data/GO/20080304/gene_ontology_edit.obo |wc -l
    #    1071
    #    uyen@uyen:~/phd/gnr$ grep 'alt_id:' /home/uyen/phd/data/GO/20080304/gene_ontology_edit.obo |sort |tail -n 1
    #    alt_id: GO:0055027
    #    uyen@uyen:~/phd/gnr$ grep 'alt_id:' /home/uyen/phd/data/GO/20080304/gene_ontology_edit.obo |sort |head -n 1
    #    alt_id: GO:0000004
    count = GoAlternate.count
    answer = 1071
    if count != answer
      p "Go alternate count incorrect: #{count}, when it should be #{answer}"
    end

  end
  
  
  def yeast
    genes = Gene.find(:all, 
      :include => {:scaffold => :species}, 
      :conditions => "species.name='yeast'"
    )
    # Unsure why this doesn't work:
    if genes.length != 6608+21+89-1
      p "number of genes unexpected, #{genes.length} vs expected #{6608+21+89}"
    end
    
    #Localisation from GFP
    method = LocalisationMethod.find_by_description LocalisationMethod.yeast_gfp_description
    if ! method
      p "No Yeast GFP localisation method found"
    end
    codes = CodingRegion.s(Species.yeast_name).count(:select => 'coding_region_localisations.id',
      :conditions => "localisation_method_id=#{method.id}",
      :joins => :localisations
    )
    expected = 4152
    if codes != expected
      # not 4160 (the simple count) because some of them are duplicates of the same
      # ORF
      puts "number of coding_region_localisations, #{codes} vs expected #{expected}"
    end
    
    locs = Localisation.find(:all,
      :joins => :coding_regions,
      :conditions => "string_id='YER173W'"
    ).collect {|l| l.name}
      
    if ['cytoplasm','nucleus'].sort != locs.sort
      p "bad localisations found: #{locs}"
    end
    
    
    # test orthomcl official is joined up properly
    count = CodingRegion.count(
      :include => [
        {:gene => {:scaffold => :species}},
        {:orthomcl_genes => {:orthomcl_group => :orthomcl_run}}
      ],
      :conditions => ["#{OrthomclRun.table_name}.name=? and species.name='yeast'",
        OrthomclRun.official_run_v2_name
      ]
    )
    if count < 4000
      p "Orthomcl official doesn't seem to be linked in. Found #{count} coding regions with links"
    end
  end
  
  
  def strangeness
    els = CodingRegionLocalisation.find(:all, 
      :include => [:coding_region, :localisation],
      :limit => 5, :order => 'coding_region_localisations.id desc')
    
    els.each do |e|
      puts "#{e.id} #{e.localisation.name} #{e.coding_region.string_id}"
    end
    
    els = CodingRegionLocalisation.find(:all, 
      :include => [:coding_region, :localisation],
      :conditions => "string_id='YFL007W'", 
      :order => 'coding_region_localisations.id desc')
    puts
    els.each do |e|
      puts "#{e.id} #{e.localisation.name} #{e.coding_region.string_id}"
    end
  end
  
  def orthomcl
    expected = 79695
    actual = OrthomclGroup.official.count(:select => 'distinct(orthomcl_groups.id)')
    if actual != 79695
      puts "Incorrect number of gene groups. Found #{actual}, expected #{expected}"
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
    
    
    # Check mouse - one with a group and one without
    # OG2_100010: mmu|ENSMUSP00000096204 rno|ENSRNOP00000028006 hsa|ENSP00000301244 sma|Smp_052230
    mice = OrthomclGene.find_all_by_orthomcl_name('mmu|ENSMUSP00000096204')
    raise unless mice.length == 1
    mice = OrthomclGene.official.find_all_by_orthomcl_name('mmu|ENSMUSP00000096204')
    raise unless mice.length == 1
    mouse = mice[0]
    raise unless mouse.orthomcl_group.orthomcl_name == 'OG2_100010'
    raise if mouse.single_code.nil?
    # no group and no coding region (in mouse_phenotypes at least)
    # >mmu|ENSMUSP00000040224 | no_group | ENSMUSG00000004377|ENSF00000003814|WD repeat and FYVE domain containing 1 [Source:MarkerSymbol;Acc:MGI:1916618]
    mice = OrthomclGene.find_all_by_orthomcl_name('mmu|ENSMUSP00000040224')
    raise unless mice.length == 1
    mice = OrthomclGene.find_all_by_orthomcl_name('mmu|ENSMUSP00000040224')
    raise unless mice.length == 1
    mouse = mice[0]
    raise unless mouse.orthomcl_group.nil?
    # no group and something attached in mouse_phenotypes
    # >mmu|ENSMUSP00000081669 | no_group | ENSMUSG00000039809|ENSF00000001597|gamma-aminobutyric acid (GABA) B receptor 2 [Source:MarkerSymbol;Acc:MGI:2386030]
    mice = OrthomclGene.find_all_by_orthomcl_name('mmu|ENSMUSP00000081669')
    raise unless mice.length == 1
    mice = OrthomclGene.find_all_by_orthomcl_name('mmu|ENSMUSP00000081669')
    raise unless mice.length == 1
    mouse = mice[0]
    raise unless mouse.orthomcl_group.nil?
    raise if mouse.single_code.nil?   
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
        elsif codes[0].string_id != 'WBGene00000001'
          puts "Cel orthomcl gene falsy linked in properly BAD BAD BAD - wrong code #{codes[0].id}"
        end
      end
      
      
    end
  end



 
  def suba
    
    
    codes = CodingRegion.find(:all, 
      :include => {:gene => {:scaffold => :species}}, 
      :conditions => "species.name='Arabidopsis'"
    )
    code_num = 6872
    if codes.length != code_num
      puts "Wrong number of coding regions: Expected #{code_num}, was #{codes.length}"
    end
    
    #random
    
  end
  
  def theileria
    hits = CodingRegionAlternateStringId.count(
      :include => {:coding_region => {:gene => {:scaffold => :species}}},
      :conditions => "species.name='#{Species.theileria_parva_name}'"
    )
    if hits != 4079
      puts "Not enough uploaded. Found #{hits}, correct amount is 4079"
    end
    
    code = CodingRegion.find_by_name_or_alternate('547.m00128')
    if !code
      puts "not enough uploaded"
    elsif code.string_id != 'TP05_0003'
      puts "Badly linked alternate"
    elsif !code.orthomcl_genes[0]
      puts "orthomcl gene not properly linked in"
    end
    
    
    
  end

  def amino_acid_sequences
    c = AminoAcidSequence.count(
      :include => {:coding_region => {:gene => {:scaffold => :species}}},
      :conditions => "species.name='Babesia bovis'"
    ) 
    if c != 3703
      puts "Wrong number of babesia sequences: #{c}, expected 3703"
    end
    
    aa = AminoAcidSequence.find(:first,
      :include => :coding_region,
      :conditions => "coding_regions.string_id='BBOV_I000830'"
    )
    
    if !SignalP.calculate_signal?(aa.sequence)
      puts "Badly implemented sequence signal thingy"
    end
  end
  
  def transmembrane_domains
    # toppred only for the moment
    code = CodingRegion.find_by_name_or_alternate_and_organism('MAL8P1.156', Species.falciparum_name)
    if code.toppred_min_transmembrane_domain_length.measurement != 21
      $stderr.puts "Simple min problem found"
    end
    
    
    code = CodingRegion.find_by_name_or_alternate_and_organism('MAL8P1.156', Species.falciparum_name)
    if code.toppred_min_transmembrane_domain_length.measurement != 21
      $stderr.puts "Simple min problem found"
    end
    
  end
  
  
  def uniprot
    codes = CodingRegion.find_all_by_string_id('Q4U9M9')
    if codes.length != 1 
      $stderr.puts "First coding region not found or too many times uploaded"
    end
    code = codes[0]
    if !(code.annotation.annotation === '104 kDa microneme/rhoptry antigen precursor - Theileria annulata')
      $stderr.puts 'annotation problems'
    end
    if !(code.amino_acid_sequence.sequence[0..3] === 'MKFL')
      $stderr.puts 'sequence problems'
    end
    if CodingRegion.find_by_name_or_alternate('104K_THEAN').id != code.id
      $stderr.puts 'alternate id problems'
    end
    
    if CodingRegion.count(:include => :gene, :conditions => "genes.name like 'UniprotKB Dummy%'") != 385721
      $stderr.puts "Wrong number of sequences.."
    end
  end
  
  
  
  
  
  def membrain
    gene = Gene.find_by_name('membrain_dummy', :include => :coding_regions)
    if gene.coding_regions.length != 130
      $stderr.puts "Wrong number of coding regions uploaded"
    end
    
    code = CodingRegion.find_by_string_id_and_gene_id(
      'P00404',
      gene.id
    )
    
    if MembrainTransmembraneDomain.count(:conditions => "coding_region_id = #{code.id}") != 2
      $stderr.puts "No transmembrane domain found"
    end
    
    mem = MembrainTransmembraneDomain.find_by_coding_region_id(code.id, :order => 'start')
    if mem.start != 19 or mem.stop != 42
      $stderr.puts "Badly uploaded start and/or stop"
    end
    
    #>P08336   8-29   164-189    
    code = CodingRegion.find_by_string_id_and_gene_id(
      'P08336',
      gene.id
    )
    mem = MembrainTransmembraneDomain.find_by_coding_region_id(code.id, :order => 'start desc')
    if mem.start != 164 or mem.stop != 189
      $stderr.puts "Badly uploaded start and/or stop"
    end
    
    
    #pdb ones, which aren't in the original file
    code = CodingRegion.find_by_string_id_and_gene_id(
      '1AP9.pdb_A',
      gene.id
    )
    if code.membrain_transmembrane_domains.length != 7
      $stderr.puts "Problems with the pdb one"
    end
    #Observed	10-30; 39-62; 77-101; 105-127; 134-157; 169-191; 202-224
    mem = MembrainTransmembraneDomain.find_by_coding_region_id(code.id, :order => 'start desc')
    if mem.start != 202 or mem.stop != 224
      $stderr.puts "Badly uploaded start and/or stop for pdb"
    end
    
    
    # every one should have a tmd
    gene.coding_regions.each do |coda|
      if coda.membrain_transmembrane_domains.length < 1
        # some come up here. This is because they are attached to another chain that actually does have a TMD?
        # bad data on Membrain's part I believe.
        ems = coda.string_id.match('(....\.pdb_).') or raise Exception, "bad parsing of #{coda.string_id}"
        if MembrainTransmembraneDomain.count(
            :include => :coding_region,
            :conditions => "coding_regions.string_id like '#{ems[1]}%'"
          ) <1
          
          # and still a few persist - heterodimers? meh. Good enough.
          $stderr.puts "No TMDs for #{coda.string_id}"
        end
      end
    end
  end
  
  
  def memsat
    # check the number of yeast results
    #            MemsatAverageTransmembraneDomainLength.find_or_create_by_coding_region_id_and_measurement(code.id, tmds.average_length)
    #        MemsatMinTransmembraneDomainLength.find_or_create_by_coding_region_id_and_measurement(code.id, tmds.minimum_length)
    if 5883 != MemsatAverageTransmembraneDomainLength.count(
        :include => {:coding_region => {:gene => {:scaffold => :species}}},
        :conditions => "species.name ='#{Species.yeast_name}'") or 
        5883 != MemsatMinTransmembraneDomainLength.count(
        :include => {:coding_region => {:gene => {:scaffold => :species}}},
        :conditions => "species.name ='#{Species.yeast_name}'") 
      $stderr.puts "Wrong number of yeast proteins uploaded"
    end
  end
  
  
  def babesia_bovis_cds
    # Find the first cds
    name = "BBOV_II000010"
    code = CodingRegion.find_by_name_or_alternate(name)
    if !code
      raise Exception, "No coding region #{name} found"
    end
    if !code.negative_orientation?
      raise Exception, "Coding region orientation not properly set: #{code.inspect}"
    end
    cds = Cd.all(:joins => {:coding_region => {:gene => {:scaffold => :species}}}, :conditions => 
        {:coding_regions => {:id => code.id}, :species => {:name => Species.babesia_bovis_name}}
    )
    if cds.length != 1
      raise Exception, "Strange number of cds found for #{name}: #{cds.inspect}"
    end
    cd = cds[0]
    if cd.start != 1311 or cd.stop != 1787 or cd.coding_region.gene.scaffold.name != 'AAXT01000003.gb'
      raise Exception, "start or stop wrong for #{name}: #{cd.inspect} #{cd.coding_region.gene.scaffold.inspect}"
    end
    
    
    # Find one on another chromosome to be more certain
    name = "BBOV_I005780"
    code = CodingRegion.find_by_name_or_alternate(name)
    if !code
      raise Exception, "No coding region #{name} found"
    end
    if !code.negative_orientation?
      raise Exception, "Coding region orientation not properly set: #{code.inspect}"
    end
    cds = Cd.all(:joins => {:coding_region => {:gene => {:scaffold => :species}}}, :conditions => 
        {:coding_regions => {:id => code.id}, :species => {:name => Species.babesia_bovis_name}}
    )
    if cds.length != 1
      raise Exception, "Strange number of cds found for #{name}: #{cds.inspect}"
    end
    cd = cds[0]
    if cd.start != 9810 or cd.stop != 9963 or cd.coding_region.gene.scaffold.name != 'AAXT01000012.gb'
      raise Exception, "start or stop wrong for #{name}: #{cd.inspect}"
    end
    
    # Find one with positive orientation
    name = "BBOV_I005300"
    code = CodingRegion.find_by_name_or_alternate(name)
    if !code
      raise Exception, "No coding region #{name} found"
    end
    if !code.positive_orientation?
      raise Exception, "Coding region orientation not properly set: #{code.inspect}"
    end
    cds = Cd.all(:joins => {:coding_region => {:gene => {:scaffold => :species}}}, :conditions => 
        {:coding_regions => {:id => code.id}, :species => {:name => Species.babesia_bovis_name}}
    )
    if cds.length != 1
      raise Exception, "Strange number of cds found for #{name}: #{cds.inspect}"
    end
    cd = cds[0]
    if cd.start != 3374 or cd.stop != 4232 or cd.coding_region.gene.scaffold.name != 'AAXT01000011.gb'
      raise Exception, "start or stop wrong for #{name}: #{cd.inspect}"
    end
  end
  
  def snp_jeffares
    raise if CodingRegion.ff('MAL13P1.12').it_synonymous_snp
    raise if !CodingRegion.ff('MAL13P1.148').it_synonymous_snp
    raise if ItSynonymousSnp.count != ItNonSynonymousSnp.count
    raise if PfClinSynonymousSnp.count != PfClinNonSynonymousSnp.count
    raise if CodingRegion.ff('MAL13P1.107').pf_clin_non_synonymous_snp.value != 2.89
    raise if CodingRegion.ff('MAL13P1.100').reichenowi_dnds.value != 0.19
    raise if CodingRegion.ff('MAL13P1.100').reichenowi_non_synonymous_snp.value != 9.58
    raise if CodingRegion.ff('MAL13P1.100').reichenowi_synonymous_snp.value != 8.83
    
    # 0.07	561	1.02	4.1
    raise if CodingRegion.ff('MAL13P1.111').reichenowi_dnds.value != 0.07
    raise if CodingRegion.ff('MAL13P1.111').reichenowi_non_synonymous_snp.value != 1.02
    raise if CodingRegion.ff('MAL13P1.111').reichenowi_synonymous_snp.value != 4.1

    #ben@ben:~/phd/gnr$ awk -F'      ' '{print $16,$15}' /home/ben/phd/data/falciparum/polymorphism/Jeffares2007/ng1931-S4.csv |grep . |grep -v REICH |grep -v 'NA NA' | grep -v '^ $' |wc -l
    #3024
    # There are no entries that have a reich value and a coding region that no longer exists, however there is
    # genes that have 2 measurements for the same - ignoring those so I can keep the coding_region has_one reichenowi_dnds
    # thing going
    raise unless ReichenowiNonSynonymousSnp.count == 3024
    raise unless ReichenowiSynonymousSnp.count == 3024
    raise unless ReichenowiDnds.count == 3024
  end

  
  def nucleo
    raise if NucleoNls.count != NucleoNonNls.count
    # $ uniq ../data/falciparum/localisation/prediction\ outputs/nucleoV20080902.tab  |wc -l 
    # 292
    raise if NucleoNls.count != 292
    raise if CodingRegion.ff('PFE0355c').nucleo_nls.value != 0.83
    raise if CodingRegion.ff('PFI0105c').nucleo_non_nls.value != 0.57
  end
  
  def pats
    raise if PatsPrediction.count != PatsScore.count
    raise if PatsPrediction.count != 269
    raise if CodingRegion.ff('PFA0410w').pats_prediction.value != false
    raise if CodingRegion.ff('PFA0445w').pats_score.value != 0.702
  end
  
  def pprowler
    raise if PprowlerMtpScore.count != PprowlerOtherScore.count
    raise if PprowlerMtpScore.count != PprowlerSignalScore.count
    raise if PprowlerMtpScore.count != 269
    raise if CodingRegion.ff('PFA0410w').pprowler_mtp_score.value != 0.03
    raise if CodingRegion.ff('PFA0445w').pprowler_signal_score.value != 0.96
  end
  
  def top_level_localisations
    raise Exception, "Count not right: #{TopLevelLocalisation.count}" if TopLevelLocalisation::TOP_LEVEL_LOCALISATIONS.length != TopLevelLocalisation.count
    raise if Localisation.find_by_name('hepatocyte nucleus').malaria_top_level_localisations.pick(:name) != ['nucleus']
  end
  
  def seven_species_orthomcl
    r = OrthomclRun.find_by_name(OrthomclRun.seven_species_filtering_name)
    raise if r.orthomcl_groups.count != 7657
    raise if r.orthomcl_groups.count(:conditions => {:orthomcl_name => 'ORTHOMCL7653'}) != 1
    raise if r.orthomcl_groups.first(:conditions => {:orthomcl_name => 'ORTHOMCL7653'}).orthomcl_genes.pick(:orthomcl_name).sort !=
      ['TA05550','TA16035'].sort
    raise if !r.orthomcl_groups.first(:conditions => {:orthomcl_name => 'ORTHOMCL42'}).orthomcl_genes.pick(:orthomcl_name).include?('Cryptosporidium_parvum|AAEE01000006|cgd1_330|Annotation|GenBank|(protein')
  end
  
  def vivax
    raise if !CodingRegion.fs('Pv085115', Species.vivax_name)
    raise if !CodingRegion.fs('Pv085115', Species.vivax_name).amino_acid_sequence
  end

  def crypto
    # ben@ben:~/phd/data/Cryptosporidium hominis/genome/cryptoDB/4.0$ grep '  CDS     ' c_hominis_tu502.gff |wc -l
    # 3886
    raise unless CodingRegion.s(Species::CYRYPTOSPORIDIUM_HOMINIS_NAME).count == 3886
    # ben@ben:~/phd/data/Cryptosporidium hominis/genome/cryptoDB/4.0$ grep '>' /home/ben/phd/data/Cryptosporidium\ parvum/genome/cryptoDB/4.0/CparvumAnnotatedProteins_CryptoDB-4.0.fasta |wc -l
    # 3805
    raise unless CodingRegion.s(Species::CYRYPTOSPORIDIUM_PARVUM_NAME).count == 3805

    raise unless AminoAcidSequence.count(:joins => {:coding_region => {:gene => {:scaffold => :species}}}, :conditions => ['species.name = ?', Species::CYRYPTOSPORIDIUM_HOMINIS_NAME]) == 3886
    raise unless AminoAcidSequence.count(:joins => {:coding_region => {:gene => {:scaffold => :species}}}, :conditions => ['species.name = ?', Species::CYRYPTOSPORIDIUM_PARVUM_NAME]) == 3805
  end
  
  def winzeler_2003_microarray
    # test first normal one
    raise if CodingRegion.ff('MAL13P1.100').microarray_measurements.timepoint_name('Cell Cycle 1 (Sorbitol), Early Ring').count != 20
    
    # test random temperature one
    raise if CodingRegion.ff('MAL13P1.106').microarray_measurements.timepoint_name('Cell Cycle 2 (Temperature), Early Ring').count != 11
    
    raise if Microarray.find_by_description(Microarray::WINZELER_2003_NAME).microarray_timepoints.count != 17
  end
  
  def toxoplasma_gondii
    # test gff first
    # ben@ben:~/phd/gnr$ grep '>' ../data/Toxoplasma\ gondii/ToxoDB/4.3/TgondiiME49/TgondiiAnnotatedProteins_toxoDB-4.3.fasta |wc -l
    # 7793
    raise if CodingRegion.s(Species::TOXOPLASMA_GONDII_NAME).count != 7793
    
    # test first one is there
    raise if !CodingRegion.fs('190.m00008', Species::TOXOPLASMA_GONDII_NAME)
    raise if !CodingRegion.fs('41.m02959', Species::TOXOPLASMA_GONDII_NAME)
    raise if !CodingRegion.fs('328.m00001', Species::TOXOPLASMA_GONDII_NAME)
    
    # check a sequence from the fasta file
    raise if CodingRegion.fs('328.m00001', Species::TOXOPLASMA_GONDII_NAME).amino_acid_sequence.sequence !=
      'MKHPIICRLIHFSNSSNINNFHDLRSLRFEAKSPNSRRTLHKPGVTIWMPPTLPHIRRTRIHKI*'
    raise if CodingRegion.fs('41.m02959', Species::TOXOPLASMA_GONDII_NAME).amino_acid_sequence.sequence != 
      %w(MNPVAAAEAAAVRERVAEEMGEIAEAAGRLFDLGGEHRERATAFLYRGCAAQVATSTAGM
YGEMVESSVRQVVQYMRHYGGDEFSVFLDLGSGRGAPSCIALYQQPWLACLGIEKCPQAY
SLSLETHWTVLRREMMQAELIAPPPRFPSVLCASQRCASEADGAHTADDSGEATAQKQAS
RWTSGALCGRGRPGGRVPERRLCFTQEDLSAFYHLEGVTHVYSFDAAMEGALINWIVQMF
MRTKTWYLYASFRSDLISKFELKGASLVGQVSSSMWVSSEGRTTYIYVKDDWRTCKAYHR
RWLSQFLFSSSVSSKTPTGEAGAPGVSKPEASGAAVGFQEEQNLAAKVLQMTAAETFRLL
CVQQEAMWDEFENRDRTPSRSRCPLQAQRECDASLRSPSSPSPASETRSRGRSTSRRRAS
SVSGASRHLQLQTLQLQAASHCCAEDRLPDCLRVHGRIWATEQDLEEKEPRDVERREAVP
RDTKGEFSTSEENEEKLLRHAVKTFRASFVRMSKWLQPLTVLDMLRLAFLPGEGQEAWLE
QRQQQLTGGGVLTRTRRPTARGFDEQERRKEELERDGLLEMLAKAENPQEAAMCRRNLEL
KLETTRRDRYSIFPFSLLQDSELSPELLTRVNEDAQAVAESLAHLLSSPSPRTSSVSPLS
SPLSARRHSAVAPVSVQRKSQGLPVSPQKRDLRVRVVDAAQTVSPCRPRFSAQPNTLGEW
NCQDSNMEDVEQSVSFLGGSQPSVMPSFDSTPRRRSRRSSPHKELTSCRRKSELSPQISS
RKEKNEHTPSPPLKRRGAGNPEESKAMISDPASSRMTPKTRAAYKLMELGFDALEIRTAL
SRRKRRMPEGLDN*).join('')
    
    raise if CodingRegion.s(Species::TOXOPLASMA_GONDII_NAME).count(:joins => :amino_acid_sequence) != 7793
    
    # check orthomcl integration - single_orthomcl will raise an exception by itself
    CodingRegion.fs('80.m02161', Species::TOXOPLASMA_GONDII_NAME).single_orthomcl
  end
  
  def upload_winzeler_gametocyte_microarray
    microarray = Microarray.find_by_description(Microarray::WINZELER_2005_GAMETOCYTE_NAME)
    raise unless microarray
    
    code = CodingRegion.f('PFE0065w')
    timepoints = code.microarray_measurements.all(:joins => :microarray_timepoint,
      :conditions => "microarray_timepoints.microarray_id = #{microarray.id}"
    )
    raise unless timepoints.length == 39
    
    # test Panova
    points = timepoints.select{|t| t.microarray_timepoint.name == MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_PANOVA}
    raise unless points.length == 1
    raise unless 1.12E-125 == points[0].measurement
    
    # test Early Ring S
    points = timepoints.select{|t| t.microarray_timepoint.name == MicroarrayTimepoint::WINZELER_2003_EARLY_RING_SORBITOL}
    raise unless points.length == 1
    raise unless 8331 == points[0].measurement
    
    # test 3D7 Early Day 2
    points = timepoints.select{|t| t.microarray_timepoint.name == MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_EARLY_DAY_2}
    raise unless points.length == 1
    raise unless 1163 == points[0].measurement
    
    # test NF54 Day 13
    points = timepoints.select{|t| t.microarray_timepoint.name == MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_13}
    raise unless points.length == 1
    raise unless 48 == points[0].measurement
    
    
    # Test random one from the middle
    code = CodingRegion.f('PF11_0482')
    timepoints = code.microarray_measurements.all(:joins => :microarray_timepoint,
      :conditions => "microarray_timepoints.microarray_id = #{microarray.id}"
    )
    raise unless timepoints.length == 39
    points = timepoints.select{|t| t.microarray_timepoint.name == MicroarrayTimepoint::WINZELER_2003_EARLY_SCHIZONT_SORBITOL}
    raise unless points.length == 1
    raise unless 137 == points[0].measurement
    
    # Test very last one
    code = CodingRegion.f('PFI1220w')
    timepoints = code.microarray_measurements.all(:joins => :microarray_timepoint,
      :conditions => "microarray_timepoints.microarray_id = #{microarray.id}"
    )
    raise unless timepoints.length == 39
    points = timepoints.select{|t| t.microarray_timepoint.name == MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_13}
    raise unless points.length == 1
    raise unless 339 == points[0].measurement
        
    # In PlasmoDB 5.5 upload, there is 77 that do not have any associated data, and 5159 entries in the spreadsheet
    # This means there must be 39*(5159-77) entries uploaded to this microarray
    # Actually, that's not technically correct since they aren't all in the same microarray, but eh to that
    count = MicroarrayMeasurement.count(:joins => :microarray_timepoint, :conditions => "microarray_id=#{microarray.id}")
    expected = 39*(5159-77)
    raise Exception, "Incorrect number of measurements found: #{count}, expected #{expected}" unless count == expected
  end
  
  def voss_nuclear_proteome_2008_upload
    raise unless PlasmodbGeneList.find_all_by_description(PlasmodbGeneList::VOSS_NUCLEAR_PROTEOME_OCTOBER_2008).coding_regions.count == 1091
  end
  
  def percentiles
    nums = []
    CodingRegion.falciparum(:joins => :microarray_measurements).all.each do |code|
      r = code.microarray_measurements.timepoint_names([MicroarrayTimepoint::WINZELER_2003_EARLY_RING_SORBITOL].flatten).all.reach.percentile.average
      next if r.nil?
      puts r
      nums.push r
    end
    puts "Average: #{nums.average}"
  end

  def neafsey
    raise unless CodingRegion.f('PFC0485w').neafsey_synonymous_snp.value == 1
    raise unless CodingRegion.f('MAL7P1.227').neafsey_synonymous_snp.value == 2
    raise unless CodingRegion.f('MAL7P1.227').neafsey_non_synonymous_snp.value == 2
    
    # ben@uyen:~/phd/gnr$ grep 'Non-Synon' /home/ben/phd/data/falciparum/polymorphism/SNP/NeafseySchaffner2008-gb-2008-9-12-r171-s5.csv |awk '{print $5}' |uniq |wc -l
    # 441
    raise unless NeafseyNonSynonymousSnp.count == 441
    # ben@uyen:~/phd/gnr$ grep 'Synon' /home/ben/phd/data/falciparum/polymorphism/SNP/NeafseySchaffner2008-gb-2008-9-12-r171-s5.csv |grep -v 'Non-Syn' |awk '{print $5}' |uniq |wc -l
    # 257
    raise unless NeafseySynonymousSnp.count == 257
    # ben@uyen:~/phd/gnr$ grep 'Intronic' /home/ben/phd/data/falciparum/polymorphism/SNP/NeafseySchaffner2008-gb-2008-9-12-r171-s5.csv |grep -v 'Non-Syn' |awk '{print $5}' |uniq |wc -l
    # 36
    raise unless NeafseyIntronicSnp.count == 36
  end
  
  def mu
    raise if CodingRegion.ff('PFA0005w').mu_pi
    raise unless CodingRegion.ff('PFA0120c').mu_bp_surveyed.value == 523.0
    raise unless CodingRegion.ff('PFA0120c').mu_synonymous_snp.value == 0.0
    raise unless CodingRegion.ff('PFA0120c').mu_synonymous_snp.value == 0.0
    
    raise unless CodingRegion.ff('PFB0085c').mu_bp_surveyed.value == 1229.0
    raise unless CodingRegion.ff('PFB0085c').mu_synonymous_snp.value == 1.0
    raise unless CodingRegion.ff('PFB0085c').mu_non_synonymous_snp.value == 1.0
    raise unless CodingRegion.ff('PFB0085c').mu_non_coding_snp.value == 0.0
    raise unless CodingRegion.ff('PFB0085c').mu_theta.value == 0.000781
    raise unless CodingRegion.ff('PFB0085c').mu_pi.value == 0.001899
    
    raise unless CodingRegion.ff('PFB0535w').mu_non_coding_snp.value == 2.0
    
    #    ben@ben:~/phd/gnr$ scr Script.new.upload_mu_et_al_snps
    #Couldn't find PFA0395c
    #Couldn't find PFD0510c
    #Couldn't find PFD0965w
    #Couldn't find MAL6P1.234
    #Couldn't find chr7.rRNA-1-28s
    #
    #ben@ben:~/phd/data/falciparum/polymorphism/Mu2007$ awk '{print $1}' ng1924-S5.csv |grep -v Gene |grep . |wc -l
    #7399
    raise unless MuSynonymousSnp.count != 7399-5
    raise unless MuTheta.count != 7399-5
  end
  
  def jiang_chromosomal_features
    scaff1 = Scaffold.find_falciparum_chromosome(1)
    raise unless Jiang7G8TenKbBinSfpCount.find_all_by_scaffold_id_and_start(scaff1.id, 0).length == 1
    raise unless Jiang7G8TenKbBinSfpCount.find_by_scaffold_id_and_start(scaff1.id, 0).value == 69.0
    raise unless JiangDd2TenKbBinSfpCount.find_by_scaffold_id_and_start(scaff1.id, 0).value == 103.0
    raise unless JiangDd2TenKbBinSfpCount.find_by_scaffold_id_and_start(scaff1.id, 10000).value == 15.0
    
    scaff1 = Scaffold.find_falciparum_chromosome(12)
    raise unless JiangFCR3TenKbBinSfpCount.find_by_scaffold_id_and_start(scaff1.id, 20000).value == 383
    raise unless JiangFCR3TenKbBinSfpCount.find_by_scaffold_id_and_start(scaff1.id, 20000).stop == 29999
    
    # ben@uyen:~/phd/data/falciparum/polymorphism/Jiang2008$ cat *.csv |grep -v FCR |grep -v Additiona |wc -l
    # 2333
    raise unless JiangHB3TenKbBinSfpCount.count == 2333
  end
end
