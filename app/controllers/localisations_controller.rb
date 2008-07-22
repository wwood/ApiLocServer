class LocalisationsController < ApplicationController
  # GET /localisations
  # GET /localisations.xml
  def index
    @localisations = Localisation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @localisations }
    end
  end

  # GET /localisations/1
  # GET /localisations/1.xml
  def show
    @localisation = Localisation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @localisation }
    end
  end

  # GET /localisations/new
  # GET /localisations/new.xml
  def new
    @localisation = Localisation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @localisation }
    end
  end

  # GET /localisations/1/edit
  def edit
    @localisation = Localisation.find(params[:id])
  end

  # POST /localisations
  # POST /localisations.xml
  def create
    @localisation = Localisation.new(params[:localisation])

    respond_to do |format|
      if @localisation.save
        flash[:notice] = 'Localisation was successfully created.'
        format.html { redirect_to(@localisation) }
        format.xml  { render :xml => @localisation, :status => :created, :location => @localisation }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @localisation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /localisations/1
  # PUT /localisations/1.xml
  def update
    @localisation = Localisation.find(params[:id])

    respond_to do |format|
      if @localisation.update_attributes(params[:localisation])
        flash[:notice] = 'Localisation was successfully updated.'
        format.html { redirect_to(@localisation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @localisation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /localisations/1
  # DELETE /localisations/1.xml
  def destroy
    @localisation = Localisation.find(params[:id])
    @localisation.destroy

    respond_to do |format|
      format.html { redirect_to(localisations_url) }
      format.xml  { head :ok }
    end
  end
end
