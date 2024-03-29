class ApilocController < ApplicationController
  APILOC_CACHES = [
    :index,
    :species,
    :gene,
    :microscopy,
    :developmental_stage
  ]
  
  #  I gave up on caches because they weren't really working and just causing problems.
  #  # Define each of the caches
  #  APILOC_CACHES.each do |c|
  #    caches_page c
  #  end
  #  
  #  # sweeper so caches don't get in the way
  #  cache_sweeper :apiloc_sweeper
  
  def index
  end
  
  def gene
    if params[:id].nil? and params[:species].nil?
      redirect_to :action => :index
      return
    end

    gene_id = params[:id]
    # Some gene IDs have dots in them, and rails splits these up. Fix that.
    gene_id += ".#{params[:id2]}" unless params[:id2].nil?
    gene_id += ".#{params[:id3]}" unless params[:id3].nil?
    
    # If a gene ID but not species is given, make it so.
    if params[:species] and gene_id.nil?
      gene_id = params[:species]
      params[:species] = nil
    end
    #whitespace is pernicious, and isn't trailing or initialising gene ids I know of
    gene_id.strip!
    
    codes = []
    if !gene_id or gene_id == ''
      @gene_id = gene_id
      @species_name = params[:species]
      logger.debug "Unknown gene id '#{gene_id}'."
      render :action => :choose_species
    else
      
      # we have a given gene_id
      if params[:species]
        # If given a proper string id, then just match that, and don't try for anything else
        code1 = CodingRegion.species(params[:species]).find_by_string_id(gene_id)
        if code1
          codes = [code1]
        else
          # if agreeable then you might need to remove the species 2 letter,
          # otherwise trust the specifically given species id
          if Species.agreeable_name_and_two_letter_prefix?(params[:species], gene_id)
            codes = CodingRegion.find_all_by_partial_name_or_alternate_and_species_maybe_with_species_prefix(gene_id, params[:species])
          else
            codes = CodingRegion.find_all_by_partial_name_or_alternate_and_species(gene_id, params[:species])
          end
        end
      else
        code1 = CodingRegion.find_by_string_id(gene_id)
        if code1
          codes = [code1]
        else
          codes = CodingRegion.find_all_by_partial_name_or_alternate_maybe_with_species_prefix(gene_id)
        end
      end
    end
    
    # possible problem here - what happens for legitimately conflicting names like PfSPP?
    # Answer - must use (the unique) EuPathDB ids, which are given in the
    # redirected page
    if codes.length == 1
      @code = codes[0]
      
      # redirect non-species specific requests to species-specific ones, because
      # then the caching will be better
      unless params[:species]
        redirect_to :controller => :apiloc, :action => :gene, :species => @code.species.name, :id => @code.string_id
      end
    else
      @gene_id = gene_id
      @codes = codes.sort{|a,b| a.string_id <=> b.string_id}
      @species_name = params[:species]
      render :action => :choose_species
    end
  end
  
  def publication
    myed = params[:id]
    @publication = Publication.find_by_pubmed_id(myed.to_i) #first try PMID, which covers most papers
    @publication ||= Publication.find(myed) #failing that, go with the database ID. Using a URL here is hard for rails routes to work out
    if @publication.nil?
      @publication_id = myed
    end
  end
  
  def localisation
    params[:id].downcase! if params[:id] == 'Golgi apparatus' #damn case-sensitive
    params[:id] = 'cytoplasm' if params[:id] == Localisation::CYTOPLASM_NOT_ORGANELLAR_PUBLIC_NAME
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
    
    # Deal with situations where the localisations are incorrect
    if @localisations.length == 0
      flash[:error] = "No proteins found in the location '#{params[:id]}'"
      render :action => :location_not_found
    end
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
    if params[:negative]
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
    name += ".#{params[:id3]}" unless params[:id3].nil?
    name += ".#{params[:id4]}" unless params[:id4].nil?
    name += ".#{params[:id5]}" unless params[:id5].nil?
    $stderr.puts "`#{name}'"
    name = CGI.unescape name
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
  
  def annotate
    string = params[:ids]
    
    @coding_regions = []
    @coding_regions_not_found = []
    string.split(/[\s\,]+/).each do |string_id|
      code = CodingRegion.f(string_id)
      if code
        @coding_regions.push code
      else
        @coding_regions_not_found.push string_id
      end
    end
  end
end
