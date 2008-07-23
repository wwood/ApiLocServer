class DrosophilaAlleleGenesController < ApplicationController
  # GET /drosophila_allele_genes
  # GET /drosophila_allele_genes.xml
  def index
    @drosophila_allele_genes = DrosophilaAlleleGene.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @drosophila_allele_genes }
    end
  end

  # GET /drosophila_allele_genes/1
  # GET /drosophila_allele_genes/1.xml
  def show
    @drosophila_allele_gene = DrosophilaAlleleGene.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @drosophila_allele_gene }
    end
  end

  # GET /drosophila_allele_genes/new
  # GET /drosophila_allele_genes/new.xml
  def new
    @drosophila_allele_gene = DrosophilaAlleleGene.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @drosophila_allele_gene }
    end
  end

  # GET /drosophila_allele_genes/1/edit
  def edit
    @drosophila_allele_gene = DrosophilaAlleleGene.find(params[:id])
  end

  # POST /drosophila_allele_genes
  # POST /drosophila_allele_genes.xml
  def create
    @drosophila_allele_gene = DrosophilaAlleleGene.new(params[:drosophila_allele_gene])

    respond_to do |format|
      if @drosophila_allele_gene.save
        flash[:notice] = 'DrosophilaAlleleGene was successfully created.'
        format.html { redirect_to(@drosophila_allele_gene) }
        format.xml  { render :xml => @drosophila_allele_gene, :status => :created, :location => @drosophila_allele_gene }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @drosophila_allele_gene.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /drosophila_allele_genes/1
  # PUT /drosophila_allele_genes/1.xml
  def update
    @drosophila_allele_gene = DrosophilaAlleleGene.find(params[:id])

    respond_to do |format|
      if @drosophila_allele_gene.update_attributes(params[:drosophila_allele_gene])
        flash[:notice] = 'DrosophilaAlleleGene was successfully updated.'
        format.html { redirect_to(@drosophila_allele_gene) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @drosophila_allele_gene.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /drosophila_allele_genes/1
  # DELETE /drosophila_allele_genes/1.xml
  def destroy
    @drosophila_allele_gene = DrosophilaAlleleGene.find(params[:id])
    @drosophila_allele_gene.destroy

    respond_to do |format|
      format.html { redirect_to(drosophila_allele_genes_url) }
      format.xml  { head :ok }
    end
  end
end
