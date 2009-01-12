class TopLevelLocalisationsController < ApplicationController
  # GET /localisations
  # GET /localisations.xml
  def index
    @top_level_localisations = TopLevelLocalisation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @top_level_localisations }
    end
  end

  # GET /localisations/1
  # GET /localisations/1.xml
  def show
    @top_level_localisation = TopLevelLocalisation.find(params[:id])
    @coding_regions = @top_level_localisation.malaria_localisations.all.reach.expressed_coding_regions.retract.flatten.uniq

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @top_level_localisation }
    end
  end

end
