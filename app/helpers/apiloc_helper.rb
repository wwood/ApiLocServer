module ApilocHelper
  def popular_localisations
    [
      'apicoplast',
      'mitochondrion',
      'nucleus',
      'exported',
      'apical',
      'endoplasmic reticulum',
      'Golgi apparatus',
      'inner membrane complex',
      Localisation::CYTOPLASM_NOT_ORGANELLAR_PUBLIC_NAME,
      'food vacuole',
      'parasite plasma membrane',
      'other'
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
  
  def unpopular_developmental_stages
    TopLevelDevelopmentalStage.positive.all(
      :conditions => ['name not in (?)',
    popular_developmental_stages
    ]
    ).reach.name.sort
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
      ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_NAME,
      ProteomicExperiment::FALCIPARUM_GAMETOCYTOGENESIS_2010_TROPHOZOITE_NAME,
      ProteomicExperiment::FALCIPARUM_GAMETOCYTOGENESIS_2010_GAMETOCYTE_STAGE_I_AND_II_NAME,
      ProteomicExperiment::FALCIPARUM_GAMETOCYTOGENESIS_2010_GAMETOCYTE_STAGE_V_NAME
      ],
      Species::TOXOPLASMA_GONDII_NAME =>
      ProteomicExperiment::TOXOPLASMA_NAME_TO_PUBLICATION_HASH.keys.sort
    }
    
    pros = nil
    if species_name.nil?
      pros = hash.values.flatten
    else
      pros = hash[species_name]
    end
    
    return [] unless pros
    return pros.collect do |name|
      pro = ProteomicExperiment.find_by_name(name)
      logger.error "Couldn't find proteomic experiment called '#{name}'" unless pro
      pro
      end.no_nils
    end
    
    def proteomic_experiment_name_to_html_link(name)
      html_name = proteomic_experiment_name_to_italics(name)
      return(link_to html_name, :controller => :apiloc, :action => :proteome, :id => name)
    end
    
    def proteomic_experiment_name_to_italics(name)
      # assume the first 2 words are the species
      splits = name.split(' ')
    "<i>#{splits[0]} #{splits[1]}</i> #{splits[2..(splits.length-1)].join(' ')}"
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
