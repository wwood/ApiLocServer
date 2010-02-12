class ApilocController < ApplicationController
  APILOC_CACHES = [
    :index,
    :species,
    :gene,
    :microscopy,
    :developmental_stage
  ]
  
  # Define each of the caches
  APILOC_CACHES.each do |c|
    if c == :gene
      caches_page c
    else
      caches_page c
    end
  end
  
  # sweeper so caches don't get in the way
  cache_sweeper :apiloc_sweeper
  
  
  def index
  end
  
  def gene
    gene_id = params[:id]
    gene_id += ".#{params[:id2]}" unless params[:id2].nil?
    gene_id += ".#{params[:id3]}" unless params[:id3].nil?
    
    if !gene_id
      flash[:error] = "Unknown gene id '#{gene_id}'."
      logger.debug "Unknown gene id '#{gene_id}'."
      redirect_to :action => :index
      return
    end
    
    codes = nil
    if params[:species]
      codes = CodingRegion.find_all_by_name_or_alternate_and_species_maybe_with_species_prefix(gene_id, params[:species])
    else
      codes = CodingRegion.find_all_by_name_or_alternate_maybe_with_species_prefix(gene_id)
      if codes.empty?
        codes = CodingRegion.all(
          :joins => [:annotation, :coding_region_alternate_string_ids],
          :select => 'distinct(coding_regions.*)',
          :conditions => [
            'annotations.annotation like ? or coding_region_alternate_string_ids.name like ?',
            "%#{gene_id}%", "%#{gene_id}%"
        ]
        )
      end
    end
    
    # possible problem here - what happens for legitimately conflicting names like PfSPP?
    unless codes.length == 1
      @gene_id = gene_id
      @codes = codes.sort{|a,b| a.string_id <=> b.string_id}
      render :action => :choose_species
      return
    end
    
    @code = codes[0]
  end
  
  def publication
    myed = params[:id]
    @publication = Publication.find_by_pubmed_id(myed.to_i)
    @publication ||= Publication.find_by_url(myed)
    if @publication.nil?
      flash[:error] = "no publication found by the pubmed or URL '#{myed}'"
      redirect_to :action => :index
    end
  end
  
  def localisation
    params[:id].downcase! if params[:id] == 'Golgi apparatus' #damn case-sensitive
    if params[:id]
      @top_level_localisation = TopLevelLocalisation.find_by_name(params[:id])
      if @top_level_localisation.nil?
        flash[:error] = "No umbrella localisation found by the name of '#{params[:id]}'"
      else
        @localisations = @top_level_localisation.apiloc_localisations.all(
          :joins => :expression_contexts
        )
        render :action => :localisation_show
      end
    end
  end
  
  # low level localisation
  def specific_localisation
    params[:id].downcase! if params[:id] == 'Golgi apparatus' #damn case-sensitive
    @localisations = Localisation.find_all_by_name(params[:id])
    if @localisations.empty? and params[:format]
      @localisations = Localisation.find_all_by_name("#{params[:id]}.#{params[:format]}")
      params[:format] = 'html'
    end
    # get rid of cases where the dev stage is defined but there isn't any
    # more genes localised there
    @localisations = @localisations.select do |d|
      ExpressionContext.count(:conditions => ['localisation_id = ?',d.id])>0
    end
    raise Exception, "No localisations found by the name of '#{params[:id]}'" if @localisations.length == 0
  end
  
  
  # high level dev stage
  def developmental_stage
    if params[:id]
      @top_level_developmental_stage = TopLevelDevelopmentalStage.find_by_name(params[:id])
      if @top_level_developmental_stage.nil?
        flash[:error] = "No umbrella developmental stage found by the name of '#{params[:id]}'"
      else
        @developmental_stages = @top_level_developmental_stage.developmental_stages.all(
          :joins => :expression_contexts
        )
        render :action => :developmental_stage_show
      end
    end
  end
  
  # low level dev stage
  def specific_developmental_stage
    @developmental_stages = DevelopmentalStage.find_all_by_name(params[:id])
    if @developmental_stages.empty? and params[:format]
      @developmental_stages = DevelopmentalStage.find_all_by_name("#{params[:id]}.#{params[:format]}")
      params[:format] = 'html'
    end
    # get rid of cases where the dev stage is defined but there isn't any
    # more genes localised there
    @developmental_stages = @developmental_stages.select do |d|
      ExpressionContext.count(:conditions => ['developmental_stage_id = ?',d.id])>0
    end
    raise Exception, "No localisations found by the name of '#{params[:id]}'" if @developmental_stages.length == 0
  end
  
  def acknowledgements
  end
  
  def species
    name = params[:id]
    @species = Species.find_by_name(name)
    if @species.nil?
      unless name.nil?
        flash[:error] = "Could not find a species by the name of '#{name}'"
      end
      redirect_to :action => :index and return
    end
    
    # build up the query using named_scopes
    @localisations = TopLevelLocalisation
    if params[:negative] == 'true'
      @viewing_positive_localisations = false
      @localisations = @localisations.negative
    else
      @viewing_positive_localisations = true
      @localisations = @localisations.positive
    end
    
    @localisations = @localisations.all(
      :joins => {:apiloc_localisations => {:expression_contexts => {:coding_region => {:gene => :scaffold}}}},
      :conditions => ['scaffolds.species_id = ?',
    @species.id
    ],
      :select => 'distinct(top_level_localisations.*)'
    )
  end
  
  def proteome
    name = params[:id]
    name += ".#{params[:id2]}" unless params[:id2].nil?
    if name.nil?
      render :action => :index
    end
    
    @experiment = ProteomicExperiment.find_by_name(name)
    if @experiment.nil?
      flash[:error] = "No proteomic experiment found called '#{name}'"
      render :action => :index
    end
    @publication = @experiment.publication
  end
  
  def microscopy
    @name = params[:id]
    scopes = LocalisationAnnotation::POPULAR_MICROSCOPY_TYPE_NAME_SCOPE[@name]
    if scopes.nil?
      flash[:error] = "No microscopy type '#{@name}' found"
      render :action => :index
      return
    end
    done = LocalisationAnnotation
    scopes.each do |scope|
      done = done.send(scope)
    end
    @annotations = done.all
    
    # Separate each of the coding regions by species
    @coding_regions_by_species = {}
    @annotations.each do |a|
      species_name = a.coding_region.species
      @coding_regions_by_species[species_name] ||= []
      code = a.coding_region
      @coding_regions_by_species[species_name].push code unless @coding_regions_by_species[species_name].include?(code)
    end
  end
end
