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
      'sporozoite'
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
      'Plasmodium berghei',
      'Plasmodium vivax',
      'Plasmodium yoelii',
      'Toxoplasma gondii',
    ]
  end

  def code_name(code)
    "#{link_to code.string_id, :action => :gene, :id => code.string_id} (#{code.case_sensitive_literature_defined_coding_region_alternate_string_ids.reach.name.join(', ')})"
  end
end