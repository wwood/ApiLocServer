

class BScript
  def voss_proteomics_spreadsheet
    
    apis = ApilocLocalisationTopLevelLocalisation.all.reach.top_level_localisation.uniq
    top_names = (%w(nucleus cytoplasm).push apis.reject{
      |top| [
          'nucleus',
          'cytoplasm',
      ].include?(top.name) or top.negative?
    }.reach.name.retract).flatten
    
    puts [
      'PlasmoDB',
    #          'Annotation',
    #              'Common names',
    #              'ApiLoc Localisation(s)',
    #              'ApiLoc Localisation(s) in Apicomplexan Orthologues',
    #      'PlasmoAP?',
    #        'Plasmit?',
    #      'SignalP?',
    #      #      'Transmembrane domain # (TMHMM)',
    #      'ExportPred score > 0?',
              'Agreement with nuclear simple manually inspected',
    #          'Agreement with ER simple',
    #    'Literature survey localisations',
    #          'Literature survey localisation description',
    #          'Literature survey nuclear agreement',
    #      'Literature survey ER agreement',
    #      'Localisation description of Orthologue(s)',
    #      'Metabolic Maps nuclear agreement simple',
    #      'Metabolic Maps ER agreement simple',
    #  'Included in Maurer\'s Cleft proteome?',
    #  'Included in Food Vacuole proteome?',
    #      top_names.collect{|n| "'#{n}' Agreement"},
    #      'In Lifecycle Proteomics at all?',
    #      'In Lifecycle Proteomics with at least 2 peptides'
    #    'Winzeler iRBC+Spz+Gam Affy Max Percentile'
    #'Winzeler ring expression percentage',
    #'Winzeler troph expression percentage',
    #'Winzeler schizont expression percentage',
    #'Length',
    #'Number of Hydrophilic Residues',
    ].flatten.join("\t")
    
    $stdin.each do |plasmodb_id|
      plasmodb_id.strip!
      code = CodingRegion.ff(plasmodb_id)
      print "#{plasmodb_id}\t"
      if code.nil?
        puts "Couldn't find this gene ID"
      else
        
        ## Determine nucleus agreement with manual annotation
        nucleus_agreement_simple = manually_correct_some_nucleus_agreements(code)
        nucleus_agreement_simple ||= code.agreement_with_top_level_localisation_simple(
                                                                                       TopLevelLocalisation.find_by_name('nucleus')
        )
        
        #        orth_str = nil
        #        begin
        #          localised_orths = code.localised_apicomplexan_orthomcl_orthologues
        #          if localised_orths.nil?
        #            orth_str = 'no entry in OrthoMCL v3'
        #          else
        #            orth_str = localised_orths.reject{
        #              |c| c.id == code.id
        #            }.reach.localisation_english.join(' | ')
        #          end
        #        rescue OrthomclGene::UnexpectedCodingRegionCount
        #          orth_str = 'multiple OrthoMCL orthologues found'
        #        end
        #        
        #        # second class the same thing
        #        lit_orth_str = nil
        #        begin
        #          localised_orths = code.localised_apicomplexan_orthomcl_orthologues(:by_literature => true)
        #          if localised_orths.nil?
        #            lit_orth_str = 'no entry in OrthoMCL v3'
        #          else
        #            lit_orth_str = localised_orths.reject{
        #              |c| c.id == code.id
        #            }.reach.localisation_english(:by_literature => true).join(' | ')
        #          end        rescue OrthomclGene::UnexpectedCodingRegionCount
        #          lit_orth_str = 'multiple OrthoMCL orthologues found'
        #        end
        
        #        maurers_proteome = ProteomicExperiment.find_by_name(ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_NAME)
        #        fv_proteome = ProteomicExperiment.find_by_name(ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_NAME)
        
        #        measurements = MicroarrayMeasurement.timepoint_name(MicroarrayTimepoint::WINZELER_IRBC_SPZ_GAM_MAX_PERCENTILE_TIMEPOINT).find_all_by_coding_region_id(
        #                                                                                                                                                              code.id
        #        ).reach.measurement.retract
        #        measure = measurements.empty? ? '' : measurements.average
        
        #        measure_ring = code.microarray_measurements.timepoint_names([
        #                                                                    MicroarrayTimepoint::WINZELER_2003_EARLY_RING_SORBITOL,
        #        MicroarrayTimepoint::WINZELER_2003_LATE_RING_SORBITOL,
        #        MicroarrayTimepoint::WINZELER_2003_EARLY_RING_TEMPERATURE,
        #        MicroarrayTimepoint::WINZELER_2003_LATE_RING_TEMPERATURE,
        #        ]
        #        ).all.reach.measurement.median
        #        measure_troph = code.microarray_measurements.timepoint_names([
        #                                                                     MicroarrayTimepoint::WINZELER_2003_EARLY_TROPHOZOITE_SORBITOL,
        #        MicroarrayTimepoint::WINZELER_2003_LATE_TROPHOZOITE_SORBITOL,
        #        MicroarrayTimepoint::WINZELER_2003_EARLY_TROPHOZOITE_TEMPERATURE,
        #        MicroarrayTimepoint::WINZELER_2003_LATE_TROPHOZOITE_TEMPERATURE
        #        ]
        #        ).all.reach.measurement.median
        #        measure_schizont = code.microarray_measurements.timepoint_names([
        #                                                                        MicroarrayTimepoint::WINZELER_2003_EARLY_SCHIZONT_SORBITOL,
        #        MicroarrayTimepoint::WINZELER_2003_LATE_SCHIZONT_SORBITOL,
        #        MicroarrayTimepoint::WINZELER_2003_EARLY_SCHIZONT_TEMPERATURE,
        #        MicroarrayTimepoint::WINZELER_2003_LATE_SCHIZONT_TEMPERATURE,
        #        ]
        #        ).all.reach.measurement.median
        
        puts [
        #        code.annotation.annotation,
        #                code.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.uniq.join(', '),
        #                code.localisation_english,
        #                orth_str,
        #          code.plasmo_a_p.signal?,
        #                code.plasmit?,
        #          code.signalp_however.signal?,
        #          code.tmhmm.transmembrane_domains.length,
        #          code.amino_acid_sequence.exportpred.predicted?,
        #                code.names.reject{|n| n==code.string_id}.join(', '),
        nucleus_agreement_simple
        #                code.agreement_with_top_level_localisation_simple(
        #                                                                  TopLevelLocalisation.find_by_name('endoplasmic reticulum')
        #                ),
        #        code.literature_based_top_level_localisations.reach.name.uniq.join(', '),
        #                code.localisation_english(:by_literature => true),
        #                code.agreement_with_top_level_localisation_simple(
        #                                                                  TopLevelLocalisation.find_by_name('nucleus'),
        #                            :by_literature => true
        #                ),
        #        code.agreement_with_top_level_localisation_simple(
        #                                                          TopLevelLocalisation.find_by_name('endoplasmic reticulum'),
        #                    :by_literature => true
        #        ),
        #        lit_orth_str,
        #        code.agreement_with_top_level_localisation_simple(
        #                                                          TopLevelLocalisation.find_by_name('nucleus'),
        #                            :expression_context_evidence_class => :metabolic_maps_expression_contexts
        #        ),
        #        code.agreement_with_top_level_localisation_simple(
        #                                                          TopLevelLocalisation.find_by_name('endoplasmic reticulum'),
        #                    :expression_context_evidence_class => :metabolic_maps_expression_contexts
        #        ),
        
        #        maurers_proteome.coding_regions.include?(code),
        #        fv_proteome.coding_regions.include?(code),
        #        top_names.collect{|top_name|
        #          code.agreement_with_top_level_localisation(
        #                                                     TopLevelLocalisation.find_by_name(top_name)
        #          )
        #        },
        #        top_names.collect{|top_name|
        #          code.agreement_with_top_level_localisation(
        #                                                     TopLevelLocalisation.find_by_name(top_name),
        #                                                     :by_literature => true
        #          )
        #        },
        #          code.proteomics(nil, 1).length > 0,
        #          code.proteomics.length > 0
        #        measure,
        
        #        measure_ring,
        #        measure_troph,
        #        measure_schizont,
        #(code.aaseq.nil? ? '' : code.aaseq.length),
        #code.number_of_hydrophilic_residues,
        ].flatten.join("\t")
      end
    end
  end
  
  def nuclear_or_er
    CodingRegion.falciparum.all.each do |code|
      nuc = code.agreement_with_top_level_localisation_simple(
                                                              TopLevelLocalisation.find_by_name('nucleus')
      )
      er = code.agreement_with_top_level_localisation_simple(
                                                             TopLevelLocalisation.find_by_name('endoplasmic reticulum')
      )
      print "#{code.string_id}\t"
      if nuc == 'agree' or er == 'agree'
        puts 'agree'
      elsif nuc == 'disagree' or er == 'disagree'
        puts 'disagree'
      else
        puts
      end
    end
  end
  
  
  def localisation_for_list
    $stdin.each do |plasmodb_id|
      plasmodb_id.strip!
      
      code = CodingRegion.ff(plasmodb_id)
      print "#{plasmodb_id}\t"
      
      if code.nil?
        puts "Couldn't find this gene ID"
      else
        
        orth_str = nil
        orth_pubs = nil
        begin
          localised_orths = code.localised_apicomplexan_orthomcl_orthologues
          if localised_orths.nil?
            orth_str = 'no entry in OrthoMCL v3'
          else
            orth_str = localised_orths.reject{
              |c| c.id == code.id
            }.reach.localisation_english.join(' | ')
            orth_pubs = localised_orths.reject{
              |c| c.id == code.id
            }.reach.expression_contexts.flatten.reach.publication.definition.uniq.join(', ')
          end
        rescue OrthomclGene::UnexpectedCodingRegionCount
          orth_str = 'multiple OrthoMCL orthologues found'
        end
        
        puts [
        code.annotation.annotation,
        code.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.join(', '),
        code.localisation_english,
        code.expression_contexts.reach.publication.definition.uniq.join(', '),
        orth_str,
        orth_pubs
        ].join("\t")
      end
    end
  end
  
  def how_many_localised_proteins_have_a_signal_peptide?
    codes = CodingRegion.falciparum.localised.all(:select => 'distinct(coding_regions.*)')
    puts "Total localised proteins: #{codes.length}"
    positives = codes.select do |code|
      code.signalp_however.signal?
    end
    puts "Total with signal peptide: #{positives.length}"
    percent = codes.length.to_f/(positives.length.to_f)
    puts "= #{percent}"
  end
  
  def falciparum_tmhmm_distribution
    codes = CodingRegion.falciparum.all.uniq
    codes.each do |code|
      aminos = code.amino_acid_sequence
      if aminos.nil?
        $stderr.puts "Couldn't find amino acid sequence for #{code.string_id}!"
        next
      end
      
      to_print = []
      to_print.push code.string_id
      to_print.push code.tmhmm.transmembrane_domains.length
      puts to_print.join("\t")
    end
  end
  
  # Setup methods so voss_proteome_annotation runs smoothly
  def voss_proteome_annotation_setup
    # Upload the usual ER retention motifs
    EndoplasmicReticulumCTerminalRetentionMotif.new.fill
    
    # Upload the GPI anchor list
    upload_gilson_gpi_list
  end
  
  # various methods about the voss nuclear proteome. The
  # method voss_proteome_annotation_setup should be run first
  # so everything works as it should.
  def voss_proteome_annotation(all_falciparum_proteins=false)
    ers = EndoplasmicReticulumCTerminalRetentionMotif.all
    gpi_list_codes = PlasmodbGeneList.find_by_description(GILSON_GPI_LIST_NAME).coding_regions.reach.string_id.retract
    
    puts [
    "PlasmoDB ID",
    #        'Annotation (PlasmoDB 6.4)',
    #        'ApiLoc localisation description',
    #        'OrthoMCL links ApiLoc description',
        'Agreement with nucleus',
        'Agreement with literature survey nucleus?',
#        'nucleus GO term',
#        "Number of transmembrane domains (not including Signal Peptide)",
#            "ER retention motifs",
#        'Plasmit?',
#        'GPI?',
#        'SignalP?',
#        'ExportPred?',
#        'PlasmoAP?'
#        'HP1?'
    ].join("\t")
    
    #    nucleus_go_term_list_plasmodbs = PlasmodbGeneList.find_by_description("PlasmoDB nucleus GO terms").coding_regions.reach.string_id.retract
    hp1_list_plasmodbs = PlasmodbGeneList.find_by_description(PlasmodbGeneList::VOSS_HP1_LIST_NAME).coding_regions.reach.string_id.retract
    raise Exception, "bad hp1 list!" unless hp1_list_plasmodbs.length == 537
    
    foreach_code = lambda do |code, plasmodb_id|
      to_print = []
      to_print.push plasmodb_id
      to_print.push code.agreement_with_top_level_localisation_simple(
                                                                      TopLevelLocalisation.find_by_name('nucleus')
      )
      to_print.push code.agreement_with_top_level_localisation_simple(
                                                                      TopLevelLocalisation.find_by_name('nucleus'),
                                  :expression_context_evidence_class => :second_class_citizen_expression_contexts
      )
      #      to_print.push nucleus_go_term_list_plasmodbs.include?(code.string_id)
      #      to_print.push code.tmhmm.transmembrane_domains.length
      #      matching_ers = ers.collect {|er|
      #        if matches = er.regex.match(code.aaseq)
      #          er.signal
      #        else
      #          nil
      #        end
      #      }.no_nils
      #      to_print.push matching_ers.empty? ? 'none' : matching_ers.join(',')
      #      
      #      to_print.push code.plasmit?
      #      
      #      to_print.push gpi_list_codes.include?(code.string_id)
      #      
      #      to_print.push code.signalp_however.signal?
      #      to_print.push code.export_pred_however.signal?
      #      to_print.push code.plasmo_a_p.signal?
      #to_print.push hp1_list_plasmodbs.include?(code.string_id)
      
      
      puts to_print.join("\t")
      $stdout.flush
    end
    
    
    if all_falciparum_proteins
      CodingRegion.falciparum.all.uniq.each do |code|
        if code.amino_acid_sequence.nil?
          puts [
          code.string_id,
            "Couldn't find PlasmoDB ID"
          ].join("\t")
          next         
        end
        
        foreach_code.call(code, code.string_id)
      end
    else
      $stdin.each do |plasmodb_id|
        plasmodb_id.strip!
        plasmodb_id.gsub!('"','')
        code = CodingRegion.ff(plasmodb_id)
        
        # remove wayward plasmodbs
        if code.nil? or code.amino_acid_sequence.nil?
          puts [
          plasmodb_id,
            "Couldn't find PlasmoDB ID"
          ].join("\t")
          next
        end
        
        foreach_code.call(code, plasmodb_id)
      end
    end
  end
  
  def distribution_of_microarray(timepoint_name=MicroarrayTimepoint::WINZELER_IRBC_SPZ_GAM_MAX_PERCENTILE_TIMEPOINT)
    CodingRegion.falciparum.all.each do |code|
      measurements = MicroarrayMeasurement.timepoint_name(timepoint_name).find_all_by_coding_region_id(
                                                                                                       code.id
      ).reach.measurement.retract
      unless measurements.empty?
        puts measurements.average
      end
    end
  end
  
  def plasmodbs_to_yeast_sgd_ids
    $stdin.each do |line|
      name = line.strip.gsub('"','')
      code = CodingRegion.ff(name)
      if code.nil?
        $stderr.puts "Couldn't find #{name}, ignoring"
        next
      end
      
      sgds = sgd_homologues(code)
      orth = code.single_orthomcl!
      unless orth
        puts [name, "Unable to find Orthomcl v3 ID"].join("\t")
        next
      end
      group = orth.official_group
      if group.nil? #doesn't have orthologues
        puts name
        next
      end
      yeasts = group.orthomcl_genes.code('scer').all
      if yeasts.length == 1
        puts [name, yeasts[0].official_split[1]].join("\t")
      elsif yeasts.length > 1
        puts [name, "#{yeasts.length} yeast genes found"].join("\t")
      else
        puts [name].join("\t")
      end
    end
  end
  
  def plasmodbs_to_yeast_sgd_info
    $stdin.each do |line|
      name = line.strip.gsub('"','')
      code = CodingRegion.ff(name)
      if code.nil?
        $stderr.puts "Couldn't find #{name}, ignoring"
        next
      end
      
      ogenes = code.orthomcl_genes
      if ogenes.length > 1
        puts [name, "Linking problems - one orthomcl genes has 2 coding regions, ignoring"]
        next
      end
      orth = ogenes.empty? ? nil : ogenes[0]
      unless orth
        puts [name, "Unable to find Orthomcl v3 ID"].join("\t")
        next
      end
      group = orth.official_group
      if group.nil? #doesn't have orthologues
        puts name
        next
      end
      yeasts = group.orthomcl_genes.code('scer').all
      compartments = yeasts.collect do |y|
        codes = y.coding_regions
        if codes.empty?
          []
        else
          codes.reach.cached_compartments.uniq
        end
      end
      compartments.flatten!
      compartments.uniq!
      
      to_print = [
      name,
      yeasts.length,
      yeasts.collect{|y| y.official_split[1]}.join(', '),
      compartments.join(", "),
      compartments.empty? ? nil : compartments.include?(OntologyComparison::NUCLEUS_NAME),
      compartments.empty? ? nil : compartments.include?(OntologyComparison::ENDOPLASMIC_RETICULUM_NAME)
      ]
      puts to_print.join("\t")
    end
  end
  
  # For each protein taken in on $stdin, print out
  # the plasmodb id and percentile (in blocks of 5)
  # max in ER, LR, ET, LT, ES, LS from Winzeler 2003
  # Affy data, as downloaded from plasmodb
  def microarray_percentiles_from_stdin
    # Read in the PlasmoDB id mappings
    plasmodbs_to_blocks = {}
     (0..19).each do |i|
      start = i*5
      stop = start+5
      
      filename = "#{DATA_DIR}/Plasmodium falciparum/microarray/Winzeler2003/percentile_blocks/sorbitol#{start}to#{stop}.txt"
      FasterCSV.foreach(filename, :headers => true) do |row|
        plasmodb = row[0].strip
        plasmodbs_to_blocks[plasmodb] = start #may overwrite, but because we are in order that's ok
      end
    end
    
    $stdin.each do |line|
      plasmodb = line.strip
      if plasmodbs_to_blocks[plasmodb].nil?
        $stderr.puts "Unable to find coding region for #{plasmodb}"
        puts "#{plasmodb}\t"
      else
        puts [
        plasmodb,
        plasmodbs_to_blocks[plasmodb]
        ].join("\t")
      end
    end
  end
  
  def gametocyte_whole_cell_proteomics
    # troph genes are not gametocyte genes, if you read the paper. "For the trophozoite sample, synchronous trophozoites of gametocyte-less clone F12 (15) from a high parasitemia culture were MACS-purified."
    #    troph_coding_regions = ProteomicExperiment.find_by_name(ProteomicExperiment::FALCIPARUM_GAMETOCYTOGENESIS_2010_TROPHOZOITE_NAME).coding_regions
    stage_i_and_ii_coding_regions = ProteomicExperiment.find_by_name(ProteomicExperiment::FALCIPARUM_GAMETOCYTOGENESIS_2010_GAMETOCYTE_STAGE_I_AND_II_NAME).coding_regions
    stage_v_coding_regions = ProteomicExperiment.find_by_name(ProteomicExperiment::FALCIPARUM_GAMETOCYTOGENESIS_2010_GAMETOCYTE_STAGE_V_NAME).coding_regions
    
    puts [
    'PlasmoDB',
    'Stage I/II gametocyte proteome',
    'Stage V gametocyte proteome',
    ].join("\t")
    
    $stdin.each do |line|
      plasmodb = line.strip.gsub('"','')
      code = CodingRegion.ff(plasmodb)
      if code.nil?
        puts [plasmodb, "Couldn't find coding region id `#{plasmodb}', ignoring"].join("\t")
        next
      end
      
      puts [
      plasmodb,
      #      troph_coding_regions.include?(code),
      stage_i_and_ii_coding_regions.include?(code),
      stage_v_coding_regions.include?(code)
      ].join("\t")
    end
  end
  
  # Print out a list of the second class citizens in P. falciparum
  # and their compiled localisation
  def second_class_citizens_list
    CodingRegion.falciparum.all(:joins => :second_class_citizen_expression_contexts, :select => 'distinct(coding_regions.*)').each do |code|
      puts [
      code.string_id,
      code.annotation.annotation,
      code.literature_based_top_level_localisations.reach.name.uniq.sort.join((', ')),
      code.second_class_citizen_expression_contexts.collect{|e| e.publication.definition}.sort.uniq.join(', ')
      ].join("\t")
    end
  end
  
  def nucleus_go_annotation
    go_decisions = {}
    
    # Read in the data
    FasterCSV.foreach("#{PHD_DIR}/voss_proteome/June2010/go_term_annotation/PfalciparumGene_PlasmoDB-7.0.txt.nucleus_agreement.txt",:col_sep => "\t") do |row|
      go_decisions[row[0]] = row[1]
    end
    
    failed_count = 0
    $stdin.each do |code|
      code.strip!
      decision = go_decisions[code]
      print "#{code}\t"
      if decision == 'positive'
        puts 'positive'
      elsif decision == 'negative'
        puts 'negative'
      elsif decision == 'both'
        puts 'positive'
      elsif decision
        puts 'unknown'
      else
        failed_count += 1
        puts 'unknown'
      end
    end
    $stderr.puts "Failed #{failed_count}."
  end
  
  def voss_annotated_proteins_counting
    {
      ExpressionContext => :expression_contexts,
      SecondClassCitizenExpressionContext => :second_class_citizen_expression_contexts,
      MetabolicMapsExpressionContext => :metabolic_maps_expression_contexts,
    }.each do |clazz, s|
      nucs = []
      sorta_nucs = []
      not_nucs = []
      nils = []
      ers = []
      
      nuc_top = TopLevelLocalisation.find_by_name('nucleus')
      CodingRegion.falciparum.all(:joins => s).uniq.each do |code|
        endo_agree = code.agreement_with_top_level_localisation_simple(
                                                                       TopLevelLocalisation.find_by_name('endoplasmic reticulum'),
                            :expression_context_evidence_class => s
        )
        if endo_agree == 'agree'
          ers.push code
          next
        end
        agree = code.agreement_with_top_level_localisation_simple(
                                                                  TopLevelLocalisation.find_by_name('nucleus'),
                            :expression_context_evidence_class => s
        )
        if agree == 'agree'
          if code.tops_by_evidence(s).reject{|top| %w(nucleus cytoplasm).push('not cytoplasm').include?(top.name)}.length > 0
            sorta_nucs.push code
          end
          nucs.push code
        elsif agree == 'disagree'
          not_nucs.push code
        elsif agree.nil? or agree == 'conflict'
          nils.push code
        else
          raise Exception, "programming error - agree was #{agree}"
        end
      end
      
      puts [
      s.to_s,
      nucs.length,
      not_nucs.length + nucs.length,
      nils.length,
      ers.length
      ].join("\t")
      
      sorta_nucs.each do |code|
        puts [
        code.names.join(', '),
        code.tops_by_evidence(s).sort{|a,b| a.name<=>b.name}.uniq.reach.name.join(', '),
        code.localisation_english,
        ].join("\t")
      end
    end
  end
  
  def manually_correct_some_nucleus_agreements(coding_region)
    # by default, anything that is nuclear is in agreement. However, some are manually changed due to literature disagreements
    hash = {
    'PF10_0155' => 'conflict', #enolase
    'PF10_0395' => 'conflict',#stevor
    'PFE0285c' => 'exclude', #sumo
    'PFE0360c' => 'conflict', #unnamed, from pull-down
    }
    if hash[coding_region.string_id]
      return hash[coding_region.string_id]
    end
    return nil
  end
end
