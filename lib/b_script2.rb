class BScript
  def printtandem(roll)
    raise if roll.empty?
    puts
    puts "#{roll[0].string_id} #{roll[0].annotation.annotation}"
    roll[1..(roll.length-1)].each do |hit|
      puts "#{hit[0].string_id} #{hit[0].annotation.annotation} #{hit[1]}"
    end
  end
  
  # Taking in order all the genes in P. falciparum, is there interesting clusters?
  def tandem_orthologue_search
    Species.find_by_name(Species::FALCIPARUM_NAME).scaffolds.each do |scaf|
      #start with the most downstream gene
      code = scaf.downstreamest_coding_region
      puts
      puts
      puts scaf.name
      
      roll = []
      
      while code != nil #never actually reach this condition
        next_code = code.next_coding_region
        break if next_code.nil?
        
        unless code.aaseq.nil? or next_code.aaseq.nil?
          hits = code.amino_acid_sequence.blastp(
                                                 next_code.amino_acid_sequence,
            '1e-5'
          ).hits
          
          if hits.length > 0 and hits[0].evalue < 0.00001
            if roll.empty?
              roll.push code
            end
            roll.push [next_code, hits[0].evalue]
          else
            unless roll.empty?
              printtandem(roll)
              roll = []
            end
          end
        end
        
        code = next_code
      end
      printtandem(roll) unless roll.empty?
    end
  end
  
  # What is the distribution of the number of each amino acid in each protein.
  # Don't print headers, but do print row names
  def print_amino_acid_counts
    amino_acid_counts.each do |residue, residue_counts|
      puts [
      residue, (residue_counts.slap*100).round(2).retract.join(',')
      ].flatten.join(",")
    end
  end
  
  # What is the distribution of the number of each amino acid in each protein.
  # Don't print headers, but do print row names
  def cache_amino_acid_counts
    name = MyCache::FALCIPARUM_AMINO_ACID_FRACTIONS
    raise Exception, "Already exists?" if MyCache.find_by_name(name)
    MyCache.create!(:name => name, :cache => amino_acid_counts)
    return nil
  end
  
  # What is the distribution of the number of each amino acid in each protein.
  # Don't print headers, but do print row names
  def print_amino_acid_numbers
    amino_acid_counts.each do |residue, residue_counts|
      puts [
      residue, residue_counts.length
      ].flatten.join(' ')
    end
  end
  
  def amino_acid_counts
    counts = {}
    
    CodingRegion.falciparum.all(
      :joins => :amino_acid_sequence,
      :include => [:amino_acid_sequence, :annotation]
    ).each do |code|
      next if code.falciparum_cruft? #skip overrepresented ones
      
      my_counts = {}
      skipped_count = 0
      
      code.aaseq.each_char do |residue|
        if %w(X *).include?(residue)
          skipped_count += 1
          next
        end
        my_counts[residue] ||= 0
        my_counts[residue] += 1
      end
      
      my_counts.each do |residue, count|
        counts[residue] ||= []
        counts[residue].push count.to_f/(code.aaseq.length.to_f-skipped_count)
      end
    end
    
    return counts
  end
  
  
  def c_terminal_unexpectedness_coverage_normalised
    puts "c_terminal_unexpectedness_coverage_normalised"
    
    #array of positions each containing residue hash to count
    # so a count of each residue and each position
    position_residue = []
    # total number of residues at each position for normalisation
    coverages = []
    # the amino acids I care about (so no X, U, B)
    # ben@ben:~/phd/gnr$ scr BScript2.new.print_amino_acid_numbers
    #K 5101
    #V 5095
    #A 5030
    #W 4105
    #L 5107
    #M 5110
    #N 5097
    #C 4919
    #Y 5093
    #D 5093
    #E 5094
    #P 5005
    #F 5088
    #Q 5045
    #G 5057
    #R 5069
    #H 4990
    #S 5105
    #T 5094
    #I 5105
    #U 1
    amino_acids = %w(A C D E F G H I K L M N P Q R S T V W Y)
    CodingRegion.falciparum.all(
      :include => [:amino_acid_sequence, :annotation],
      :joins => :amino_acid_sequence).each do |code|
      
      aaseq = code.aaseq
      next if aaseq.nil? #skip ncRNA and stuff
      next if code.falciparum_cruft? # skip var, rifin, etc.
      
       (0..(aaseq.length-1)).each do |i|
        break if i > 300
        index = i
        current_aa = aaseq[index..index]
        next unless amino_acids.include?(aaseq[index..index])
        
        # initialise the numbers of each residue this position
        position_residue[index] ||= {}
        amino_acids.each do |aa|
          position_residue[index][aa] ||= 0
        end
        # increment the amino acid count
        position_residue[index][current_aa] += 1
        
        # record the coverage here
        coverages[index] ||= 0
        coverages[index] += 1
      end
      print '.'
    end; nil
    puts
    
    # work out distributions of each of the amino acids
    aminos = MyCache.find_by_name(MyCache::FALCIPARUM_AMINO_ACID_FRACTIONS).cache; nil
    
    # for each position, determine how much the distribution of amino acids is
    # unexpected. The metric is to take the average distance away from the distribution,
    # measured by the kolmogorov-smirnov test distance.
    # I'm not choosing the right way to do
    # this probably, Because:
    # * I want to upweight overrepresented residues, because the distances are
    #   more reliable
    # * 2 units away is more than twice 1 unit away.
    #
    # But I want to do something first, so here goes. It is just exploratory
    # anyway, right?
    
    position_residue.each_with_index do |amino_acid_hash, index|
      puts [
      index+1,
      amino_acids.collect { |aa|
        observed = amino_acid_hash[aa].to_f/coverages[index].to_f # a single number
        expected = aminos[aa] # a distribution
        
        r = RSRuby.instance
        r.ks_test(expected,observed)['statistic']['D']
      }.average
      ].join("\t")
    end
    
    # z-score trial
    # create the averages and standard deviations for each aa.
    averages = {}
    sds = {}
    aminos.each do |aa, observeds|
      averages[aa] = observeds.average
      sds[aa] = observeds.standard_deviation
    end
    # Average the z-scores
    results = []
    position_residue.each_with_index do |amino_acid_hash, index|
      break if index > 100
      result = amino_acids.collect { |aa|
        puts aa
        observed = amino_acid_hash[aa].to_f/coverages[index].to_f # a single number
         (observed - averages[aa])/sds[aa]
      }.send(:average)
      results[index] = result
      puts [
      index+1,
      result
      ].join("\t")
    end
    RSRuby.instance.plot(results, :type => 'l', :xlab=>'residue', :ylab => 'difference'); nil
  end
  
  # As of PlasmoDB 6.0
  # => #<ReachingArray:0xb65c7ba8 @retract=["MAL8P1.86"]>
  def print_selenocysteine_search
    puts selenocysteine_search.reach.string_id.join(' ')
  end
  
  def selenocysteine_search(species_name=Species::FALCIPARUM_NAME)
    CodingRegion.species(species_name).all(:include => :amino_acid_sequence,
      :joins => :amino_acid_sequence,
      :conditions => ['sequence like ?', '%U%'])
  end
  
  def apicoplast_and_transmembrane_domains
    CodingRegion.falciparum.all do |code|
      next unless code.plasmo_a_p.predicted
    end
  end
  
  # print a csv file of the mass spec peptides, lined up by their N terminus
  def proteomics_profile_first
    total_profile = [0.0]*100 #initialize. This is done on percent, so..
    
    CodingRegion.falciparum.all(
      :joins => [:amino_acid_sequence, :proteomic_experiment_peptides]
    ).uniq.each do |code|
      code.proteomics_profile.each_with_index do |yes_no, i|
        l = code.aaseq.length
        index = ((i.to_f/l.to_f)*100).round
        total_profile[index-1] += yes_no.to_f/l.to_f #normalise addition by length too, otherwise long proteins will get in the way
      end
    end
    
    puts "ProteomicsProfile"
    puts total_profile.join("\n")
  end
  
  # print a csv file of the mass spec peptides, lined up by their N terminus
  def proteomics_coverage_n_terminal_coverage_normalised
    total_profile = []
    length_coverages = []
    
    CodingRegion.falciparum.all(
      :joins => [:amino_acid_sequence, :proteomic_experiment_peptides],
      :include => [:amino_acid_sequence, :proteomic_experiment_peptides]
    ).uniq.each do |code|
      code.proteomics_profile.each_with_index do |yes_no, i|
        index = i
        total_profile[index] ||= 0
        total_profile[index] += yes_no
        length_coverages[index] ||= 0
        length_coverages[index] += 1
      end
    end
    
    puts "ProteomicsProfileNTerminal\tProteins"
    total_profile.each_with_index do |num, i|
      puts [
       (num.to_f/length_coverages[i].to_f).round(5),
      length_coverages[i]
      ].join("\t")
    end
  end
  
  def stuart_apicoplast_falciparum_to_toxoplasma
    r = File.read('/home/ben/Desktop/392 falciparum apicoplast.txt').split("\n").collect {|f|
      if %w(
PF10_0249
PF11_0110
PF11_0475
PF11_0493
PFB0814c
PFE0180w
PFI1740c).include?(f)
        [f, 'no falciparum gene'].join("\t")
      else
        og = OrthomclGene.official.find_by_orthomcl_name("pfa|#{f}")
        if og
          group = og.orthomcl_group
          if group
            [f, og.orthomcl_group.orthomcl_genes.code('tgo').all.reach.orthomcl_name.retract].flatten.join("\t")
          else
            [f, 'no orthomcl group'].join("\t")
          end
        else
          [f, 'no orthomcl gene'].join("\t")
        end
      end
    }.join("\n"); nil
    puts r
  end
  
  def map_localisations_to_go_terms
    Localisation::KNOWN_LOCALISATIONS[Species::FALCIPARUM_NAME].each do |loc_name|
      terms = Localisation.find_by_name(loc_name).map_to_go_term_multiple
      if terms.empty?
        puts "#{loc_name}"
      else
        terms.each_with_index do |term, index|
          if index == 0
            print "#{loc_name}\t"
          else
            print "\t"
          end
          puts [
          term.go_identifier,
          term.term,
          ].join("\t")
        end
      end
    end
  end
  
  
  def conserved_counts_4_species
    [
      'endoplasmic reticulum',
      'inner membrane complex',
      'cytoplasm',
      'parasitophorous vacuole',
      'mitochondrion',
      'exported',
      'apical',
      'apicoplast'
    ].each do |localisation|
      print localisation
      total = 0
      %w(pber tgon cpar tthe atha).each do |orth_code|
        yes = 0
        no = 0
        #        CodingRegion.falciparum.topa(localisation).all.uniq.each do |code|
        CodingRegion.s(Species::TOXOPLASMA_GONDII_NAME).topa(localisation).all.uniq.each do |code|
          begin
            o = code.single_orthomcl
            unless o.nil?
              if o.orthomcl_groups.first.orthomcl_genes.code(orth_code).count > 0
                yes += 1
              else
                no += 1
              end
            end
          rescue
          end
        end
        total = yes+no
        print "\t#{yes.to_f/(no.to_f+yes.to_f)*100.0}"
      end
      print "\t#{total}"
      puts
    end
    
  end
  
  def are_proteins_localised?
    $stdin.each do |plasmodb_id|
      plasmodb_id.strip!
      code = CodingRegion.ff(plasmodb_id)
      print "#{plasmodb_id}\t"
      if code.nil?
        puts "Couldn't find this gene ID"
      else
        puts [
        code.annotation.annotation,
        code.localisation_english
        ].join("\t")
      end
    end
  end
  
  # read in a blastclust file and print out the different annotations
  def clusters_to_annotation
    File.foreach(ARGV[0]) do |line|
      splits = line.strip.split(' ')
      splits.each do |split|
        name = split.strip.gsub(/^psu\|/,'')
        code = CodingRegion.ff(name)
        if code
          puts [
          code.string_id,
          code.agreement_with_top_level_localisation(TopLevelLocalisation.find_by_name('nucleus')),
          code.annotation.annotation,
          ].join("\t")
        else
          puts "coudn't find #{name}"
        end
      end
      
      puts '----------------------------------------------------'
    end
  end
  
  def pfmpred_to_plasmodb_ids(filename =
      "#{DATA_DIR}/Plasmodium falciparum/pfmpred/mito-40")
    Bio::FlatFile.foreach(filename) do |entry|
      codes = CodingRegion.falciparum.all(
        :joins => :amino_acid_sequence,
        :conditions => [
          'sequence = ?', entry.seq
      ]
      )
      if codes.length == 1
        puts [
        entry.definition,
          'yes',
        codes[0].string_id,
        codes[0].annotation.annotation,
        codes[0].localisation_english
        ].join("\t")
      elsif codes.length == 0
        plasmo = AminoAcidSequence.new(:sequence => entry.seq).best_blast_hit
        if plasmo.nil?
          puts [
          entry.definition,
            'no',
            'no hits'
          ]
        else
          code = CodingRegion.find_by_string_id(plasmo.gsub(/^psu\|/,''))
          raise unless code
          puts [
          entry.definition,
            'no',
          code.string_id,
          code.annotation.annotation,
          code.localisation_english
          ].join("\t")
        end
      else
        raise #doesn't happen in practise
        puts [
        entry.definition,
        codes.reach.string_id.retract
        ].flatten
      end
    end
  end
  
  def which_proteins_to_localise
    # must be a 1 to 1 correspondence in the orthomcl group between toxo and
    # falciparum
    codes = OrthomclGroup.all_overlapping_groups(%w(tgon pfal)).select {|group|
      group.orthomcl_genes.code('pfal').count == 1 and
      group.orthomcl_genes.code('tgon').count == 1
    }
    $stderr.puts "Found #{codes.length} with 1 to 1 orthomcl genes"
    
    codes.collect! {|group|
      begin
        [
        group.orthomcl_genes.code('pfal').first.single_code!,
        group.orthomcl_genes.code('tgon').first.single_code!
        ]
      rescue OrthomclGene::UnexpectedCodingRegionCount
        [nil, nil]
      end
    }
    
    codes.reject! { |a|
      a[0].nil? or a[1].nil?
    }
    $stderr.puts "After mapping to coding regions, found #{codes.length}"
    
    # must not be localised currently
    codes.reject! do |pair|
      pair[0].localised_apicomplexan_orthomcl_orthologues #accounts for itself as well as the other gene in the group
      pair.collect {|e|
        e.expression_contexts.count
      }.sum > 0
    end
    $stderr.puts "After making sure none are already localised, found #{codes.length}"
    
    codes = codes.select do |pair|
      pair[0].gene.scaffold.name.match(/Pf3D7/) and pair[1].gene.scaffold.name.match(/TGME49/)
    end
    $stderr.puts "After removing non-nuclear encoded genes, found #{codes.length}"
    
    # must be predicted as nuclear or mitochondria by falg
    codes.each do |pair|
      puts [
      pair[0].string_id,
      pair[1].string_id,
      ].join("\t")
    end
  end
  
  def safe_proteins
    puts PlasmodbGeneList.find_by_description(PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME).coding_regions.select{|c|
      c.topsap.length == 1 and c.topsap[0].name == 'nucleus'
    }.reach.string_id.join(' ')
  end
  
  def quick_delete(species_name)
    CodingRegion.s(species_name).all.each do |code|
      code.orthomcl_gene_coding_regions.all.reach.destroy
      code.delete
    end
    
    Species.find_by_name(species_name).delete
  end
  
  def falciparum_first30
    CodingRegion.falciparum.all(
      :joins => :amino_acid_sequence,
      :include => :amino_acid_sequence
    ).each do |code|
      aa = code.amino_acid_sequence
      next unless aa.sequence.length > 30
      puts ">#{code.string_id}"
      puts aa.sequence[0..29]
    end
  end
  
  PLASMIT_FILENAME = "/home/ben/phd/data/falciparum/plasmit/20100604.html"
  def plasmit_falciparum
    plasmit_filename = PLASMIT_FILENAME
    `rm '#{plasmit_filename}'`
    
    codes = CodingRegion.falciparum.all(
      :joins => :amino_acid_sequence,
      :include => :amino_acid_sequence
    )
    progress = ProgressBar.new('plasmit',codes.length)
    codes.each do |code|
      aa = code.amino_acid_sequence
      progress.inc
      # only the first 24 amino acids are used, but given that the length
      # output recorded for a 24 amino acid length protein is 23, I'm playing
      # it safe here
      next unless aa.sequence.length > 25
      Tempfile.open('plasmit') do |tempfile|
        `wget -nv 'http://gecco.org.chemie.uni-frankfurt.de/cgi-bin/plasmit/runanalysis.cgi?output=simple&sequence=>#{code.string_id}%0A#{aa.sequence[0..25]}' -O #{tempfile.path}`
        `cat #{tempfile.path} >>#{plasmit_filename}`
      end
    end
    progress.finish
  end
  
  def upload_plasmit_results
    File.foreach(PLASMIT_FILENAME) do |line|
      next unless line.match(/Lines read with presumably/)
      matches = line.match(/>>(.*?)<\/TD><TD>(.*?)</)
      raise unless matches
      code = CodingRegion.ff(matches[1]) or raise
      PlasmitResult.find_or_create_by_coding_region_id_and_prediction_string(
                                                                             code.id, matches[2]
      ) or raise
    end
  end
  
  # print out each coding region that has been localised, and put them into
  # columns so that manual curation is easy enough
  def manual_localisation_sheet
    puts [
      'PlasmoDB ID',
      'Name',
      'Manual Curation',
      'Top Level Localisation',
      'Full Localisation'
    ].join("\t")
    
    CodingRegion.falciparum.all(
      :joins => [
        :expressed_localisations,
        :plasmodb_gene_lists
    ],
      :conditions => ['plasmodb_gene_lists.description = ?',
    PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME
    ],
      :select => 'distinct(coding_regions.*)'
    ).each do |code|
      puts [
      code.string_id,
      code.annotation.annotation,
      code.curated_top_level_localisations.nil? ? 
      nil :
      code.curated_top_level_localisations.reach.name.sort.join(', '),
      code.topsap.reach.name.join(', '),
      code.localisation_english
      ].join("\t")
    end
  end
  
  def upload_manual_localisation_sheet(filename="#{PHD_DIR}/apiloc/manual_curation/confirmation_commented.csv")
    FasterCSV.foreach(filename, :headers => true, :col_sep => "\t") do |row|
      unless row[2].nil?
        curations = row[2].strip.split(', ')
        code = CodingRegion.ff(row[0]) or raise Exception, "Coudn't find #{row[0]}"
        curations.each do |curate|
          top = TopLevelLocalisation.find_by_name(curate)
          raise unless top
          CuratedTopLevelLocalisation.find_or_create_by_coding_region_id_and_top_level_localisation_id(
                                                                                                       code.id, top.id
          ) or raise
        end
      end
    end
  end
  
  # For files output by weka and manually chopped together using openoffice.
  def upload_weka_prediction_csv(filename = "#{PHD_DIR}/weka/second/falciparum_trained1_output.csv")
    FasterCSV.foreach(filename, :col_sep => "\t") do |row|
      plasmo = row[0]
      prediction = row[3]
      code = CodingRegion.ff(plasmo.strip) or raise
      
      matches = prediction.strip.match(/\d\:(.*)/) or raise
      real_prediction = matches[1]
      fixes = {
        'cytoplas' => 'cytoplasm',
        'apicopla' => 'apicoplast',
        'mitochon' => 'mitochondrion',
        'endoplas' => 'endoplasmic reticulum',
      }
      real_prediction = fixes[matches[1]] if fixes[matches[1]]
      
      WekaPrediction.find_or_create_by_coding_region_id_and_measurement(
                                                                        code.id, real_prediction
      )
    end
  end
  
  # Try to get a list of proteins that I might like to test in the lab.
  def gather_lab_testing_dataset1
    # Criteria:
    # must be predicted as mitochondrial or nuclear (I want a smattering of both)
    candidates = CodingRegion.falciparum.all(
      :joins => [:weka_prediction, :orthomcl_genes],
      :conditions => ["string_coding_region_measurements.measurement in #{%w(nucleus mitochondrion).to_sql_in_string}"]
    #      :limit => 10
    ).select do |code|
      # must not already be localised
      # must only have 1 to 1 mapping in orthomcl database to toxo
      group = code.single_orthomcl.official_group
      if code.expression_contexts.count == 0 and
        group.orthomcl_genes.code('pfal').count == 1 and
        group.orthomcl_genes.code('tgon').count == 1
        true
      else
        false
      end
    end
    
    parts = candidates.partition do |code|
      code.weka_prediction.measurement == 'nucleus'
    end
    $stderr.puts "Found #{parts[0].length} nucleus, and #{parts[1].length} mitochondrion."
    
    # must be expressed during tachyzoite stages and blood stages. Not sure how to do this yet
    
    #proteomic experiments
    prots = ["MS Carruthers 2destinct peptides",
      "Murray Conoid-enriched Fraction",
      "MS Tachyzoite Membrane fraction 05-10-2006",
      "MS Tachyzoite Membrane fraction 06-2006",
      "MS Tachyzoite Cytosolic Protein Fractions 05-2007",
      "2DLC MS/MS Tachyzoite Membrane fraction",
      "MS Carruthers MudPIT Twinscan hits",
      "1D Gel Tachyzoite Membrane fraction 10-2006",
      "Moreno DTASelect filter sample G",
      "Murray Conoid-depleted Fraction",
      "Wastling MudPIT Soluble",
      "Wastling MudPIT Insoluble",
      "Wastling 1-D SDS PAGE",
      "MS Tachyzoite Membrane Protein with Biotinlyation Purification 05-22-2007",
      "Moreno DTASelect filter sample A",
      "Wastling 1-D SDS PAGE Soluble",
      "Wastling 1-D SDS PAGE Insoluble",
      "MS Tachyzoite Membrane fraction 02-03-2006",
      "1D Gel Tachyzoite Membrane fraction 12-2006",
      "MS Tachyzoite Membrane fraction 05-02-2006",
      "Wastling Rhoptry"]
    
    # headers
    puts [
      'PlasmoDB ID',
      'Annotation',
      'Prediction',
      'Toxo orthologue',
      'Toxo orthologue annotation',
      'Hit e-value between falciparum and toxo',
      'falciparum start of best HSP',
      'toxo start of best HSP',
      'plasmit?',
      'DeRisi 3D7 measurement at 47 hours',
    ["VEG", "CTG", "Prugniaud", "RH", "GT1", "ME49"].collect{|s| "#{s} percentile"},
    prots,
      '# tachyzoite ESTs',
      '# non-tachyzoite ESTs',
    ].flatten.join("\t")
    
    # how close is the homology to the N terminus? More homology N terminally means more chance of the gene model being correct?
    candidates.each do |code|
      gondii_code = nil
      
      begin
        print [
        code.string_id,
        code.annotation.annotation,
        code.weka_prediction.measurement,
        nil
        ].join("\t")
        gondii_code = code.single_orthomcl.official_group.orthomcl_genes.code('tgon').first.single_code
        print [
        gondii_code.string_id,
        gondii_code.annotation.annotation,
        nil
        ].join("\t")
      rescue
        puts "Failed to map from orthomcl"
        next
      end
      
      blast = code.amino_acid_sequence.blastp(gondii_code.amino_acid_sequence)
      
      if blast.hits.length == 1
        hit = blast.hits[0]
        
        meas = code.microarray_measurements.first(:joins => :microarray_timepoint, :conditions => ['name = ?', 'Timepoint 47'])
        
        strain_percentiles = ["VEG", "CTG", "Prugniaud", "RH", "GT1", "ME49"].collect do |strain|
          measurement = MicroarrayMeasurement.find_by_coding_region_id(gondii_code.id,
            :joins => :microarray_timepoint,
            :conditions => ['microarray_timepoints.name = ?', strain]
          )
          measurement.nil? ? '-' : measurement.measurement
        end
        
        proteomics = prots.collect do |name|
          num_peptides = ProteomicExperimentResult.find_by_coding_region_id(
                                                                            gondii_code.id,
            :joins => :proteomic_experiment,
            :conditions => ['proteomic_experiments.name = ?', name]
          )
          num_peptides.nil? ? 0 : num_peptides.number_of_peptides
        end
        
        puts [
        hit.evalue,
        hit.hsps[0].query_from,
        hit.hsps[0].hit_from,
        code.plasmit_result.predicted?,
        meas.nil? ? '-' : meas.measurement,
        strain_percentiles,
        proteomics,
        gondii_code.tachyzoite_est_count.nil? ? 0 : gondii_code.tachyzoite_est_count.value,
        gondii_code.non_tachyzoite_est_count.nil? ? 0 : gondii_code.non_tachyzoite_est_count.value,
        ].flatten.join("\t")
        
      else
        puts "Unexpectedly found #{blast.hits.length} hits bl2seq'ing between falciparum and toxo."
      end
      
    end
  end
  
  def anntotate_toxo_percentiles
    
    prots = ["MS Carruthers 2destinct peptides",
      "Murray Conoid-enriched Fraction",
      "MS Tachyzoite Membrane fraction 05-10-2006",
      "MS Tachyzoite Membrane fraction 06-2006",
      "MS Tachyzoite Cytosolic Protein Fractions 05-2007",
      "2DLC MS/MS Tachyzoite Membrane fraction",
      "MS Carruthers MudPIT Twinscan hits",
      "1D Gel Tachyzoite Membrane fraction 10-2006",
      "Moreno DTASelect filter sample G",
      "Murray Conoid-depleted Fraction",
      "Wastling MudPIT Soluble",
      "Wastling MudPIT Insoluble",
      "Wastling 1-D SDS PAGE",
      "MS Tachyzoite Membrane Protein with Biotinlyation Purification 05-22-2007",
      "Moreno DTASelect filter sample A",
      "Wastling 1-D SDS PAGE Soluble",
      "Wastling 1-D SDS PAGE Insoluble",
      "MS Tachyzoite Membrane fraction 02-03-2006",
      "1D Gel Tachyzoite Membrane fraction 12-2006",
      "MS Tachyzoite Membrane fraction 05-02-2006",
      "Wastling Rhoptry"]
    
    puts ['ToxoDB ID',
      'Bad gene mode?',
      'annotation',
      'strains studied by localisation',
    ["VEG", "CTG", "Prugniaud", "RH", "GT1", "ME49"],
    prots,
      '# tachyzoite ESTs',
      '# non-tachyzoite ESTs',
    ].flatten.join("\t")
    
    %w(TGME49_114250
    TGME49_061780
    TGME49_045490
    TGME49_059020
    TGME49_052640
    TGME49_068860
    TGME49_091040
    TGME49_033460
    TGME49_070240
    TGME49_012910
    TGME49_097520).each do |t|
      code = CodingRegion.f(t) or raise
      
      
      strain_percentiles = ["VEG", "CTG", "Prugniaud", "RH", "GT1", "ME49"].collect do |strain|
        measurement = MicroarrayMeasurement.find_by_coding_region_id(code.id,
          :joins => :microarray_timepoint,
          :conditions => ['microarray_timepoints.name = ?', strain]
        )
        measurement.nil? ? '-' : measurement.measurement
      end
      
      proteomics = prots.collect do |name|
        num_peptides = ProteomicExperimentResult.find_by_coding_region_id(
                                                                          code.id,
          :joins => :proteomic_experiment,
          :conditions => ['proteomic_experiments.name = ?', name]
        )
        num_peptides.nil? ? 0 : num_peptides.number_of_peptides
      end
      
      puts [
      code.string_id,
      code.gene_model_inconsistent?,
      code.annotation.annotation,
      code.expression_contexts.reach.localisation_annotation.strain.no_nils.sort.uniq.join(', '),
      strain_percentiles,
      proteomics,
      code.tachyzoite_est_count.nil? ? 0 : code.tachyzoite_est_count.value,
      code.non_tachyzoite_est_count.nil? ? 0 : code.non_tachyzoite_est_count.value,
      ].flatten.join("\t")
      
    end
    
  end
  
  # A helper method to print out foreign keys so a migration can be made all
  # at once using matthuhiggins-foreigner style. Implemented in migration 20100112063516
  def print_add_foreign_keys
    model_root = "#{RAILS_ROOT}/app/models"
    Dir.open(model_root).each do |file|
      next unless (matches = file.match(/^(.*).rb$/))
      File.foreach(
                   File.join(model_root,"#{matches[1]}.rb")
      ) do |line|
        if m2 = line.strip.match(/has_many \:(.*)/) and line.match(/dependent/) and !line.match(/through/)
          foreign_key_table = m2[1].gsub(/,.*/,'')
          puts "\##{line}"
          puts "add_foreign_key :#{foreign_key_table.pluralize}, :#{matches[1].pluralize}, :dependent => :delete"
        end
      end
    end
  end
  
  def robot_targets_foreach_predictor
    File.foreach("#{PHD_DIR}/robot_targets/targets.list").each do |n|
      name = n.strip
      next if name.empty?
      code = CodingRegion.fs(name, Species::FALCIPARUM_NAME)
      raise Exception, name unless code
      puts [
      code.string_id,
      code.annotation.annotation,
      code.plasmo_a_p.predicted?
      ].join("\t")
    end
  end
  
  # Fixes for these genes
  def hagai_manual_fixes
    {
    'Pf11_0114' => 'PF11_0114',
    'PFB0305c' => 'PFB0305c-a', #-a and -b. -a is MSP5, presumably that's the one he is talking about
    'PPFI1370c' => 'PFI1370c',
    'PFL2210' => 'PFL2210w',
    'PFE1030' => 'PFE1030c',
    'PFE1030' => 'PFE1030c',
    'PFL1710C' => 'PFL1710c',
    'PF14_0172' => 'PF14_0173',
    'PF00_0002' => "MAL7P1.206", # is this new to PlasmoDB 7?
    }
  end
end
