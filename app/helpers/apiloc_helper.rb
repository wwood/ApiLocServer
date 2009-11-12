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

  # How was the mapping from the gene in the paper to the gene in the database
  # done.
  def mapping_comments(localisation_annotation)
    if localisation_annotation.gene_mapping_comments
      return localisation_annotation.gene_mapping_comments
    else
      if Species::UNSEQUENCED_APICOMPLEXANS.include?(
          localisation_annotation.coding_region.species.name
        )
        return "#{localisation_annotation.coding_region.string_id} taken directly from publication"
      else
        return 'inferred from another publication'
      end
    end
  end

  def popular_proteomic_experiments(species_name)
    hash = {
      Species::FALCIPARUM_NAME =>
        [
        ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_NAME,
        ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_NAME
      ]
    }
    pros = hash[species_name]
    return [] unless pros
    return pros.collect do |name|
      ProteomicExperiment.find_by_name(name)
    end
  end

  def proteomic_experiment_name_to_html(name)
    hash = {
      ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_NAME =>
        'Food vacuole, Lamarque et al 2008',
      ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_NAME =>
        'Maurer\'s cleft, Vincensini et al 2005'
    }
    return hash[name] if hash[name]
    return name
  end
end
