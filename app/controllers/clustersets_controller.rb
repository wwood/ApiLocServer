class ClustersetsController < ApplicationController
  # GET /clustersets
  # GET /clustersets.xml
  def index
    @clustersets = Clusterset.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @clustersets }
    end
  end

  # GET /clustersets/1
  # GET /clustersets/1.xml
  def show
    @clusterset = Clusterset.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @clusterset }
    end
  end

  # GET /clustersets/new
  # GET /clustersets/new.xml
  def new
    @clusterset = Clusterset.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @clusterset }
    end
  end

  # GET /clustersets/1/edit
  def edit
    @clusterset = Clusterset.find(params[:id])
  end

  # POST /clustersets
  # POST /clustersets.xml
  def create
    @clusterset = Clusterset.new(params[:clusterset])

    respond_to do |format|
      if @clusterset.save
        flash[:notice] = 'Clusterset was successfully created.'
        format.html { redirect_to(@clusterset) }
        format.xml  { render :xml => @clusterset, :status => :created, :location => @clusterset }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @clusterset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /clustersets/1
  # PUT /clustersets/1.xml
  def update
    @clusterset = Clusterset.find(params[:id])

    respond_to do |format|
      if @clusterset.update_attributes(params[:clusterset])
        flash[:notice] = 'Clusterset was successfully updated.'
        format.html { redirect_to(@clusterset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @clusterset.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /clustersets/1
  # DELETE /clustersets/1.xml
  def destroy
    @clusterset = Clusterset.find(params[:id])
    @clusterset.destroy

    respond_to do |format|
      format.html { redirect_to(clustersets_url) }
      format.xml  { head :ok }
    end
  end
end
