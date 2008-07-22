class CodingRegionLocalisationsController < ApplicationController
  # GET /coding_region_localisations
  # GET /coding_region_localisations.xml
  def index
    @coding_region_localisations = CodingRegionLocalisation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @coding_region_localisations }
    end
  end

  # GET /coding_region_localisations/1
  # GET /coding_region_localisations/1.xml
  def show
    @coding_region_localisation = CodingRegionLocalisation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @coding_region_localisation }
    end
  end

  # GET /coding_region_localisations/new
  # GET /coding_region_localisations/new.xml
  def new
    @coding_region_localisation = CodingRegionLocalisation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @coding_region_localisation }
    end
  end

  # GET /coding_region_localisations/1/edit
  def edit
    @coding_region_localisation = CodingRegionLocalisation.find(params[:id])
  end

  # POST /coding_region_localisations
  # POST /coding_region_localisations.xml
  def create
    @coding_region_localisation = CodingRegionLocalisation.new(params[:coding_region_localisation])

    respond_to do |format|
      if @coding_region_localisation.save
        flash[:notice] = 'CodingRegionLocalisation was successfully created.'
        format.html { redirect_to(@coding_region_localisation) }
        format.xml  { render :xml => @coding_region_localisation, :status => :created, :location => @coding_region_localisation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @coding_region_localisation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /coding_region_localisations/1
  # PUT /coding_region_localisations/1.xml
  def update
    @coding_region_localisation = CodingRegionLocalisation.find(params[:id])

    respond_to do |format|
      if @coding_region_localisation.update_attributes(params[:coding_region_localisation])
        flash[:notice] = 'CodingRegionLocalisation was successfully updated.'
        format.html { redirect_to(@coding_region_localisation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @coding_region_localisation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /coding_region_localisations/1
  # DELETE /coding_region_localisations/1.xml
  def destroy
    @coding_region_localisation = CodingRegionLocalisation.find(params[:id])
    @coding_region_localisation.destroy

    respond_to do |format|
      format.html { redirect_to(coding_region_localisations_url) }
      format.xml  { head :ok }
    end
  end
end
