module AtBias
  def at_bias_length_normalised_proteins_species(species_name)
    puts "ATbiasBin\tAverage\tMedian"
    bins = []
    CodingRegion.s(species_name).all(
      :include => :transcript_sequence
    ).each do |code|
      next unless code.naseq #skip ncRNA and stuff
      next if block_given? and yield(code)

      l = code.naseq.length
      pro = code.at_profile
      pro.each_with_index do |h,i|
        index = i.to_f/l.to_f*100
        bins[index] ||= []
        bins[index].push h
      end
    end
    bins.each_with_index do |b, i|
      puts [
        i,
        b.average,
        b.median
      ].join("\t")
    end
  end

  def at_bias_c_terminal_coverage_biased(species_name=Species::FALCIPARUM_NAME)
    puts "ATbiasBin\tAverage\tMedian"
    at_biases = []
    coverages = []
    CodingRegion.species(species_name).all(
      :joins => [:cds_sequence, :annotation],
      :include => [:cds_sequence, :annotation]
    ).each do |code|
      next unless code.cdsseq #skip ncRNA and stuff
      next if block_given? and yield(code)
      l = code.cdsseq.length
      pro = code.cds_at_profile
      pro.each_with_index do |h,i|
        index = l-i
        at_biases[index] ||= 0.0
        at_biases[index] += h
      end
      (1..l).each do |i|
        coverages[i] ||= 0
        coverages[i] += 1
      end
    end
    at_biases.each_with_index do |b, i|
      next if i==0
      puts b/coverages[i]
    end
  end

  def at_bias_c_terminal_coverage_biased_falciparum
    at_bias_c_terminal_coverage_biased(Species::FALCIPARUM_NAME) do |code|
      code.falciparum_cruft? #exclude var, rifin, stevor, etc.
    end
  end

  def at_bias_c_terminal_coverage_biased_vivax
    at_bias_c_terminal_coverage_biased(Species::VIVAX_NAME) do |code|
      code.cruft?(Species::VIVAX_NAME)
    end
  end

  def at_bias_c_terminal_coverage_biased_yeast
    at_bias_c_terminal_coverage_biased(Species::YEAST_NAME)
  end

  def at_bias_c_terminal_coverage_biased_toxo
    at_bias_c_terminal_coverage_biased(Species::TOXOPLASMA_GONDII)
  end

  def hydrophobicity_bias_n_terminal_coverage_normalised
    puts "Hydrophobicities"
    hydrophobicities = []
    coverages = []
    CodingRegion.falciparum.all(
      :include => [:transcript_sequence, :annotation],
      :joins => :transcript_sequence).each do |code|
      next unless code.aaseq #skip ncRNA and stuff
      next if code.falciparum_cruft? # skip var, rifin, etc.
      l = code.aaseq.length
      pro = code.hydrophobicity_profile
      pro.each_with_index do |h,i|
        hydrophobicities[i] ||= 0.0
        hydrophobicities[i] += h
      end

      (1..l).each do |i|
        coverages[i] ||= 0
        coverages[i] += 1
      end
    end

    hydrophobicities.each_with_index do |h,i|
      next if i==0 #there is no zeroth residue
      puts h/coverages[i].to_f
    end
  end

  def stop_codon_usage(species=Species::TOXOPLASMA_GONDII)
    codons = {}
    CodingRegion.s(species).all(
      :joins => [:cds_sequence, :annotation],
      :include => [:cds_sequence, :annotation]
    ).each do |code|
      codon = code.cdseq[-3..-1]
      codons[codon] ||= 0
      codons[codon] += 1
    end

    codons.to_a.sort{|a,b|
      a[1]<=> b[1]
    }.each do |a|
      puts "#{a[0]} #{a[1]}"
    end
  end

  def codon_usage(species=Species::FALCIPARUM_NAME, amino_acid_numbers = nil)
    codons = {}
    species ||= Species::FALCIPARUM
    CodingRegion.s(species).all(
      :joins => [:amino_acid_sequence, :annotation],
      :include => [:amino_acid_sequence, :annotation]
    ).each do |code|
      lamb = lambda{|a|
        codons[a] ||= 0
        codons[a] += 1
      }
      aaseq = code.aaseq
      if amino_acid_numbers.nil?
        aaseq.each_char do |a|
          lamb.call(a)
        end
      else
        raise unless amino_acid_numbers.kind_of?(Array)
        min = amino_acid_numbers[0]
        max = amino_acid_numbers[1]
        if min > aaseq.length-1
          raise
        elsif max > aaseq.length-1
          next
          #          max = aaseq.length-1
        end

        str = aaseq[min..max]
        next if str.match(/\*/)

        aaseq[min..max].each_char do |a|
          lamb.call(a)
        end
      end
    end

    codons.to_a.sort{|a,b|
      a[1]<=> b[1]
    }.each do |a|
      puts "#{a[0]} #{a[1]}"
    end
  end
end
