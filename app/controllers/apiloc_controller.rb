class ApilocController < ApplicationController
  def index
    raise
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

    codes = CodingRegion.find_all_by_name_or_alternate_maybe_with_species_prefix(gene_id)
    # possible problem here - what happens for legitimately conflicting names like PfSPP?
    unless codes.length == 1
      flash[:error] = "Error: Unexpected number of coding regions for #{gene_id}: #{codes.inspect}"
      logger.debug "Error: Unexpected number of coding regions for #{gene_id}: #{codes.inspect}"
      render :action => :index
      return
    end

    @code = codes[0]
  end

  def publication
    @publication = Publication.find_by_pubmed_id(params[:id])
    @publication ||= Publication.find_by_url(params[:id])
    raise Exception, "no publication found! '#{publication}'" if @publication.nil?
  end

  def localisation
    @localisations = Localisation.find_all_by_name(params[:id])
    raise Exception, "No localisations found by the name of '#{params[:id]}'" if @localisations.length == 0
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
end
