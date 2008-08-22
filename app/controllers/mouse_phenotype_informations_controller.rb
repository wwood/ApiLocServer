class MousePhenotypeInformationsController < ApplicationController
  # GET /mouse_phenotype_informations
  # GET /mouse_phenotype_informations.xml
  def index
    @mouse_phenotype_informations = MousePhenotypeInformation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mouse_phenotype_informations }
    end
  end

  # GET /mouse_phenotype_informations/1
  # GET /mouse_phenotype_informations/1.xml
  def show
    @mouse_phenotype_information = MousePhenotypeInformation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mouse_phenotype_information }
    end
  end

  # GET /mouse_phenotype_informations/new
  # GET /mouse_phenotype_informations/new.xml
  def new
    @mouse_phenotype_information = MousePhenotypeInformation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mouse_phenotype_information }
    end
  end

  # GET /mouse_phenotype_informations/1/edit
  def edit
    @mouse_phenotype_information = MousePhenotypeInformation.find(params[:id])
  end

  # POST /mouse_phenotype_informations
  # POST /mouse_phenotype_informations.xml
  def create
    @mouse_phenotype_information = MousePhenotypeInformation.new(params[:mouse_phenotype_information])

    respond_to do |format|
      if @mouse_phenotype_information.save
        flash[:notice] = 'MousePhenotypeInformation was successfully created.'
        format.html { redirect_to(@mouse_phenotype_information) }
        format.xml  { render :xml => @mouse_phenotype_information, :status => :created, :location => @mouse_phenotype_information }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mouse_phenotype_information.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mouse_phenotype_informations/1
  # PUT /mouse_phenotype_informations/1.xml
  def update
    @mouse_phenotype_information = MousePhenotypeInformation.find(params[:id])

    respond_to do |format|
      if @mouse_phenotype_information.update_attributes(params[:mouse_phenotype_information])
        flash[:notice] = 'MousePhenotypeInformation was successfully updated.'
        format.html { redirect_to(@mouse_phenotype_information) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mouse_phenotype_information.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mouse_phenotype_informations/1
  # DELETE /mouse_phenotype_informations/1.xml
  def destroy
    @mouse_phenotype_information = MousePhenotypeInformation.find(params[:id])
    @mouse_phenotype_information.destroy

    respond_to do |format|
      format.html { redirect_to(mouse_phenotype_informations_url) }
      format.xml  { head :ok }
    end
  end
end
