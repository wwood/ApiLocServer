class BScript
  def gather_prediction_set_for_manual_inspection
    CodingRegion.falciparum.all(
    :select => 'distinct(coding_regions.*)',
    :joins => :expressed_localisations
    ).each do |code|
      next if code.string_id == 'A common gene for all genes not assigned to a gene model'
      puts [
        code.string_id,
        code.literature_defined_coding_region_alternate_string_ids.reach.name.uniq.join(', '),
        code.annotation.annotation,
        code.topsa.uniq.reject{|a| a.negative?}.reach.name.join(', '),
        code.localisation_english
      ].join("\t")
    end
  end
end