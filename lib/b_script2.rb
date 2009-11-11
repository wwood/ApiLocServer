require 'jgi_genes'
require 'simple_go'
require 'rio'
require 'api_db_genes'
require 'yeast_genome_genes'
require 'signalp'
require 'api_db_fasta'
require 'gff3_genes'
require 'tm_hmm_wrapper'
require 'rubygems'
require 'csv'
require 'bio'
require 'peach'

#require 'mscript'
require 'reach'
require 'plasmo_a_p'
require 'top_db_xml'
require 'pdb_tm'
#require 'go'
require 'wormbase_go_file'
require 'libsvm_array'
require 'bl2seq_report_shuffling'
require 'rarff'
require 'stdlib'
require 'babesia'
require 'spoctopus_wrapper'
require 'b_script'
require 'eu_path_d_b_gene_information_table'
require 'zlib'

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
      'Annotation',
      'Common names',
      'Localisation(s)',
      'Localisation in Apicomplexan Orthologues',
      'PlasmoAP?',
      'SignalP?',
      'Transmembrane domain # (TMHMM)',
      top_names.collect{|n| "'#{n}' Agreement"}
    ].flatten.join("\t")

    $stdin.each do |plasmodb_id|
      plasmodb_id.strip!
      code = CodingRegion.ff(plasmodb_id)
      print "#{plasmodb_id}\t"
      if code.nil?
        puts "Couldn't find this gene ID"
      else
        puts code.amino_acid_sequence.exportpred.predicted?
        next
        orth_str = nil
        begin
          localised_orths = code.localised_apicomplexan_orthomcl_orthologues
          if localised_orths.nil?
            orth_str = 'no entry in OrthoMCL v3'
          else
            orth_str = localised_orths.reject{
              |c| c.id == code.id
            }.reach.localisation_english.join(' | ')
          end
        rescue OrthomclGene::UnexpectedCodingRegionCount
          orth_str = 'multiple OrthoMCL orthologues found'
        end


        puts [
          code.annotation.annotation,
          code.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.join(', '),
          code.localisation_english,
          orth_str,
          code.plasmo_a_p.signal?,
          code.signalp_however.signal?,
          code.tmhmm.transmembrane_domains.length,
          top_names.collect{|top_name|
            code.agreement_with_top_level_localisation(
              TopLevelLocalisation.find_by_name(top_name)
            )
          }
        ].flatten.join("\t")
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
end
