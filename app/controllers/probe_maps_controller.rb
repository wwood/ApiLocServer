class ProbeMapsController < ApplicationController
  # GET /probe_maps
  # GET /probe_maps.xml
  def index
    @probe_maps = ProbeMap.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @probe_maps }
    end
  end

  # GET /probe_maps/1
  # GET /probe_maps/1.xml
  def show
    @probe_map = ProbeMap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @probe_map }
    end
  end

  # GET /probe_maps/new
  # GET /probe_maps/new.xml
  def new
    @probe_map = ProbeMap.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @probe_map }
    end
  end

  # GET /probe_maps/1/edit
  def edit
    @probe_map = ProbeMap.find(params[:id])
  end

  # POST /probe_maps
  # POST /probe_maps.xml
  def create
    @probe_map = ProbeMap.new(params[:probe_map])

    respond_to do |format|
      if @probe_map.save
        flash[:notice] = 'ProbeMap was successfully created.'
        format.html { redirect_to(@probe_map) }
        format.xml  { render :xml => @probe_map, :status => :created, :location => @probe_map }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @probe_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /probe_maps/1
  # PUT /probe_maps/1.xml
  def update
    @probe_map = ProbeMap.find(params[:id])

    respond_to do |format|
      if @probe_map.update_attributes(params[:probe_map])
        flash[:notice] = 'ProbeMap was successfully updated.'
        format.html { redirect_to(@probe_map) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @probe_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /probe_maps/1
  # DELETE /probe_maps/1.xml
  def destroy
    @probe_map = ProbeMap.find(params[:id])
    @probe_map.destroy

    respond_to do |format|
      format.html { redirect_to(probe_maps_url) }
      format.xml  { head :ok }
    end
  end
end
