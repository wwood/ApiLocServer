class PlasmodbGeneListsController < ApplicationController
  # GET /plasmodb_gene_lists
  # GET /plasmodb_gene_lists.xml
  def index
    @plasmodb_gene_lists = PlasmodbGeneList.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @plasmodb_gene_lists }
    end
  end

  # GET /plasmodb_gene_lists/1
  # GET /plasmodb_gene_lists/1.xml
  def show
    @plasmodb_gene_list = PlasmodbGeneList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @plasmodb_gene_list }
    end
  end

  # GET /plasmodb_gene_lists/new
  # GET /plasmodb_gene_lists/new.xml
  def new
    @plasmodb_gene_list = PlasmodbGeneList.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @plasmodb_gene_list }
    end
  end

  # GET /plasmodb_gene_lists/1/edit
  def edit
    @plasmodb_gene_list = PlasmodbGeneList.find(params[:id])
  end

  # POST /plasmodb_gene_lists
  # POST /plasmodb_gene_lists.xml
  def create
    @plasmodb_gene_list = PlasmodbGeneList.new(params[:plasmodb_gene_list])

    respond_to do |format|
      if @plasmodb_gene_list.save
        flash[:notice] = 'PlasmodbGeneList was successfully created.'
        format.html { redirect_to(@plasmodb_gene_list) }
        format.xml  { render :xml => @plasmodb_gene_list, :status => :created, :location => @plasmodb_gene_list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @plasmodb_gene_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /plasmodb_gene_lists/1
  # PUT /plasmodb_gene_lists/1.xml
  def update
    @plasmodb_gene_list = PlasmodbGeneList.find(params[:id])

    respond_to do |format|
      if @plasmodb_gene_list.update_attributes(params[:plasmodb_gene_list])
        flash[:notice] = 'PlasmodbGeneList was successfully updated.'
        format.html { redirect_to(@plasmodb_gene_list) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @plasmodb_gene_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /plasmodb_gene_lists/1
  # DELETE /plasmodb_gene_lists/1.xml
  def destroy
    @plasmodb_gene_list = PlasmodbGeneList.find(params[:id])
    @plasmodb_gene_list.destroy

    respond_to do |format|
      format.html { redirect_to(plasmodb_gene_lists_url) }
      format.xml  { head :ok }
    end
  end
end
