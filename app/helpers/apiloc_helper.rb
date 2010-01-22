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
    LocalisationAnnotation::POPULAR_MICROSCOPY_TYPE_NAME_SCOPE.keys.sort.reverse
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
    name = "#{link_to code.name, :action => :gene, :id => code.string_id, :species => code.species.name}"
    alts = code.literature_defined_names
    unless alts.empty?
      name += " (#{alts.join(', ')})"
    end
    name
  end

  def code_name_annotation(code)
    # must link to the species because otherwise
    # "A common gene for all genes not assigned to a gene model" genes
    # never resolve
    name = "#{link_to code.name, :action => :gene, :id => code.string_id, :species => code.species.name}"
    alts = code.literature_defined_names
    unless alts.empty?
      name += " (#{alts.join(', ')})"
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

  # Return ProteomicExperiment objects for a given species, or all proteomics
  # experiments if no species is given.
  def popular_proteomic_experiments(species_name=nil)
    hash = {
      Species::FALCIPARUM_NAME =>
        [
        ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_NAME,
        ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_NAME
      ]
    }
    
    pros = nil
    if species_name.nil?
      pros = hash.values.flatten
    else
      pros = hash[species_name]
    end

    return [] unless pros
    return pros.collect do |name|
      ProteomicExperiment.find_by_name(name)
    end
  end

  def proteomic_experiment_name_to_html(name)
    hash = {
      ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_NAME =>
        (link_to 'Food vacuole, Lamarque et al 2008',
        :action => :proteome, :id => ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_NAME
      ),
      ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_NAME =>
        (link_to 'Maurer\'s cleft, Vincensini et al 2005',
        :action => :proteome, :id => ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_NAME
      ),
    }
    return hash[name] if hash[name]
    return name
  end

  # maybe I could do a form or something but eh.
  def apiloc_contact_email_address
    'b.woodcroft@pgrad.unimelb.edu.au'
  end

  def coding_region_localisation_html(coding_region)
    ExpressionContextGroup.new(nil).coalesce(
      coding_region.expression_contexts.collect do |ec|
        LocalisationsAndDevelopmentalStages.new(
          ec.localisation ?
            "<a href='#{url_for :action => :specific_localisation, :id => ec.localisation.name}'>#{ec.localisation.name}</a>" : [],
          ec.developmental_stage ?
            "<a href='#{url_for :action => :specific_developmental_stage, :id => ec.developmental_stage.name}'>#{ec.developmental_stage.name}</a>" : []
        )
      end
    )
  end
end
