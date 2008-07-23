class DrosophilaAllelePhenotypesController < ApplicationController
  # GET /drosophila_allele_phenotypes
  # GET /drosophila_allele_phenotypes.xml
  def index
    @drosophila_allele_phenotypes = DrosophilaAllelePhenotype.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @drosophila_allele_phenotypes }
    end
  end

  # GET /drosophila_allele_phenotypes/1
  # GET /drosophila_allele_phenotypes/1.xml
  def show
    @drosophila_allele_phenotype = DrosophilaAllelePhenotype.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @drosophila_allele_phenotype }
    end
  end

  # GET /drosophila_allele_phenotypes/new
  # GET /drosophila_allele_phenotypes/new.xml
  def new
    @drosophila_allele_phenotype = DrosophilaAllelePhenotype.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @drosophila_allele_phenotype }
    end
  end

  # GET /drosophila_allele_phenotypes/1/edit
  def edit
    @drosophila_allele_phenotype = DrosophilaAllelePhenotype.find(params[:id])
  end

  # POST /drosophila_allele_phenotypes
  # POST /drosophila_allele_phenotypes.xml
  def create
    @drosophila_allele_phenotype = DrosophilaAllelePhenotype.new(params[:drosophila_allele_phenotype])

    respond_to do |format|
      if @drosophila_allele_phenotype.save
        flash[:notice] = 'DrosophilaAllelePhenotype was successfully created.'
        format.html { redirect_to(@drosophila_allele_phenotype) }
        format.xml  { render :xml => @drosophila_allele_phenotype, :status => :created, :location => @drosophila_allele_phenotype }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @drosophila_allele_phenotype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /drosophila_allele_phenotypes/1
  # PUT /drosophila_allele_phenotypes/1.xml
  def update
    @drosophila_allele_phenotype = DrosophilaAllelePhenotype.find(params[:id])

    respond_to do |format|
      if @drosophila_allele_phenotype.update_attributes(params[:drosophila_allele_phenotype])
        flash[:notice] = 'DrosophilaAllelePhenotype was successfully updated.'
        format.html { redirect_to(@drosophila_allele_phenotype) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @drosophila_allele_phenotype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /drosophila_allele_phenotypes/1
  # DELETE /drosophila_allele_phenotypes/1.xml
  def destroy
    @drosophila_allele_phenotype = DrosophilaAllelePhenotype.find(params[:id])
    @drosophila_allele_phenotype.destroy

    respond_to do |format|
      format.html { redirect_to(drosophila_allele_phenotypes_url) }
      format.xml  { head :ok }
    end
  end
end
