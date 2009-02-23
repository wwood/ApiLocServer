class CodingRegion < ActiveRecord::Base
  def signalp_one_or_zero
    if signal?
      1
    else
      0
    end
  end
  
  def amino_acid_composition
    amino_acid_hash = AminoAcidSequence::AMINO_ACIDS.reach.downcase.to_hash
    mine = []
    amino_acid_sequence.to_bioruby_sequence.composition.each do |aa, count|
      a = aa.downcase
      if amino_acid_hash[a]
        mine[amino_acid_hash[a]] = count.to_f
      end
    end
    # make all the rows the same
    amino_acid_hash.keys.each_with_index do |e, i|
      mine[i] ||=0.0
    end
    return mine
  end
  
  def jeffares_snps
    result = []
    [:it_synonymous_snp, :it_non_synonymous_snp, :pf_clin_synonymous_snp, :pf_clin_non_synonymous_snp].each do |method|
      if s = code.send(method)
        results.push s.value
      else
        results.push nil
      end
    end
    return result
  end
  
  def derisi_3d7
    derisi_timepoints = Microarray.find_by_description(Microarray.derisi_2006_3D7_default).microarray_timepoints(:select => 'distinct(name)', 
      :conditions => ['microarray_timepoints.name = ?', 'Phase']
    )
    results = []
    derisi_timepoints.each do |timepoint|
      measures = MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(
        self.id,
        timepoint.id
      )
      if !measures.nil?
        results.push measures.measurement
      else
        results.push nil
      end
    end
    return results
  end
    
  def gmars_vector(max_gap=3, gmars = GMARS.new)
    t = Time.now
    logger.debug "Starting gMARS for #{string_id} - #{gmars}"
    to_return = aaseq ? gmars.gmars_gapped_vector(aaseq, max_gap) : nil
    logger.debug "Finished running gMARS for #{string_id} (#{(t-Time.now)*1000.0}ms)"
    return to_return
  end

  def length_from_chromosome_end_percent
    l = length_from_chromosome_end
    l.nil? ? nil : l.to_f / gene.scaffold.length.to_f
  end

  def length_from_chromosome_end
    scaffold = gene.scaffold
    return nil unless scaffold and scaffold.length

    return nil if cds.empty?

    # position from start is relative to the 1 position on the scaffold,
    # but the positiion is dependent on the orientation of the gene
    position_from_start = nil
    if positive_orientation?
      position_from_start = cds.first(:order => 'start').start
    else
      position_from_start = cds.first(:order => 'start desc').stop
    end

    position_from_end = scaffold.length - position_from_start

    winner = position_from_start
    if position_from_end < position_from_start
      winner = position_from_end
    end
    return winner
  end

  def chromosome_name
    big = gene.scaffold.name
    if matches = big.match(/apidb\|(.+)/)
      return matches[1]
    else
      return nil
    end
  end

  def second_exon_splice_offset
    return nil unless cds.count > 1
    if positive_orientation?
      return cds.first(:order => 'start').length % 3
    else
      return cds.first(:order => 'start desc').length % 3
    end
  end
  
  def start_of_transcription
    if positive_orientation?
      return cds.first(:order => 'start').start
    else
      return cds.first(:order => 'start desc').stop
    end
  end
  
  def jiangs
    gene.scaffold.jiang_bin_sfp_counts(start_of_transcription)
  end
end