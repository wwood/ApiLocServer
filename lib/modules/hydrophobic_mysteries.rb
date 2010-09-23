# Hydrophobic anomalies encountered - I must investigate!
class BScript
  def hydrophobicity_bias_length_properly_normalised(species_name = nil)
    puts "Hydrophobicities"
    bins = []
    counts = []
    
    down_and_dirty = lambda {|code|
      next unless code and code.aaseq #skip ncRNA and stuff
      my_bin = []
      my_counts = []
      # return hydropathy and counts
      l = code.aaseq.length
      pro = code.hydrophobicity_profile
      pro.each_with_index do |h,i|
        next if i==0 #ignore the first residue
        next if h.nil? #ignore X's
        index = i.to_f/l.to_f*100
        my_bin[index] ||= 0
        my_bin[index] += h
        my_counts[index] ||= 0
        my_counts[index] += 1
      end
      [my_bin, my_counts]
    }
    
    # Abuse the modular counter
    if species_name.nil?
      $stdin.each do |line|
        name = line.strip.gsub('"','')
        code = CodingRegion.ff(name)
        if code.nil?
          $stderr.puts "Couldn't find #{name}, ignoring"
          next
        end
        normaliser_plumbing(bins, counts, code, &down_and_dirty)
      end
    else
      CodingRegion.s(species_name).all(:joins => :amino_acid_sequence).each do |code|
        next if code.cruft?
        normaliser_plumbing(bins, counts, code, &down_and_dirty)
      end
    end
    
    # Output
    values = []
    bins.each_with_index do |h, i|
      values[i] = h.to_f/counts[i].to_f
    end
    puts values.join("\n")
    $stderr.puts "Included #{counts.max} proteins"
  end
  
  def hydrophobicity_without_transmembrane_domains(species_name = nil)
    puts "Hydrophobicities"
    bins = []
    counts = []
    
    down_and_dirty = lambda {|code|
      next unless code and code.aaseq #skip ncRNA and stuff
      my_bin = []
      my_counts = []
      # calculate stuffs
      l = code.aaseq.length
      tmds = TmHmmWrapper.new.calculate(code.aaseq)
      pro = code.hydrophobicity_profile
      
      pro.each_with_index do |h,i|
        next if i==0 #ignore the first residue
        next if h.nil? #ignore X characters
        next if tmds.residue_number_contained?(i+1) #skip transmembrane domains
        index = i.to_f/l.to_f*100
        my_bin[index] ||= 0
        my_bin[index] += h
        my_counts[index] ||= 0
        my_counts[index] += 1
      end
      [my_bin, my_counts]
    }
    
    # Abuse the modular counter
    if species_name.nil?
      $stdin.each do |line|
        name = line.strip.gsub('"','')
        code = CodingRegion.ff(name)
        if code.nil?
          $stderr.puts "Couldn't find #{name}, ignoring"
          next
        end
        normaliser_plumbing(bins, counts, code, &down_and_dirty)
      end
    else
      CodingRegion.s(species_name).all(:joins => :amino_acid_sequence).each do |code|
        next if code.cruft?
        normaliser_plumbing(bins, counts, code, &down_and_dirty)
      end
    end
    
    # Output
    values = []
    bins.each_with_index do |h, i|
      values[i] = h.to_f/counts[i].to_f
    end
    puts values.join("\n")
    $stderr.puts "Included #{counts.max} proteins"
  end
  
  # A generic function to help normalise properly the 
  def normaliser_plumbing(bins, counts, code)
    # The block given calculates the value and the thing to be divided
    raise unless block_given?
    my_bin, my_counts = yield code
    return if bins.nil? #if the whole coding region was rejected
    
    # Add the normalised amounts to the total so each protein is weighted equally
    my_bin.each_with_index do |h, index|
      next if h.nil?
      bins[index] ||= 0.0
      bins[index] += h/(my_counts[index].to_f)
      counts[index] ||= 0
      counts[index] += 1
    end
  end
  
  def transmembrane_distribution(species_name=nil)
    puts "Hydrophobicities"
    bins = []
    counts = []
    
    down_and_dirty = lambda {|code|
      next unless code and code.aaseq #skip ncRNA and stuff
      my_bin = []
      my_counts = []
      # calculate stuffs
      aaseq = code.aaseq
      l = aaseq.length
      tmds = TmHmmWrapper.new.calculate(aaseq)
      
       (0..(aaseq.length-1)).each do |i|
        index = i.to_f/l.to_f*100
        if tmds.residue_number_contained?(i+1)
          my_bin[index] ||= 0
          my_bin[index] += 1
        end
        my_counts[index] ||= 0
        my_counts[index] += 1
      end
      [my_bin, my_counts]
    }
    
    # Abuse the modular counter
    if species_name.nil?
      $stdin.each do |line|
        name = line.strip.gsub('"','')
        code = CodingRegion.ff(name)
        if code.nil?
          $stderr.puts "Couldn't find #{name}, ignoring"
          next
        end
        normaliser_plumbing(bins, counts, code, &down_and_dirty)
      end
    else
      CodingRegion.s(species_name).all(:joins => :amino_acid_sequence).each do |code|
        next if code.cruft?
        normaliser_plumbing(bins, counts, code, &down_and_dirty)
      end
    end
    
    # Output
    values = []
    bins.each_with_index do |h, i|
      values[i] = h.to_f/counts[i].to_f
    end
    puts values.join("\n")
    $stderr.puts "Included #{counts.max} proteins"
  end
  
  def pka_profile(species_name=nil)
    puts "PKAs"
    bins = []
    counts = []
    
    down_and_dirty = lambda {|code|
      next unless code and code.aaseq #skip ncRNA and stuff
      my_bin = []
      my_counts = []
      # return hydropathy and counts
      l = code.aaseq.length
      pro = Hydrophobicity.new.profile(code.aaseq, Hydrophobicity::PKA)
      pro.each_with_index do |h,i|
        next if i==0 #ignore the first residue
        next if h.nil? #ignore X's
        index = i.to_f/l.to_f*100
        my_bin[index] ||= 0
        my_bin[index] += h
        my_counts[index] ||= 0
        my_counts[index] += 1
      end
      [my_bin, my_counts]
    }
    
    # Abuse the modular counter
    if species_name.nil?
      $stdin.each do |line|
        name = line.strip.gsub('"','')
        code = CodingRegion.ff(name)
        if code.nil?
          $stderr.puts "Couldn't find #{name}, ignoring"
          next
        end
        normaliser_plumbing(bins, counts, code, &down_and_dirty)
      end
    else
      CodingRegion.s(species_name).all(:joins => :amino_acid_sequence).each do |code|
        next if code.cruft?
        normaliser_plumbing(bins, counts, code, &down_and_dirty)
      end
    end
    
    # Output
    values = []
    bins.each_with_index do |h, i|
      puts [
      h.to_f/counts[i].to_f,
      h,
      counts[i]
      ].join("\t")
    end
    $stderr.puts "Included #{counts.max} proteins"
  end
end