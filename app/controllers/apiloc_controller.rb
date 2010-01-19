class ApilocController < ApplicationController
  caches_page :index
  caches_page :species
  caches_page :gene
  caches_page :microscopy
  caches_page :developmental_stage
  
  def index
  end

  def gene
    gene_id = params[:id]
    gene_id += ".#{params[:id2]}" unless params[:id2].nil?
    gene_id += ".#{params[:id3]}" unless params[:id3].nil?

    # This should not ever happen in a static web page.
    if !gene_id
      flash[:error] = "Unknown gene id '#{gene_id}'."
      logger.debug "Unknown gene id '#{gene_id}'."
      render :action => :index
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
      @codes = codes
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
    @localisations = Localisation.find_all_by_name(params[:id],
      :joins => :expression_contexts,
      :select => 'distinct(localisations.*)'
    )
    if @localisations.length == 0
      flash[:error] = "No localisations found by the name of '#{params[:id]}'"
      redirect_to :action => :index
    end
  end

  def developmental_stage
    @developmental_stages = DevelopmentalStage.find_all_by_name(params[:id])
    logger.info params.inspect
    if @developmental_stages.empty? and params[:format]
      @developmental_stages = DevelopmentalStage.find_all_by_name("#{params[:id]}.#{params[:format]}")
      params[:format] = 'html'
    end
    raise Exception, "No localisations found by the name of '#{params[:id]}'" if @developmental_stages.length == 0
  end

  def acknowledgements
  end

  def species
    name = params[:id]
    @species = Species.find_by_name(name)
    if @species.nil?
      params[:error] = "Could not find a species by the name of '#{name}'"
      render :action => :index
    end

    if params[:negative] == 'true'
      @localisations = Localisation.all(
        :joins => {:expression_contexts => {:coding_region => {:gene => {:scaffold => :species}}}},
        :conditions => ['species.id = ? and localisations.name like ?',
          @species.id, 'not %'
        ],
        :select => 'distinct(localisations.*)'
      )
      @viewing_positive_localisations = false
    else
      # only include positive localisations
      @localisations = Localisation.all(
        :joins => {:expression_contexts => {:coding_region => {:gene => {:scaffold => :species}}}},
        :conditions => ['species.id = ? and localisations.name not like ?',
          @species.id, 'not %'
        ],
        :select => 'distinct(localisations.*)'
      )
      @viewing_positive_localisations = true
    end
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
