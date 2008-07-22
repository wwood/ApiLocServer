class OrthomclGenesController < ApplicationController
  # GET /orthomcl_genes
  # GET /orthomcl_genes.xml
  def index
    @orthomcl_genes = OrthomclGene.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orthomcl_genes }
    end
  end

  # GET /orthomcl_genes/1
  # GET /orthomcl_genes/1.xml
  def show
    @orthomcl_gene = OrthomclGene.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @orthomcl_gene }
    end
  end

  # GET /orthomcl_genes/new
  # GET /orthomcl_genes/new.xml
  def new
    @orthomcl_gene = OrthomclGene.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @orthomcl_gene }
    end
  end

  # GET /orthomcl_genes/1/edit
  def edit
    @orthomcl_gene = OrthomclGene.find(params[:id])
  end

  # POST /orthomcl_genes
  # POST /orthomcl_genes.xml
  def create
    @orthomcl_gene = OrthomclGene.new(params[:orthomcl_gene])

    respond_to do |format|
      if @orthomcl_gene.save
        flash[:notice] = 'OrthomclGene was successfully created.'
        format.html { redirect_to(@orthomcl_gene) }
        format.xml  { render :xml => @orthomcl_gene, :status => :created, :location => @orthomcl_gene }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @orthomcl_gene.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orthomcl_genes/1
  # PUT /orthomcl_genes/1.xml
  def update
    @orthomcl_gene = OrthomclGene.find(params[:id])

    respond_to do |format|
      if @orthomcl_gene.update_attributes(params[:orthomcl_gene])
        flash[:notice] = 'OrthomclGene was successfully updated.'
        format.html { redirect_to(@orthomcl_gene) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @orthomcl_gene.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /orthomcl_genes/1
  # DELETE /orthomcl_genes/1.xml
  def destroy
    @orthomcl_gene = OrthomclGene.find(params[:id])
    @orthomcl_gene.destroy

    respond_to do |format|
      format.html { redirect_to(orthomcl_genes_url) }
      format.xml  { head :ok }
    end
  end
end
