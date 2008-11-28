class CodingRegion < ActiveRecord::Base
  def signalp_one_or_zero
    if signal?
      1
    else
      0
    end
  end
  
  def amino_acid_composition
    amino_acid_hash = Bio::AminoAcid::Data::NAMES.keys.select{|k| k.length == 1}.reach.downcase.to_hash
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
end