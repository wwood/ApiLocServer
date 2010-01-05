# Methods used in the ApiLoc publication
class BScript
  def apiloc_stats
    puts "For each species, how many genes, publications"
    Species.apicomplexan.all(:order => 'name').each do |s|
      puts [
        s.name,
        s.number_or_proteins_localised_in_apiloc,
        s.number_or_publications_in_apiloc,
      ].join("\t")
    end
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
      'cele' => 'worm'
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
  def species_orthologue_folder; "#{PHD_DIR}/apiloc/species_orthologues2"; end

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

  def generate_apiloc_orthomcl_groups_for_inspection
    interestings = %w(hsap atha mmus dmel cele)

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
      paragraph = []
      worthwhile = false #don't print unless there is GO info for proteins of interest

      # ignore groups that have genes that we don't know about
      next if ogroup.orthomcl_genes.select{|g|
        interestings.include?(g.official_split[0])
      }.length == 0

      ogroup.orthomcl_genes.all.each do |orthomcl_gene|
        four = orthomcl_gene.official_split[0]

        # POssible to have many coding regions now - using all of them just together, though there is
        # probably one good one and other useless and IEA if anything annotated.
        orthomcl_gene.coding_regions.each do |code|

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
      
      puts paragraph.join("\n") if worthwhile
      puts
    end
  end

  def apiloc_go_localisation_conservation_groups_to_database
    FasterCSV.foreach("#{PHD_DIR}/apiloc/species_orthologues2/breakdown.manual.xls",
      :col_sep => "\t"
    ) do |row|
      next unless row[0] and row[0].length > 0
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
      ).save!
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
        h1.coding_regions.reach.coding_region_go_terms.cc.useful.count <=> 
          h2.coding_regions.reach.coding_region_go_terms.cc.useful.count
      end

      next unless max_human
      puts [
        l.conservation,
        max_human.coding_regions.first.string_id
      ].join("\t")
    end
  end
end