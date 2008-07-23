class PhenotypeObservedsController < ApplicationController
  # GET /phenotype_observeds
  # GET /phenotype_observeds.xml
  def index
    @phenotype_observeds = PhenotypeObserved.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @phenotype_observeds }
    end
  end

  # GET /phenotype_observeds/1
  # GET /phenotype_observeds/1.xml
  def show
    @phenotype_observed = PhenotypeObserved.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @phenotype_observed }
    end
  end

  # GET /phenotype_observeds/new
  # GET /phenotype_observeds/new.xml
  def new
    @phenotype_observed = PhenotypeObserved.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @phenotype_observed }
    end
  end

  # GET /phenotype_observeds/1/edit
  def edit
    @phenotype_observed = PhenotypeObserved.find(params[:id])
  end

  # POST /phenotype_observeds
  # POST /phenotype_observeds.xml
  def create
    @phenotype_observed = PhenotypeObserved.new(params[:phenotype_observed])

    respond_to do |format|
      if @phenotype_observed.save
        flash[:notice] = 'PhenotypeObserved was successfully created.'
        format.html { redirect_to(@phenotype_observed) }
        format.xml  { render :xml => @phenotype_observed, :status => :created, :location => @phenotype_observed }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @phenotype_observed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /phenotype_observeds/1
  # PUT /phenotype_observeds/1.xml
  def update
    @phenotype_observed = PhenotypeObserved.find(params[:id])

    respond_to do |format|
      if @phenotype_observed.update_attributes(params[:phenotype_observed])
        flash[:notice] = 'PhenotypeObserved was successfully updated.'
        format.html { redirect_to(@phenotype_observed) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @phenotype_observed.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /phenotype_observeds/1
  # DELETE /phenotype_observeds/1.xml
  def destroy
    @phenotype_observed = PhenotypeObserved.find(params[:id])
    @phenotype_observed.destroy

    respond_to do |format|
      format.html { redirect_to(phenotype_observeds_url) }
      format.xml  { head :ok }
    end
  end
end
