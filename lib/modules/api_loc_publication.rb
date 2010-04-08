require "zlib"
# Methods used in the ApiLoc publication
class BScript
  def apiloc_stats
    puts "For each species, how many genes, publications"
    total_proteins = 0
    total_publications = 0
    Species.apicomplexan.all(:order => 'name').each do |s|
      protein_count = s.number_or_proteins_localised_in_apiloc
      publication_count = s.number_or_publications_in_apiloc
      
      puts [
      s.name,
      protein_count,
      publication_count,
      ].join("\t")
      
      total_proteins += protein_count
      total_publications += publication_count
    end
    
    puts [
    'Total',
    total_proteins,
    total_publications
    ].join("\t")
  end
  
  def species_localisation_breakdown
    #    names = Localisation.all(:joins => :apiloc_top_level_localisation).reach.name.uniq.push(nil)
    #    print "species\t"
    #    puts names.join("\t")
    top_names = [
      'apical',
      'inner membrane complex',
      'merozoite surface',
      'parasite plasma membrane',
      'parasitophorous vacuole',
      'exported',
      'cytoplasm',
      'food vacuole',
      'mitochondrion',
      'apicoplast',
      'golgi',
      'endoplasmic reticulum',
      'other',
      'nucleus'
    ]
    
    interests = [
      'Plasmodium falciparum',
      'Toxoplasma gondii',
      'Plasmodium berghei',
      'Cryptosporidium parvum'
    ]
    puts [nil].push(interests).flatten.join("\t")
    
    top_names.each do |top_name|
      top = TopLevelLocalisation.find_by_name(top_name)
      print top_name
      
      interests.each do |name|
        s = Species.find_by_name(name)
        
        if top.name == 'other'
          count = 0
          CodingRegion.all(
            :select => 'distinct(coding_regions.id)',
            :joins => {:expression_contexts => {:localisation => :apiloc_top_level_localisation}},
            :conditions => ['top_level_localisation_id = ? and species_id = ?', top.id, s.id]
          ).each do |code|
            tops = code.expressed_localisations.reach.apiloc_top_level_localisation.flatten
            if tops.length == 1
              raise unless tops[0].name == 'other'
              count += 1
            end
          end
          print "\t#{count}"
        else
          count = CodingRegion.count(
            :select => 'distinct(coding_regions.id)',
            :joins => {:expression_contexts => {:localisation => :apiloc_top_level_localisation}},
            :conditions => ['top_level_localisation_id = ? and species_id = ?', top.id, s.id]
          )
          print "\t#{count}"
        end
      end
      
      puts
    end
  end
  
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
  
  def distribution_of_falciparum_hits_given_toxo
    toxo_only = []
    falc_only = []
    no_hits = []
    hits_not_localised = []
    falc_and_toxo = []
    
    # why the hell doesn't bioruby do this for me?
    falciparum_blasts = {}
    toxo_blasts = {}
    
    
    # convert the blast file as it currently exists into a hash of plasmodb => blast_hits
    Bio::Blast::Report.new(
                           File.open("#{PHD_DIR}/apiloc/experiments/falciparum_vs_toxo_blast/falciparum_v_toxo.1e-5.tab.out",'r').read,
      :tab
    ).iterations[0].hits.each do |hit|
      q = hit.query_id.gsub(/.*\|/,'')
      s = hit.definition.gsub(/.*\|/,'')
      falciparum_blasts[q] ||= []
      falciparum_blasts[q].push s
    end
    Bio::Blast::Report.new(
                           File.open("#{PHD_DIR}/apiloc/experiments/falciparum_vs_toxo_blast/toxo_v_falciparum.1e-5.tab.out",'r').read,
      :tab
    ).iterations[0].hits.each do |hit|
      q = hit.query_id.gsub(/.*\|/,'')
      s = hit.definition.gsub(/.*\|/,'')
      toxo_blasts[q] ||= []
      toxo_blasts[q].push s
    end
    
    
    # On average, how many hits does the toxo gene have to falciparum given
    # arbitrary 1e-5 cutoff?
    #    File.open("#{PHD_DIR}/apiloc/experiments/falciparum_to_toxo_how_many_hits.csv",'w') do |how_many_hits|
    #      File.open("#{PHD_DIR}/apiloc/experiments/falciparum_to_toxo_best_evalue.csv",'w') do |best_evalue|
    File.open("#{PHD_DIR}/apiloc/experiments/falciparum_to_toxo_best_evalue.csv", 'w') do |loc_comparison|
      blast_hits = CodingRegion.s(Species::FALCIPARUM_NAME).all(
        :joins => :amino_acid_sequence,
        :include => {:expression_contexts => :localisation}
      #      :limit => 10,
      #      :conditions => ['string_id = ?', 'PF13_0280']
      ).collect do |falciparum|
        # does this falciparum have a hit?
        
        
        # compare localisation of the falciparum and toxo protein
        falciparum_locs = falciparum.expression_contexts.reach.localisation.reject{|l| l.nil?}
        
        toxo_ids = falciparum_blasts[falciparum.string_id]
        toxo_ids ||= []
        toxos = toxo_ids.collect do |toxo_id|
          t = CodingRegion.find_by_name_or_alternate_and_species(toxo_id, Species::TOXOPLASMA_GONDII)
          raise unless t
          t
        end
        toxo_locs = toxos.collect {|toxo|
          toxo.expression_contexts.reach.localisation.retract
        }.flatten.reject{|l| l.nil?}
        
        if toxos.length > 0
          # protein localised in falciparum but not in toxo
          if !falciparum_locs.empty? and !toxo_locs.empty?
            loc_comparison.puts [
            falciparum.string_id,
            falciparum.annotation.annotation,
            falciparum.localisation_english
            ].join("\t")
            toxos.each do |toxo|
              loc_comparison.puts [
              toxo.string_id,
              toxo.annotation.annotation,
              toxo.localisation_english
              ].join("\t")
            end
            loc_comparison.puts
            falc_and_toxo.push [falciparum, toxos]
          end
          
          # stats about how well the protein is localised
          if toxo_locs.empty? and !falciparum_locs.empty?
            falc_only.push [falciparum, toxos]
          end
          if !toxo_locs.empty? and falciparum_locs.empty?
            toxo_only.push [falciparum, toxos]
          end
          
          if toxo_locs.empty? and falciparum_locs.empty?
            hits_not_localised.push falciparum.string_id
          end
        else
          no_hits.push falciparum.string_id
        end
      end
    end
    
    puts "How many genes are localised in toxo and falciparum?"
    puts falc_and_toxo.length
    puts
    
    puts "How many genes are localised in toxo but not in falciparum?"
    puts toxo_only.length
    puts
    
    puts "How many genes are localised in falciparum but not in toxo?"
    puts falc_only.length
    puts
    
    puts "How many falciparum genes have no toxo hit?"
    puts no_hits.length
    puts
    
    puts "How many have hits but are not localised?"
    puts hits_not_localised.length
    puts
  end
  
  def tgo_v_pfa_crossover_count
    both = OrthomclGroup.all_overlapping_groups(%w(tgo pfa))
    pfa = OrthomclGroup.all_overlapping_groups(%w(pfa))
    tgo = OrthomclGroup.all_overlapping_groups(%w(tgo))
    
    both_genes_pfa = both.collect{|b| b.orthomcl_genes.codes(%w(pfa)).count(:select => 'distinct(orthomcl_genes.id)')}.sum
    both_genes_tgo = both.collect{|b| b.orthomcl_genes.codes(%w(tgo)).count(:select => 'distinct(orthomcl_genes.id)')}.sum
    pfa_genes = CodingRegion.s(Species::FALCIPARUM).count(:joins => :amino_acid_sequence)
    tgo_genes = CodingRegion.s(Species::TOXOPLASMA_GONDII).count(:joins => :amino_acid_sequence)
    
    puts "How many OrthoMCL groups have at least one protein in pfa and tgo?"
    puts "#{both.length} groups, #{both_genes_pfa} falciparum genes, #{both_genes_tgo} toxo genes"
    puts
    
    puts "How many OrthoMCL groups are specific to falciparum?"
    puts "#{pfa.length - both.length} groups, #{pfa_genes - both_genes_pfa} genes"
    puts
    
    puts "How many OrthoMCL groups are specific to toxo?"
    puts "#{tgo.length - both.length} groups, #{tgo_genes - both_genes_tgo} genes"
    puts
    
  end
  
  
  # Print out a fasta file of all the sequences that are in apiloc.
  # If a block is given it takes each coding region so that it can be transformed
  # into a fasta sequence header as in AminiAcidSequence#fasta, otherwise
  # a default is used.
  def apiloc_fasta(io = $stdout)
    CodingRegion.all(
      :joins => :expression_contexts
    ).uniq.each do |code|
      if code.amino_acid_sequence and code.amino_acid_sequence.sequence.length > 0
        io.print ">"
        if block_given?
          io.puts yield(code)
        else
          io.puts [
          code.species.name,
          code.string_id,
          code.annotation ? code.annotation.annotation : nil
          ].join(' | ')
        end
        io.puts code.amino_acid_sequence.sequence
      else
        $stderr.puts "Couldn't find amino acid sequence for #{code.string_id}/#{code.id}"
      end
    end
  end
  
  def apiloc_mapping_orthomcl_v3
    # Starting with falciparum, how many genes have localised orthologues?
    CodingRegion.falciparum.all(
      :joins => {:expression_contexts => :localisation},
      :select => 'distinct(coding_regions.*)'
    ).each do |code|
      next if ["PF14_0078",'PF13_0011'].include?(code.string_id) #fair enough there is no orthomcl for this - just the way v3 is.
      
      # Is this in orthomcl
      ogene = nil
      begin
        ogene = code.single_orthomcl
      rescue CodingRegion::UnexpectedOrthomclGeneCount
        next
      end
      if ogene
        groups = ogene.orthomcl_groups
        raise unless groups.length == 1
        group = groups[0]
        others = group.orthomcl_genes.apicomplexan.all.reject{|r| r.id==ogene.id}
        next if others.empty?
        
        orthologues = CodingRegion.all(
          :joins => [
        {:expression_contexts => :localisation},
            :orthomcl_genes,
        ],
          :conditions => "orthomcl_genes.id in (#{others.collect{|o|o.id}.join(',')})",
          :select => 'distinct(coding_regions.*)'
        )
        if orthologues.empty?
          $stderr.puts "Nothing useful found for #{code.names.join(', ')}"
        else
          # output the whole group, including localisations where known
          puts [
          code.string_id,
          code.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.join(', '),
          code.annotation.annotation,
          code.localisation_english
          ].join("\t")
          group.orthomcl_genes.apicomplexan.all.each do |oge|
            next if %w(cmur chom).include?(oge.official_split[0])
            c = nil
            if oge.official_split[1] == 'TGGT1_036620' #stupid v3
              c = CodingRegion.find_by_name_or_alternate("TGME49_084810")
            else
              c = oge.single_code!
            end
            if c.nil?
              # if no coding region is returned, then don't complain too much,
              # but I will check these manually later
              puts oge.orthomcl_name
            else
              next if c.id == code.id #don't duplicate the query
              print c.string_id
              puts [
              nil,
              c.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.join(', '),
              c.annotation.annotation,
              c.localisation_english
              ].join("\t")
            end
          end
          puts
        end
      end
    end
  end
  
  # Get all of the sequences that are recorded in ApiLoc and put them into
  # a blast file where the hits can be identified using a -m 8 blast output
  def create_apiloc_m8_ready_blast_database
    File.open('/tmp/apiloc_m8_ready.protein.fa','w') do |file|
      BScript.new.apiloc_fasta(file) do |code|
        "#{code.species.name.gsub(' ','_')}|#{code.string_id}"
      end
    end
    
    Dir.chdir('/tmp') do
      `formatdb -i apiloc_m8_ready.protein.fa`
      
      %w(
        apiloc_m8_ready.protein.fa
        apiloc_m8_ready.protein.fa.phr
        apiloc_m8_ready.protein.fa.pin
        apiloc_m8_ready.protein.fa.psq
      ).each do |filename|
        `mv #{filename} /blastdb`
      end
    end
  end
  
  def blast_genomes_against_apiloc
    
  end
  
  # Taking all the falciparum proteins, where are the orthologues localised?
  def orthomcl_localisation_annotations
    CodingRegion.falciparum.all(
      :joins => :expressed_localisations,
      :limit => 20,
      :select => 'distinct(coding_regions.*)'
    ).each do |code|
      begin
        falciparum_orthomcl_gene = code.single_orthomcl
        
        puts [
        code.string_id,
        code.annotation.annotation,
        falciparum_orthomcl_gene.official_group.orthomcl_genes.code('scer').all.collect { |sceg|
          sceg.single_code.coding_region_go_terms.useful.all.reach.go_term.term.join(', ')
        }.join(' | ')
        ].join("\t")
      rescue CodingRegion::UnexpectedOrthomclGeneCount => e
        $stderr.puts "Couldn't map #{code.string_id}/#{code.annotation.annotation} to orthomcl"
      end
    end
  end
  
  def apiloc_relevant_human_genes
    
  end
  
  def upload_apiloc_relevant_go_terms
    require 'ensembl'
    
    # create the species and dummy scaffolds, genes, etc.
    # yeast should already be uploaded
    #    yeast = Species.find_or_create_by_name_and_orthomcl_three_letter(Species::YEAST_NAME, 'scer')
    #    human = Species.find_or_create_by_name_and_orthomcl_three_letter(Species::HUMAN_NAME, 'hsap')
    #    mouse = Species.find_or_create_by_name_and_orthomcl_three_letter(Species::MOUSE_NAME, 'mmus')
    #    mouse = Species.find_or_create_by_name_and_orthomcl_three_letter(Species::ELEGANS_NAME, 'cele')
    gene = Gene.new.create_dummy('apiloc conservation dummy gene for multiple species')
    ensembl_uniprot_db = ExternalDb.find_by_db_name("Uniprot/SWISSPROT")
    
    # for each human, mouse, yeast gene in a group with a localised apicomplexan
    # gene, get the go terms from Ensembl so we can start to compare them later
    #    OrthomclGroup.all(
    ogroup = OrthomclGroup.first(
      :joins => {
        :orthomcl_gene_orthomcl_group_orthomcl_runs => [
          :orthomcl_run,
      {:orthomcl_gene => {:coding_regions => :expressed_localisations}}
      ]
    },
      :conditions => {
        :orthomcl_runs => {:name => OrthomclRun::ORTHOMCL_OFFICIAL_VERSION_3_NAME}
    }
    )
    #    ).each do |ogroup|
    ogroup.orthomcl_genes.codes(%w(hsap mmus scer cele)).all.each do |orthomcl_gene|
      ensembl = OrthomclGene.new.official_split[1]
      
      # fetch the uniprot ID from Ensembl
      ensp = Ensembl::Core::Translation.find_by_stable_id(ensembl)
      unless ensp
        $stderr.puts "Couldn't find ensembl gene to match #{ensembl}, skipping"
        next
      end
      # extract the uniprot id
      uniprots = ensp.xrefs.select{|x| ensembl_uniprot_db.id == x.id}.collect{|x| x.db_primaryacc}.uniq
      uniprot = uniprots[0]
      unless uniprots.length == 1
        $stderr.puts "Unexpected number of uniprot IDs found: #{uniprots.inspect}"
        next if uniprots.empty?
      end
      
      # wget the uniprot txt file entry
      filename = "/tmp/uniprot#{uniprot}.txt"
      `wget http://www.uniprot.org/#{uniprot}.txt -O #{filename}`
      
      # parse the uniprot entry
      bio = Bio::Uniprot.new(File.open(filename).read)
      p bio
      
      # create the gene
      # find the GO term that I've annnotated, otherwise add a new one, which
      # will need to be filled in with the term
      # add the relevant GO term and evidence code
      #    end
    end
  end
  
  # not realyl working - too slow for me.
  def map_using_uniprot_mapper
    #    require 'uni_prot_i_d_mapping_selected'
    
    #    mapper = Bio::UniProtIDMappingSelected.new
    #    ogroup =
    OrthomclGroup.all(
                      #      :limit => 5,
      :joins => {
        :orthomcl_gene_orthomcl_group_orthomcl_runs => [
          :orthomcl_run,
      {:orthomcl_gene => {:coding_regions => :expressed_localisations}}
      ]
    },
      :conditions => {
        :orthomcl_runs => {:name => OrthomclRun::ORTHOMCL_OFFICIAL_VERSION_3_NAME}
    }
    #    )
    ).each do |ogroup|
      ogroup.orthomcl_genes.codes(%w(mmus)).all.each do |orthomcl_gene|
        ensembl = orthomcl_gene.official_split[1]
        puts ensembl
        #        mapped = mapper.find_by_ensembl_protein_id(ensembl)
        #        p mapped
      end
    end
  end
  
  def generate_biomart_to_go_input
    {
      'hsap' => 'human',
      'mmus' => 'mouse',
      'atha' => 'arabidopsis',
      'dmel' => 'fly',
      'cele' => 'worm',
      'scer' => 'yeast',
      'crei' => 'chlamydomonas',
      'tthe' => 'tetrahymena',
    }.each do |code, name|
      $stderr.puts name
      out = File.open("#{species_orthologue_folder}/#{name}.txt",'w')
      OrthomclGroup.all(
        :joins => {
          :orthomcl_gene_orthomcl_group_orthomcl_runs => [
            :orthomcl_run,
        {:orthomcl_gene => {:coding_regions => :expressed_localisations}}
        ]
      },
        :conditions => {
          :orthomcl_runs => {:name => OrthomclRun::ORTHOMCL_OFFICIAL_VERSION_3_NAME}
      }
      ).uniq.each do |ogroup|
        ogroup.orthomcl_genes.code(code).all.each do |orthomcl_gene|
          ensembl = orthomcl_gene.official_split[1]
          out.puts ensembl
        end
      end
    end
  end
  
  # \
  def species_orthologue_folder; "#{PHD_DIR}/apiloc/species_orthologues3"; end
  
  # all the methods required to get from the biomart and uniprot
  # id to GO term mappings to a spreadsheet that can be inspected for the
  # localisations required.
  def apiloc_gathered_output_to_generated_spreadsheet_for_inspection
    upload_apiloc_ensembl_go_terms
    upload_apiloc_uniprot_go_terms
    upload_apiloc_uniprot_mappings
    upload_apiloc_flybase_mappings
    # for some reason a single refseq sequence can be linked to multiple uniprot sequences,
    # which is stupid but something I'll have to live with
    OrthomclGene.new.link_orthomcl_and_coding_regions(%w(atha), :accept_multiple_coding_regions=>true)
    OrthomclGene.new.link_orthomcl_and_coding_regions(%w(hsap mmus dmel cele))
    generate_apiloc_orthomcl_groups_for_inspection
  end
  
  def upload_apiloc_ensembl_go_terms
    {
      'human' => Species::HUMAN_NAME,
      'mouse' => Species::MOUSE_NAME,
    }.each do |this_name, proper_name|
      $stderr.puts this_name
      FasterCSV.foreach("#{species_orthologue_folder}/biomart_results/#{this_name}.csv",
        :col_sep => "\t",
        :headers => true
      ) do |row|
        protein_name = row['Ensembl Protein ID']
        go_id = row['GO Term Accession']
        evidence = row['GO Term Evidence Code']
        
        next if go_id.nil? #ignore empty columns
        
        code = CodingRegion.find_or_create_dummy(protein_name, proper_name)
        go = GoTerm.find_by_go_identifier_or_alternate go_id
        unless go
          $stderr.puts "Couldn't find GO id #{go_id}"
          next
        end
        CodingRegionGoTerm.find_or_create_by_coding_region_id_and_go_term_id_and_evidence_code(
                                                                                               code.id, go.id, evidence
        ) or raise
      end
    end
  end
  
  def upload_apiloc_uniprot_go_terms
    {
      'arabidopsis' => Species::ARABIDOPSIS_NAME,
      'worm' => Species::ELEGANS_NAME,
      'fly' => Species::DROSOPHILA_NAME
    }.each do |this_name, proper_name|
      File.open("#{species_orthologue_folder}/uniprot_results/#{this_name}.uniprot.txt").read.split("//\n").each do |uniprot|
        u = Bio::UniProt.new(uniprot)
        
        axes = u.ac
        protein_name = axes[0]
        raise unless protein_name
        code = CodingRegion.find_or_create_dummy(protein_name, proper_name)
        
        protein_alternate_names = axes[1..(axes.length-1)].no_nils
        protein_alternate_names.each do |name|
          CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(
                                                                                    code.id, name
          ) or raise
        end
        
        goes = u.dr["GO"]
        next if goes.nil? #no go terms associated
        
        goes.each do |go_array|
          go_id = go_array[0]
          evidence_almost = go_array[2]
          evidence = nil
          if (matches = evidence_almost.match(/^([A-Z]{2,3})\:.*$/))
            evidence = matches[1]
          end
          
          # error checking
          if evidence.nil?
            raise Exception, "No evidence code found in #{go_array.inspect} from #{evidence_almost}!"
          end
          
          
          go = GoTerm.find_by_go_identifier_or_alternate go_id
          unless go
            $stderr.puts "Couldn't find GO id #{go_id}"
            next
          end
          
          CodingRegionGoTerm.find_or_create_by_coding_region_id_and_go_term_id_and_evidence_code(
                                                                                                 code.id, go.id, evidence
          ).save!
        end
      end
    end
  end
  
  def upload_apiloc_uniprot_mappings
    {
      'arabidopsis' => Species::ARABIDOPSIS_NAME,
      'worm' => Species::ELEGANS_NAME,
      'fly' => Species::DROSOPHILA_NAME
    }.each do |this_name, proper_name|
      
      
      FasterCSV.foreach("#{species_orthologue_folder}/uniprot_results/#{this_name}.mapping.tab",
        :col_sep => "\t", :headers => true
      ) do |row|
        code = CodingRegion.fs(row[1], proper_name) or raise Exception, "Don't know #{row[1]}"
        CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(
                                                                                  code.id, row[0]
        )
      end
      
    end
  end
  
  # Drosophila won't match well to orthomcl because orthomcl uses protein IDs whereas
  # uniprot uses gene ids.
  # This file was created by using the (useful and working) ID converter in flybase
  def upload_apiloc_flybase_mappings
    FasterCSV.foreach("#{species_orthologue_folder}/uniprot_results/flybase.mapping.tab",
      :col_sep => "\t"
    ) do |row|
      next if row[1] == 'unknown ID' #ignore rubbish
      gene_id = row[3]
      next if gene_id == '-' # not sure what this is, but I'll ignore for the moment
      protein_id = row[1]
      
      code = CodingRegion.fs(gene_id, Species::DROSOPHILA_NAME)
      if code.nil?
        $stderr.puts "Couldn't find gene #{gene_id}, skipping"
        next
      end
      CodingRegionAlternateStringId.find_or_create_by_name_and_coding_region_id(
                                                                                protein_id, code.id
      )
    end
  end
  
  # Return a list of orthomcl groups that fulfil these conditions:
  # 1. It has a localised apicomplexan gene in it, as recorded by ApiLoc
  # 2. It has a localised non-apicomplexan gene in it, as recorded by GO CC IDA annotation
  def apiloc_orthomcl_groups_of_interest
    OrthomclGroup.all(
      :select => 'distinct(orthomcl_groups.*)',
      :joins => {
        :orthomcl_gene_orthomcl_group_orthomcl_runs => [
          :orthomcl_run,
      {:orthomcl_gene => {:coding_regions => [
      :expressed_localisations
          ]}}
      ]
    },
      :conditions => {
        :orthomcl_runs => {:name => OrthomclRun::ORTHOMCL_OFFICIAL_VERSION_3_NAME},
    }
    ).select do |ogroup|
      # only select those groups that have go terms annotated in non-apicomplexan species
      OrthomclGroup.count(
      :joins => {:coding_regions =>[
      :go_terms
        ]},
      :conditions => ['orthomcl_groups.id = ? and coding_region_go_terms.evidence_code = ? and go_terms.partition = ?',
      ogroup.id, 'IDA', GoTerm::CELLULAR_COMPONENT
      ]
      ) > 0
    end
  end
  
  def generate_apiloc_orthomcl_groups_for_inspection
    interestings = %w(hsap mmus scer drer osat crei atha dmel cele)
    
    apiloc_orthomcl_groups_of_interest.each do |ogroup|
      paragraph = []
      
      ogroup.orthomcl_genes.all.each do |orthomcl_gene|
        four = orthomcl_gene.official_split[0]
        
        # Possible to have many coding regions now - using all of them just together, though there is
        # probably one good one and other useless and IEA if anything annotated. Actually
        # not necesssarilly, due to strain problems.
        #
        # Only print out one entry for each OrthoMCL gene, to condense things
        # but that line should have all the (uniq) go terms associated
        orthomcl_gene.coding_regions.uniq.each do |code|
          
          if OrthomclGene::OFFICIAL_ORTHOMCL_APICOMPLEXAN_CODES.include?(four)
            paragraph.push [
            orthomcl_gene.orthomcl_name,
            code.nil? ? nil : code.annotation.annotation,
            code.nil? ? nil : code.localisation_english,
            ].join("\t")
          elsif interestings.include?(four)
            unless code.nil?
              goes = code.coding_region_go_terms.cc.useful.all
              unless goes.empty?
                worthwhile = true
                orig = orthomcl_gene.orthomcl_name
                goes.each do |code_go|
                  paragraph.push [
                  orig,
                  code_go.go_term.go_identifier,
                  code_go.go_term.term,
                  code_go.evidence_code
                  ].join("\t")
                  orig = ''
                end
              end
            end
          end
        end
      end
      
      puts paragraph.uniq.join("\n")
      puts
    end
  end
  
  def apiloc_go_localisation_conservation_groups_to_database
    #    FasterCSV.foreach("#{PHD_DIR}/apiloc/species_orthologues2/breakdown.manual.xls",
    #    FasterCSV.foreach("#{PHD_DIR}/apiloc/species_orthologues4/breakdown2.manual.csv",
    FasterCSV.foreach("#{PHD_DIR}/apiloc/species_orthologues4/breakdown3.manual.csv",
      :col_sep => "\t"
    ) do |row|
      # ignore lines that have nothing first or are the header line
      next unless row[0] and row[0].length > 0 and row[3]
      single = row[0]
      eg = row[1]
      
      full = OrthomclLocalisationConservations.single_letter_to_full_name(single)
      raise Exception, "Couldn't understand single letter '#{single}'" unless full
      
      # find the orthomcl group by using the gene in the first line (the example)
      ogene = OrthomclGene.official.find_by_orthomcl_name(eg)
      raise Exception, "Coun't find orthomcl gene '#{eg}' as expected" if ogene.nil?
      
      # create the record
      OrthomclLocalisationConservations.find_or_create_by_orthomcl_group_id_and_conservation(
                                                                                             ogene.official_group.id, full
      ).id
    end
  end
  
  def yes_vs_no_human_examples
    OrthomclLocalisationConservations.all.collect do |l|
      max_human = OrthomclGene.code('hsap').all(
        :joins =>[
      [:coding_regions => :go_terms],
          :orthomcl_gene_orthomcl_group_orthomcl_runs
      ],
        :conditions => {:orthomcl_gene_orthomcl_group_orthomcl_runs => {:orthomcl_group_id => l.orthomcl_group_id}}
      ).max do |h1, h2|
        counter = lambda {|h|
          CodingRegionGoTerm.cc.useful.count(
            :joins => {:coding_region => :orthomcl_genes},
            :conditions => {:orthomcl_genes => {:id => h.id}}
          )
        }
        counter.call(h1) <=> counter.call(h2)
      end
      
      next unless max_human
      puts [
      l.conservation,
      max_human.coding_regions.first.names.sort
      ].flatten.join("\t")
    end
  end
  
  def upload_uniprot_identifiers_for_ensembl_ids
    FasterCSV.foreach("#{species_orthologue_folder}/gostat/human_ensembl_uniprot_ids.txt",
      :col_sep => "\t", :headers => true
    ) do |row|
      ens = row['Ensembl Protein ID']
      uni = row['UniProt/SwissProt Accession']
      raise unless ens
      next unless uni
      code = CodingRegion.f(ens)
      raise unless code
      CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name_and_source(
                                                                                           code.id, uni, CodingRegionAlternateStringId::UNIPROT_SOURCE_NAME
      ) or raise
    end
  end
  
  def download_uniprot_data
    UNIPROT_SPECIES_ID_NAME_HASH.each do |taxon_id, species_name|
      # Download the data into the expected name
      Dir.chdir("#{DATA_DIR}/UniProt/knowledgebase") do
        unless File.exists?("#{species_name}.gz")
          cmd = "wget -O '#{species_name}.gz' 'http://www.uniprot.org/uniprot/?query=taxonomy%3a#{taxon_id}&compress=yes&format=txt'"
          p cmd
          `#{cmd}`
        end
      end
    end
  end
  
  UNIPROT_SPECIES_ID_NAME_HASH = {
    9606 => Species::HUMAN_NAME,
    4932 => Species::YEAST_NAME,
    312017 => Species::TETRAHYMENA_NAME,
    7227 => Species::DROSOPHILA_NAME,
    3702 => Species::ARABIDOPSIS_NAME,
    6239 => Species::ELEGANS_NAME,
    10090 => Species::MOUSE_NAME,
    3055 => Species::CHLAMYDOMONAS_NAME,
    7955 => Species::DANIO_RERIO_NAME,
    4530 => Species::RICE_NAME,
    
    # species below have no non-IEA gene ontology terms so are a waste of time
    #    4087 => Species::TOBACCO_NAME,
    #    70448 => Species::PLANKTON_NAME,
    #    3218 => Species::MOSS_NAME,
    #    3988 => Species::CASTOR_BEAN_NAME
  }
  APILOC_UNIPROT_SPECIES_NAMES = UNIPROT_SPECIES_ID_NAME_HASH.values
  
  # Given that the species of interest are already downloaded from uniprot
  # (using download_uniprot_data for instance), upload this data
  # to the database, including GO terms. Other things need to be run afterwards
  # to be able to link to OrthoMCL.
  #
  # This method could be more DRY - UniProtIterator could replace
  # much of the code here. But eh for the moment.
  def uniprot_to_database
    APILOC_UNIPROT_SPECIES_NAMES.each do |species_name|
      count = 0
      current_uniprot_string = ''
      complete_filename = "#{DATA_DIR}/UniProt/knowledgebase/#{species_name}.gz"
      
      # Convert the whole gzip in to a smaller one, so parsing is faster:
      filename = "#{DATA_DIR}/UniProt/knowledgebase/#{species_name}_reduced"
      cmd = "zcat '#{complete_filename}' |egrep '^(AC|DR   GO|//)' >'#{filename}'"
      `#{cmd}`
      
      dummy_gene = Gene.find_or_create_dummy(species_name)
      progress = ProgressBar.new(species_name, `grep '^//' '#{filename}' |wc -l`.to_i)
      File.foreach(filename) do |line|
        if line == "//\n"
          count += 1
          progress.inc
          #current uniprot is finished - upload it
          #puts current_uniprot_string
          u = Bio::UniProt.new(current_uniprot_string)
          
          # Upload the UniProt name as the
          axes = u.ac
          
          protein_name = axes[0]
          raise unless protein_name
          code = CodingRegion.find_or_create_by_gene_id_and_string_id(
                                                                      dummy_gene.id,
                                                                      protein_name
          )
          raise unless code.save!
          
          protein_alternate_names = axes.no_nils
          protein_alternate_names.each do |name|
            CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name_and_source(
                                                                                                 code.id, name, 'UniProt'
            ) or raise
          end
          
          goes = u.dr["GO"]
          goes ||= [] #no go terms associated - best to still make it to the end of the method, because it is too complex here for such hackery
          
          goes.each do |go_array|
            go_id = go_array[0]
            evidence_almost = go_array[2]
            evidence = nil
            if (matches = evidence_almost.match(/^([A-Z]{2,3})\:.*$/))
              evidence = matches[1]
            end
            
            # error checking
            if evidence.nil?
              raise Exception, "No evidence code found in #{go_array.inspect} from #{evidence_almost}!"
            end
            
            
            go = GoTerm.find_by_go_identifier_or_alternate go_id
            if go
              CodingRegionGoTerm.find_or_create_by_coding_region_id_and_go_term_id_and_evidence_code(
                                                                                                     code.id, go.id, evidence
              ).save!
            else
              $stderr.puts "Couldn't find GO id #{go_id}"
            end
          end
          
          current_uniprot_string = ''
        else
          current_uniprot_string += line
        end
      end
      progress.finish
      `rm '#{filename}'`
      $stderr.puts "Uploaded #{count} from #{species_name}, now there is #{CodingRegion.s(species_name).count} coding regions in #{species_name}."
    end
    #uploadin the last one not required because the last line is always
    # '//' already - making it easy.
  end
  
  def tetrahymena_orf_names_to_database
    species_name = Species::TETRAHYMENA_NAME
    current_uniprot_string = ''
    filename = "#{DATA_DIR}/UniProt/knowledgebase/#{Species::TETRAHYMENA_NAME}.gz"
    progress = ProgressBar.new(Species::TETRAHYMENA_NAME, `gunzip -c '#{filename}' |grep '^//' |wc -l`.to_i)
    Zlib::GzipReader.open(filename).each do |line|
      if line == "//\n"
        progress.inc
        
        #current uniprot is finished - upload it
        u = Bio::UniProt.new(current_uniprot_string)
        
        axes = u.ac
        protein_name = axes[0]
        raise unless protein_name
        code = CodingRegion.fs(protein_name, species_name)
        raise unless code
        
        u.gn[0][:orfs].each do |orfname|
          CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(
                                                                                    code.id, orfname
          )
        end
        
        current_uniprot_string = ''
      else
        current_uniprot_string += line
      end
    end
  end
  
  # upload aliases so that orthomcl entries can be linked to uniprot ones.
  # have to run tetrahymena_orf_names_to_database first though.
  def tetrahymena_gene_aliases_to_database
    bads = 0
    goods = 0
    filename = "#{DATA_DIR}/Tetrahymena thermophila/genome/TGD/Tt_ID_Mapping_File.txt"
    progress = ProgressBar.new(Species::TETRAHYMENA_NAME, `wc -l '#{filename}'`.to_i)
    FasterCSV.foreach(filename,
      :col_sep => "\t"
    ) do |row|
      progress.inc
      uniprot = row[0]
      orthomcl = row[1]
      code = CodingRegion.fs(uniprot, Species::TETRAHYMENA_NAME)
      if code.nil?
        bads +=1
      else
        goods += 1
        a = CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_source_and_name(
                                                                                                 code.id, 'TGD', orthomcl
        )
        raise unless a
      end
    end
    progress.finish
    $stderr.puts "Found #{goods}, failed #{bads}"
  end
  
  def yeastgenome_ids_to_database
    species_name = Species::YEAST_NAME
    current_uniprot_string = ''
    filename = "#{DATA_DIR}/UniProt/knowledgebase/#{species_name}.gz"
    progress = ProgressBar.new(species_name, `gunzip -c '#{filename}' |grep '^//' |wc -l`.to_i)
    Zlib::GzipReader.open(filename).each do |line|
      if line == "//\n"
        progress.inc
        
        #current uniprot is finished - upload it
        u = Bio::UniProt.new(current_uniprot_string)
        
        axes = u.ac
        protein_name = axes[0]
        raise unless protein_name
        code = CodingRegion.fs(protein_name, species_name)
        raise unless code
        
        unless u.gn.empty?
          u.gn[0][:loci].each do |orfname|
            CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(
                                                                                      code.id, orfname
            )
          end
        end
        
        current_uniprot_string = ''
      else
        current_uniprot_string += line
      end
    end
    progress.finish
  end
  
  def elegans_wormbase_identifiers
    species_name = Species::ELEGANS_NAME
    current_uniprot_string = ''
    complete_filename = "#{DATA_DIR}/UniProt/knowledgebase/#{species_name}.gz"
    
    # Convert the whole gzip in to a smaller one, so parsing is faster:
    filename = "#{DATA_DIR}/UniProt/knowledgebase/#{species_name}_reduced"
    `zcat '#{complete_filename}' |egrep '^(AC|DR   WormBase|//)' >'#{filename}'`
    
    progress = ProgressBar.new(species_name, `grep '^//' '#{filename}' |wc -l`.to_i)
    File.foreach(filename) do |line|
      if line == "//\n"
        progress.inc
        
        u = Bio::UniProt.new(current_uniprot_string)
        
        code = CodingRegion.fs(u.ac[0], Species::ELEGANS_NAME)
        raise unless code
        
        # DR   WormBase; WBGene00000467; cep-1.
        ides = u.dr['WormBase']
        ides ||= []
        ides.flatten.each do |ident|
          a = CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name_and_source(
                                                                                                   code.id, ident, 'WormBase'
          )
          raise unless a.save!
        end
        
        current_uniprot_string = ''
      else
        current_uniprot_string += line
      end
    end
    `rm #{filename}`
  end
  
  def uniprot_ensembl_databases
    [
    Species::MOUSE_NAME,
    Species::HUMAN_NAME,
    Species::DANIO_RERIO_NAME,
    Species::DROSOPHILA_NAME
    ].each do |species_name|
      Bio::UniProtIterator.foreach("#{DATA_DIR}/UniProt/knowledgebase/#{species_name}.gz", 'DR   Ensembl') do |u|
        code = CodingRegion.fs(u.ac[0], species_name) or raise
        ens = u.dr['Ensembl']
        ens ||= []
        ens.flatten.each do |e|
          if e.match(/^ENS/) or (species_name == Species::DROSOPHILA_NAME and e.match(/^FBpp/))
            CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name_and_source(
                                                                                                 code.id, e, 'Ensembl'
            )
          end
        end
      end
    end
  end
  
  def uniprot_refseq_databases
    [
    Species::ARABIDOPSIS_NAME,
    Species::RICE_NAME
    ].each do |species_name|
      Bio::UniProtIterator.foreach("#{DATA_DIR}/UniProt/knowledgebase/#{species_name}.gz", 'DR   RefSeq') do |u|
        code = CodingRegion.fs(u.ac[0], species_name) or raise
        
        refseqs = u.dr['RefSeq']
        refseqs ||= []
        refseqs = refseqs.collect{|r| r[0]}
        refseqs.each do |r|
          r = r.gsub(/\..*/,'')
          
          CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name_and_source(
                                                                                               code.id, r, 'Refseq'
          )
        end
      end
    end
  end
  
  def chlamydomonas_link_to_orthomcl_ids
    species_name = Species::CHLAMYDOMONAS_NAME
    Bio::UniProtIterator.foreach("#{DATA_DIR}/UniProt/knowledgebase/#{species_name}.gz", 'GN') do |u|
      code = CodingRegion.fs(u.ac[0], species_name) or raise
      gn = u.gn
      unless gn.empty?
        orfs = gn.collect{|g| g[:orfs]}
        unless orfs.empty?
          orfs.flatten.each do |orf|
            o = 'CHLREDRAFT_168484' if orf == 'CHLRE_168484' #manual fix
            raise Exception, "Unexpected orf: #{orf}" unless orf.match(/^CHLREDRAFT_/) or orf.match(/^CHLRE_/)
            o = orf.gsub(/^CHLREDRAFT_/, '')
            o = o.gsub(/^CHLRE_/,'')
            
            CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name_and_source(
                                                                                                 code.id, o, 'JGI'
            )
          end
        end
      end
    end
  end
  
  def uniprot_go_annotation_species_stats
    APILOC_UNIPROT_SPECIES_NAMES.each do |species_name|
      filename = "#{DATA_DIR}/UniProt/knowledgebase/#{species_name}.gz"
      if File.exists?(filename)
        puts [
        species_name,
        `zcat '#{filename}'|grep '  GO' |grep -v IEA |grep -v ISS |grep 'C\:' |wc -l`
        ].join("\t")
      else
        puts "Couldn't find #{species_name} uniprot file"
      end
    end
  end
  
  # Create a spreadsheet that encapsulates all of the localisation
  # information from apiloc, so that large scale analysis is simpler
  def create_apiloc_spreadsheet
    nil_char = nil #because I'm not sure how the joins will work
    
    microscopy_method_names = LocalisationAnnotation::POPULAR_MICROSCOPY_TYPE_NAME_SCOPE.keys.sort.reverse
    small_split_string = '#' #use when only 1 delimiter within a cell is needed
    big_split_string = ';' #use when 2 delimiters in one cell are needed
    orthomcl_split_char = '_'
    
    # Headings
    puts [
      'Species',
      'Gene ID',
      'Abbreviations',
      'Official Gene Annotation',
      'Localisation Summary',
      'Cellular Localisation',
      'Total Number of Cellular Localisations',
      'OrthoMCL Group Identifier',
      'Apicomplexan Orthologues with Recorded Localisation',
      'Apicomplexan Orthologues without Recorded Localisation',
      'Non-Apicomplexan Orthologues with IDA GO Cellular Component Annotation',
      'Consensus  Localisation of Orthology Group',
      'PubMed IDs of Publications with Localisation',
    microscopy_method_names,
      'All Localisation Methods Used',
      'Strains',
      'Gene Model Mapping Comments',
      'Quotes'
    ].flatten.join("\t")
    
    CodingRegion.all(:joins => :expression_contexts).uniq.each do |code|
      to_print = []
      organellar_locs = []
      
      # species
      to_print.push code.species.name
      
      #EuPath or GenBank ID
      to_print.push code.string_id
      
      #common names
      to_print.push code.literature_defined_names.join(small_split_string)
      
      #annotation
      a1 = code.annotation
      to_print.push(a1.nil? ? nil_char : a1.annotation)
      
      #full localisation description
      to_print.push code.localisation_english
      
      #'organellar' localisation (one per record,
      #if there is more repeat the whole record)
      #this might more sensibly be GO-oriented, but eh for the moment
      organellar_locs = code.topsa.uniq
      to_print.push nil_char
      
      # number of organellar localisations (ie number of records for this gene)
      to_print.push organellar_locs.length
      
      # OrthoMCL-related stuffs
      ogene = code.single_orthomcl!
      ogroup = (ogene.nil? ? nil : ogene.official_group)
      if ogroup.nil?
        5.times do
          to_print.push nil_char
        end
      else
        #orthomcl group
        to_print.push ogroup.orthomcl_name
        
        #localised apicomplexans in orthomcl group
        locked = CodingRegion.all(
          :joins => [
        {:orthomcl_genes => :orthomcl_groups},
            :expression_contexts
        ],
          :conditions => [
            'orthomcl_groups.id = ? and coding_regions.id != ?',
        ogroup.id, code.id
        ],
          :select => 'distinct(coding_regions.*)'
        )
        to_print.push "\"#{locked.collect{|a|
        [
        a.string_id,
        a.annotation.annotation,
        a.localisation_english
        ].join(small_split_string)
        }.join(big_split_string)}\""
        
        #unlocalised apicomplexans in orthomcl group
        to_print.push ogroup.orthomcl_genes.apicomplexan.all.reject {|a|
          a.coding_regions.select { |c|
            c.expressed_localisations.count > 0
          }.length > 0
        }.reach.orthomcl_name.join(', ').gsub('|',orthomcl_split_char)
        
        #non-apicomplexans with useful GO annotations in orthomcl group
        #species, orthomcl id, uniprot id(s), go annotations
        go_codes = CodingRegion.go_cc_usefully_termed.not_apicomplexan.all(
          :joins => {:orthomcl_genes => :orthomcl_groups},
          :conditions =>
        ["orthomcl_groups.id = ?", ogroup.id],
          :select => 'distinct(coding_regions.*)',
          :order => 'coding_regions.id'
        )
        to_print.push "\"#{go_codes.collect { |g|
        [
        g.species.name,
        g.orthomcl_genes.reach.orthomcl_name.join(', ').gsub('|',orthomcl_split_char),
        g.names.join(', '),
        g.coding_region_go_terms.useful.cc.all.reach.go_term.term.join(', ')
        ].join(small_split_string)
        }.join(big_split_string)}\""
        
        #    consensus of orthology group.
        to_print.push 'consensus - TODO'
      end
      contexts = code.expression_contexts
      annotations = code.localisation_annotations
      
      #    pubmed ids that localise the gene
      to_print.push contexts.reach.publication.definition.no_nils.uniq.join(small_split_string)
      
      # Categorise the microscopy methods
      microscopy_method_names.each do |name|
        scopes = 
        LocalisationAnnotation::POPULAR_MICROSCOPY_TYPE_NAME_SCOPE[name]
        
        done = LocalisationAnnotation
        scopes.each do |scope|
          done = done.send(scope)
        end
        if done.find_by_coding_region_id(code.id)
          to_print.push 'yes'
        else
          to_print.push 'no'
        end
      end
      
      #    localisation methods used (assume different methods never give different results for the same gene)
      to_print.push annotations.reach.microscopy_method.no_nils.uniq.join(small_split_string)
      #    strains
      to_print.push annotations.reach.strain.no_nils.uniq.join(small_split_string)
      #    mapping comments
      to_print.push annotations.reach.gene_mapping_comments.no_nils.uniq.join(small_split_string).gsub(/\"/,'')
      #    quotes
      # have to escape quote characters otherwise I get rows joined together
      to_print.push "\"#{annotations.reach.quote.uniq.join(small_split_string).gsub(/\"/,'\"')}\""
      
      if organellar_locs.empty?
        puts to_print.join("\t")
      else
        organellar_locs.each do |o|
          to_print[5] = o.name
          puts to_print.join("\t")
        end
      end
    end
  end
  
  # The big GOA file has not been 'redundancy reduced', a process which is buggy,
  # like the species level ones. Here I upload the species that I'm interested
  # in using that big file, not the small one
  def goa_all_species_to_database
    require 'gene_association'
    UNIPROT_SPECIES_ID_NAME_HASH.each do |species_id, species_name|
      bad_codes_count = 0
      bad_go_count = 0
      good_count = 0
      
      Bio::GzipAndFilterGeneAssociation.foreach(
        "#{DATA_DIR}/GOA/gene_association.goa_uniprot.gz",
        "\ttaxon:#{species_id}\t"
      ) do |go|
        name = go.primary_id
        code = CodingRegion.fs(name, species_name)
        unless code
          $stderr.puts "Couldn't find coding region #{name}"
          bad_codes_count += 1
          next
        end
        go_term = GoTerm.find_by_go_identifier(go.go_identifier)
        unless go_term
          $stderr.puts "Couldn't find coding region #{go.go_identifier}"
          bad_go_count += 1
          next
        end
        CodingRegionGoTerm.find_or_create_by_coding_region_id_and_go_term_id(
                                                                             code.id, go_term.id
        )
        good_count += 1
      end
      
      $stderr.puts "#{good_count} all good, failed to find #{bad_codes_count} coding regions and #{bad_go_count} go terms"
    end
  end
  
  def how_many_genes_have_dual_localisation?
    dual_loc_folder = "#{PHD_DIR}/apiloc/experiments/dual_localisations"
    raise unless File.exists?(dual_loc_folder)
    
    file = File.open(File.join(dual_loc_folder, 'duals.csv'),'w')
    
    Species.apicomplexan.each do |species|
      species_name = species.name
      codes = CodingRegion.s(species_name).all(
      :joins => :expressed_localisations,
      :select => 'distinct(coding_regions.*)'
      )
      counts = []
      nuc_aware_counts = []
      codes_per_count = []
      
      # write the results to the species-specific file
      
      
      codes.each do |code|
        next if code.string_id == CodingRegion::UNANNOTATED_CODING_REGIONS_DUMMY_GENE_NAME
        tops = TopLevelLocalisation.positive.all(
        :joins => {:apiloc_localisations => :expressed_coding_regions},
        :conditions => ['coding_regions.id = ?',code.id],
        :select => 'distinct(top_level_localisations.*)'
        )
        
        count = tops.length
        
        counts[count] ||= 0
        counts[count] += 1
        codes_per_count[count] ||= []
        codes_per_count[count].push code.string_id
        
        # nucleus and cytoplasm as a single localisation if both are included
        names = tops.reach.name.retract
        if names.include?('nucleus') and names.include?('cytoplasm')
          count -= 1
        end
        
        # Write out the coding regions to a file
        # gather the falciparum data
        og = code.single_orthomcl!
        fals = []
        if og and og.official_group
          fals = og.official_group.orthomcl_genes.code('pfal').all.collect do |ogene|
            ogene.single_code
          end
        end
        
        file.puts [
        code.species.name,
        code.string_id,
        code.names,
        count,
        code.compartments.join('|'),
        fals.reach.compartments.join('|'),
        fals.reach.localisation_english.join('|')
        ].join("\t")
        
        nuc_aware_counts[count] ||= 0
        nuc_aware_counts[count] += 1
      end
      puts species_name
      #      p codes_per_count
      p counts
      p nuc_aware_counts
    end
    file.close
  end
  
  def falciparum_test_prediction_by_orthology_to_non_apicomplexans
    bins = {}
    
    puts [
    'PlasmoDB ID',
    'Names',
    'Compartments',
    'Prediction',
    'Comparison',
    'Full P. falciparum Localisation Information'
    ].join("\t")
    
    CodingRegion.localised.falciparum.all(
    :select => 'distinct(coding_regions.*)'
    ).each do |code|
      # Unassigned genes just cause problems for orthomcl
      next if code.string_id == CodingRegion::NO_MATCHING_GENE_MODEL
      
      # When there is more than 1 P. falciparum protein in the group, then ignore this
      group = code.single_orthomcl.official_group
      if group.nil?
        $stderr.puts "#{code.names.join(', ')} has no OrthoMCL group, ignoring."
        next
      end
      num = group.orthomcl_genes.code(code.species.orthomcl_three_letter).count
      if num != 1
        $stderr.puts "#{code.names.join(', ')} has #{num} genes in its localisation group, ignoring"
        next
      end
      
      pred = code.apicomplexan_localisation_prediction_by_most_common_localisation
      next if pred.nil?
      goodness = code.compare_localisation_to_list(pred)
      
      puts [
      code.string_id,
      code.names.join('|'),
      code.compartments.join('|'),
      pred,
      goodness,
      code.localisation_english,
      ].join("\t")
      
      bins[goodness] ||= 0
      bins[goodness] += 1
    end
    
    # Print the results of the analysis
    p bins
  end
  
  # How conserved is localisation between the three branches of life with significant
  # data known about them?
  def conservation_of_eukaryotic_sub_cellular_localisation
    groups_to_counts = {}
    
    # For each orthomcl group that has IDA CC annotations
    OrthomclGroup.all(
    :select => 'distinct(orthomcl_groups.id)',
    :joins => {:orthomcl_genes => {:coding_regions => :go_terms}},
    :conditions => [
    'go_terms.aspect = ? and coding_region_go_terms.evidence_code = ?',
    GoTerm::CELLULAR_COMPONENT, 'IDA'
    ]
    ).each do |ortho_group|
      # For each non-Apicomplexan gene with localisation information in this group,
      # assign it compartments.
      # For each apicomplexan, get the compartments from apiloc
      # This is nicely abstracted already!
      # However, a single orthomcl gene can have multiple CodingRegion's associated.
      # Therefore each has to be analysed as an array, frustratingly.
      code_arrays = ortho_group.orthomcl_genes.uniq.reach.coding_regions.reject{|s| s.empty?}
      
      kingdom_codes = {}
      code_arrays.each do |code_array|
        next if code_array.blank?
        raise unless code_array.reach.species.name.uniq.length == 1 #they should all be the same, but why not check.
        species = code_array[0].species
        kingdom_codes[species.kingdom] ||= []
        kingdom_codes[species.kingdom].push code_array[0].string_id
      end
      
      code_locs = {}
      code_arrays.each do |code_array|
        name = code_array[0].string_id
        # the name shouldn't already exist, but sometimes does when 2 orthomcl
        # genes map to 1 coding region, like for instance hsap|ENSP00000251272
        # and hsap|ENSP00000375822. Therefore the raise below is commented out
        #raise Exception, "already found #{name} in #{code_locs.inspect} from #{code_array.inspect}" if code_locs[name]

        
        code_locs[name] = code_array.reach.compartments.flatten.uniq
      end
      
      # within the one kingdom, do they agree?
      kingdom_codes.each do |kingdom, codes|
        locs = codes.collect {|code|
          code_locs[code]
        }
        agreement = OntologyComparison.new.agreement_of_group(locs)
        groups_to_counts[[kingdom]] ||= {}
        groups_to_counts[[kingdom]][agreement] ||= 0
        groups_to_counts[[kingdom]][agreement] += 1
      end
      
      # within two kingdoms, do they agree?
      kingdom_codes.to_a.each_lower_triangular_matrix do |array1, array2|
        kingdom1 = array1[0]
        kingdom2 = array2[0]
        codes1 = array1[1]
        codes2 = array2[1]
        locs_for_all = [codes1,codes2].flatten.collect {|code| code_locs[code]}
        agreement = OntologyComparison.new.agreement_of_group(locs_for_all)
        
        index = [kingdom1, kingdom2]
        groups_to_counts[index] ||= {}
        groups_to_counts[index][agreement] ||= 0
        groups_to_counts[index][agreement] += 1
      end
      
      # within three kingdoms, do they agree?
      kingdom_codes.to_a.each_lower_triangular_3d_matrix do |a1, a2, a3|
        kingdom1 = a1[0]
        kingdom2 = a2[0]
        kingdom3 = a3[0]
        codes1 = a1[1]
        codes2 = a2[1]
        codes3 = a3[1]
        
        agreement = OntologyComparison.new.agreement_of_group([codes1,codes2,codes3].flatten.collect {|code| code_locs[code]})
        index = [kingdom1, kingdom2, kingdom3].sort
        groups_to_counts[index] ||= {}
        groups_to_counts[index][agreement] ||= 0
        groups_to_counts[index][agreement] += 1
      end
    end
    
    # print out the counts for each group of localisations
    p groups_to_counts
  end
end
