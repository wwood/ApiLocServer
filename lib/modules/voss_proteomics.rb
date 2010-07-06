

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
    #          'Common names',
    #          'ApiLoc Localisation(s)',
    #          'ApiLoc Localisation(s) in Apicomplexan Orthologues',
    #      'PlasmoAP?',
    #        'Plasmit?',
    #      'SignalP?',
    #      #      'Transmembrane domain # (TMHMM)',
    #      'ExportPred score > 0?',
    #      'Agreement with nuclear simple',
    #      'Agreement with ER simple',
    #'Literature survey localisations',
    #      'Literature survey localisation description',
    #      'Literature survey nuclear agreement',
    #  'Literature survey ER agreement',
    
    #  'Localisation description of Orthologue(s)',
    #  'Included in Maurer\'s Cleft proteome?',
    #  'Included in Food Vacuole proteome?',
    #      top_names.collect{|n| "'#{n}' Agreement"},
    #      'In Lifecycle Proteomics at all?',
    #      'In Lifecycle Proteomics with at least 2 peptides'
    #    'Winzeler iRBC+Spz+Gam Affy Max Percentile'
'Winzeler ring expression percentage',
'Winzeler troph expression percentage',
'Winzeler schizont expression percentage',
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
        
        # second class the same thing
        #        lit_orth_str = nil
        #        begin
        #          localised_orths = code.localised_apicomplexan_orthomcl_orthologues(:by_literature => true)
        #          if localised_orths.nil?
        #            lit_orth_str = 'no entry in OrthoMCL v3'
        #          else
        #            lit_orth_str = localised_orths.reject{
        #              |c| c.id == code.id
        #            }.reach.localisation_english(:by_literature => true).join(' | ')
        #          end
        #        rescue OrthomclGene::UnexpectedCodingRegionCount
        #          lit_orth_str = 'multiple OrthoMCL orthologues found'
        #        end
        
        #        maurers_proteome = ProteomicExperiment.find_by_name(ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_NAME)
        #        fv_proteome = ProteomicExperiment.find_by_name(ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_NAME)
        
        #        measurements = MicroarrayMeasurement.timepoint_name(MicroarrayTimepoint::WINZELER_IRBC_SPZ_GAM_MAX_PERCENTILE_TIMEPOINT).find_all_by_coding_region_id(
        #                                                                                                                                                              code.id
        #        ).reach.measurement.retract
        #        measure = measurements.empty? ? '' : measurements.average
        
        measure_ring = code.microarray_measurements.timepoint_names([
                                                                    MicroarrayTimepoint::WINZELER_2003_EARLY_RING_SORBITOL,
        MicroarrayTimepoint::WINZELER_2003_LATE_RING_SORBITOL,
        MicroarrayTimepoint::WINZELER_2003_EARLY_RING_TEMPERATURE,
        MicroarrayTimepoint::WINZELER_2003_LATE_RING_TEMPERATURE,
        ]
        ).all.reach.measurement.median
        measure_troph = code.microarray_measurements.timepoint_names([
                                                                     MicroarrayTimepoint::WINZELER_2003_EARLY_TROPHOZOITE_SORBITOL,
        MicroarrayTimepoint::WINZELER_2003_LATE_TROPHOZOITE_SORBITOL,
        MicroarrayTimepoint::WINZELER_2003_EARLY_TROPHOZOITE_TEMPERATURE,
        MicroarrayTimepoint::WINZELER_2003_LATE_TROPHOZOITE_TEMPERATURE
        ]
        ).all.reach.measurement.median
        measure_schizont = code.microarray_measurements.timepoint_names([
                                                                        MicroarrayTimepoint::WINZELER_2003_EARLY_SCHIZONT_SORBITOL,
        MicroarrayTimepoint::WINZELER_2003_LATE_SCHIZONT_SORBITOL,
        MicroarrayTimepoint::WINZELER_2003_EARLY_SCHIZONT_TEMPERATURE,
        MicroarrayTimepoint::WINZELER_2003_LATE_SCHIZONT_TEMPERATURE,
        ]
        ).all.reach.measurement.median
        
        puts [
        #        code.annotation.annotation,
        #        code.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.uniq.join(', '),
        #        code.localisation_english,
        #        orth_str,
        #          code.plasmo_a_p.signal?,
        #                code.plasmit?,
        #          code.signalp_however.signal?,
        #          code.tmhmm.transmembrane_domains.length,
        #          code.amino_acid_sequence.exportpred.predicted?,
        #        code.names.reject{|n| n==code.string_id}.join(', '),
        #        code.agreement_with_top_level_localisation_simple(
        #                                                          TopLevelLocalisation.find_by_name('nucleus')
        #        ),
        #        code.agreement_with_top_level_localisation_simple(
        #                                                          TopLevelLocalisation.find_by_name('endoplasmic reticulum')
        #        ),
        #code.literature_based_top_level_localisations.reach.name.uniq.join(', '),
        #        code.localisation_english(:by_literature => true),
        #        code.agreement_with_top_level_localisation_simple(
        #                                                          TopLevelLocalisation.find_by_name('nucleus'),
        #                    :by_literature => true
        #        ),
        #code.agreement_with_top_level_localisation_simple(
        #                                                  TopLevelLocalisation.find_by_name('endoplasmic reticulum'),
        #            :by_literature => true
        #),
        #        lit_orth_str,
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
        measure_ring,
        measure_troph,
        measure_schizont,
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
    'Annotation (PlasmoDB 6.4)',
    'ApiLoc localisation description',
    'OrthoMCL links ApiLoc description',
    'Agreement with nucleus',
    "Number of transmembrane domains (not including Signal Peptide)",
    "ER retention motifs",
    'Plasmit?',
    'GPI?',
    'SignalP?',
    'ExportPred?',
    'PlasmoAP?'
    ].join("\t")
    
    foreach_code = lambda do |code, plasmodb_id|
      to_print = []
      to_print.push plasmodb_id
      to_print.push code.tmhmm.transmembrane_domains.length
      matching_ers = ers.collect {|er|
        if matches = er.regex.match(code.aaseq)
          er.signal
        else
          nil
        end
      }.no_nils
      to_print.push matching_ers.empty? ? 'none' : matching_ers.join(',')
      
      to_print.push code.plasmit?
      
      to_print.push gpi_list_codes.include?(code.string_id)
      
      to_print.push code.signalp_however.signal?
      to_print.push code.export_pred_however.signal?
      to_print.push code.plasmo_a_p.signal?
      
      
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
        
        foreach_plasmodb_id.call(code, plasmodb_id)
      end
    end
  end
  
  def hydrophobicity_bias_length_properly_normalised(species_name = nil)
    puts "Hydrophobicities"
    bins = []
    count = 0
    
    # Create the modular counter
    counter = lambda do |code|
      next unless code and code.aaseq #skip ncRNA and stuff
      count += 1
      
      # find hydrophobicities and counts for this protein
      my_bin = []
      my_counts = []
      l = code.aaseq.length
      pro = code.hydrophobicity_profile
      pro.each_with_index do |h,i|
        next if i==0 #ignore the first residue
        index = i.to_f/l.to_f*100
        my_bin[index] ||= 0
        my_bin[index] += h
        my_counts[index] ||= 0
        my_counts[index] += 1
      end
      
      # Add the normalised amounts to the total so each protein is weighted equally
      my_bin.each_with_index do |h, index|
        next if h.nil?
        bins[index] ||= 0.0
        bins[index] += h/(my_counts[index].to_f)
      end
    end
    
    # Abuse the modular counter
    if species_name.nil?
      $stdin.each do |line|
        code = CodingRegion.ff(line.strip.gsub('"',''))
        counter.call(code)
      end
    else
      CodingRegion.s(species_name).all.each do |code|
        next if code.cruft?
        counter.call(code)
      end
    end
    
    # Output
    puts bins.collect {|b|
      b.to_f/count.to_f
    }.join("\n")
    $stderr.puts "Included #{count} proteins"
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
end
