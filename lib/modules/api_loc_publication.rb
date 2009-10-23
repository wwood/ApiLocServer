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
end
