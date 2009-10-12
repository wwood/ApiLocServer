class ApilocController < ApplicationController
  def index
  end

  def gene
    gene_id = params[:id]
    # This should not ever happen in a static web page.
    if !gene_id
      flash[:error] = "Unknown gene id '#{gene_id}'."
      render :action => :index
      return
    end

    codes = CodingRegion.find_all_by_name_or_alternate(gene_id)
    # possible problem here - what happens for legitimately conflicting names like PfSPP?
    unless codes.length == 1
      flash[:error] = "Error: Unexpected number of coding regions for #{gene_id}: #{codes.inspect}"
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

  def acknowledgements

  end
end
