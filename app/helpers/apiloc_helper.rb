module ApilocHelper
  def popular_localisations
    [
      'apicoplast',
      'mitochondrion',
      'nucleus',
      'exported',
      'endoplasmic reticulum',
      'Golgi apparatus',
      'inner membrane complex',
      'cytoplasm but not organellar',
      'food vacuole',
      'parasite plasma membrane'
    ]
  end

  def popular_developmental_stages
    [
      'ring',
      'trophozoite',
      'schizont',
      'merozoite',
      'gametocyte',
      'sporozoite',
      'tachyzoite',
      'bradyzoite',
    ]
  end

  def popular_microscopy_types
    [
      'Light microscopy using an antibody to protein or part thereof',
      'Light microscopy using an epitope tag',
      'Electron microscopy',
    ]
  end

  def popular_species
    [
      'Plasmodium falciparum',
      'Toxoplasma gondii',
      'Plasmodium berghei',
      'Plasmodium yoelii',
      'Cryptosporidium parvum',
      'Neospora caninum',
    ]
  end

  def code_name(code)
    # must link to the species because otherwise
    # "A common gene for all genes not assigned to a gene model" genes
    # never resolve
    name = "#{link_to code.string_id, :action => :gene, :id => code.string_id, :species => code.species.name}"
    unless code.case_sensitive_literature_defined_coding_region_alternate_string_ids.empty?
      name += " (#{code.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.join(', ')})"
    end
    name
  end

  def code_name_annotation(code)
    # must link to the species because otherwise
    # "A common gene for all genes not assigned to a gene model" genes
    # never resolve
    name = "#{link_to code.string_id, :action => :gene, :id => code.string_id, :species => code.species.name}"
    unless code.case_sensitive_literature_defined_coding_region_alternate_string_ids.empty?
      name += " (#{code.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.join(', ')})"
    end
    unless code.annotation.nil?
      name += " #{code.annotation.annotation}"
    end
    name
  end
end
