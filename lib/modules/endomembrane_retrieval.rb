class BScript  
  def golgi_consensus_falciparum
    # May as well run the upload of the signals because it is fast and easy
    GolgiNTerminalSignal.new.florian_fill
    GolgiCTerminalSignal.new.florian_fill
    
    signals = [GolgiNTerminalSignal.all, GolgiCTerminalSignal.all].flatten.reach.regex
    
    puts [
      'PlasmoDB ID',
      'Annotation',
      'Confirmed Localisations',
      'GPI Anchor (Predicted by Gilson et al 2006)',
      'TMHMM2 Type I/II',
      'TMHMM2 TMD Length',
      'TMHMM2 TMD Start',
      'TMHMM2 TMD End',
      'Protein Length',
      'Signal Peptide by SignalP 3.0?',
      'ExportPred Prediction',
      'Published in PEXEL List',
      'Published in HT List',
    signals.collect{|s| s.inspect}
    ].flatten.join("\t")
    
    gpi_list = PlasmodbGeneList.find_by_description "Gilson Published GPI 2006"
    
    CodingRegion.s(Species::FALCIPARUM_NAME).all(
      :include => [:amino_acid_sequence, :annotation]
    ).each do |code|
      # ignore surface crap and pseudogenes
      next if code.falciparum_cruft?
      
      # I only care about the protein minus the signal peptide
      next unless code.aaseq
      sp = code.signalp
      seq = code.aaseq
      seq = sp.cleave(seq) if sp.signal?
      
      # only count those that are predicted to have 1 TMD by TMHMM2
      tmhmm_result = TmHmmWrapper.new.calculate(seq)
      next unless tmhmm_result.transmembrane_domains.length == 1
      
      # fill in columns as possible
      m = [
      code.string_id,
      code.annotation.annotation,
      code.expressed_localisations.reach.name.join(', '),
      gpi_list.coding_regions.include?(code) ? 'GPI' : 'no GPI',
      tmhmm_result.transmembrane_type,
      tmhmm_result.transmembrane_domains[0].length,
      tmhmm_result.transmembrane_domains[0].start,
      tmhmm_result.transmembrane_domains[0].stop,
      code.aaseq.length,
      sp.signal?,
      code.amino_acid_sequence.exportpred.predicted?,
      !CodingRegion.list('pexelPlasmoDB5.5').find_by_id(code.id).nil?,
      !CodingRegion.list('htPlasmoDB5.5').find_by_id(code.id).nil?
      ]
      
      # fill in the golgi signal peptides
      signals.each do |signal|
        if code.aaseq and matches = code.aaseq.match(/(#{signal})/)
          m.push matches[1]
        else
          m.push nil
        end
      end
      puts m.join("\t")
    end
  end
  
  def florian_tmhmm_again
    # May as well run the upload of the signals because it is fast and easy
    GolgiNTerminalSignal.new.florian_fill
    GolgiCTerminalSignal.new.florian_fill
    signals = [GolgiNTerminalSignal.all, GolgiCTerminalSignal.all].flatten.reach.regex
    
    # headings
        puts [
      'PlasmoDB ID',
      'Annotation',
      'Confirmed Localisations',
      'TMHMM2 Type I/II',
      'first transmembrane domain orientation',
      'last transmembrane domain orientation',
    signals.collect{|s| s.inspect}
    ].flatten.join("\t")
    
    CodingRegion.falciparum.all(:include => :amino_acid_sequence).each do |code|
      # ignore surface crap and pseudogenes
      next if code.falciparum_cruft?
      
      # I only care about the protein minus the signal peptide
      seq = code.aaseq
      next unless seq.present?
      
      # only count those that are predicted to have 1 TMD by TMHMM2
      tmhmm_result = TmHmmWrapper.new.calculate(seq)
      next unless tmhmm_result.transmembrane_domains.length > 1
      
      m = [
      code.string_id,
      code.annotation.annotation,
      code.expressed_localisations.reach.name.join(', '),
      tmhmm_result.transmembrane_type,
      tmhmm_result.transmembrane_domains[0].orientation,
      tmhmm_result.transmembrane_domains.last.orientation
      ]
      
      # fill in the golgi signal peptides
      signals.each do |signal|
        if matches = code.aaseq.match(/(#{signal})/)
          m.push matches[1]
        else
          m.push nil
        end
      end
      puts m.join("\t")
    end
  end
end