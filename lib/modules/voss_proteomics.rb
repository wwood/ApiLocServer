

class BScript
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
end