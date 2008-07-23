class PhenotypeInformationsController < ApplicationController
  # GET /phenotype_informations
  # GET /phenotype_informations.xml
  def index
    @phenotype_informations = PhenotypeInformation.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phenotype_informations }
    end
  end

  # GET /phenotype_informations/1
  # GET /phenotype_informations/1.xml
  def show
    @phenotype_information = PhenotypeInformation.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phenotype_information }
    end
  end

  # GET /phenotype_informations/new
  # GET /phenotype_informations/new.xml
  def new
    @phenotype_information = PhenotypeInformation.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phenotype_information }
    end
  end

  # GET /phenotype_informations/1/edit
  def edit
    @phenotype_information = PhenotypeInformation.find(params[:id])
  end

  # POST /phenotype_informations
  # POST /phenotype_informations.xml
  def create
    @phenotype_information = PhenotypeInformation.new(params[:phenotype_information])

    respond_to do |format|
      if @phenotype_information.save
        flash[:notice] = 'PhenotypeInformation was successfully created.'
        format.html { redirect_to(@phenotype_information) }
        format.xml  { render :xml => @phenotype_information, :status => :created, :location => @phenotype_information }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phenotype_information.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phenotype_informations/1
  # PUT /phenotype_informations/1.xml
  def update
    @phenotype_information = PhenotypeInformation.find(params[:id])

    respond_to do |format|
      if @phenotype_information.update_attributes(params[:phenotype_information])
        flash[:notice] = 'PhenotypeInformation was successfully updated.'
        format.html { redirect_to(@phenotype_information) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phenotype_information.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phenotype_informations/1
  # DELETE /phenotype_informations/1.xml
  def destroy
    @phenotype_information = PhenotypeInformation.find(params[:id])
    @phenotype_information.destroy

    respond_to do |format|
      format.html { redirect_to(phenotype_informations_url) }
      format.xml  { head :ok }
    end
  end
end
