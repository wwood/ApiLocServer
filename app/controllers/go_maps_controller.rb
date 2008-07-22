class GoMapsController < ApplicationController
  # GET /go_maps
  # GET /go_maps.xml
  def index
    @go_maps = GoMap.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @go_maps }
    end
  end

  # GET /go_maps/1
  # GET /go_maps/1.xml
  def show
    @go_map = GoMap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @go_map }
    end
  end

  # GET /go_maps/new
  # GET /go_maps/new.xml
  def new
    @go_map = GoMap.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @go_map }
    end
  end

  # GET /go_maps/1/edit
  def edit
    @go_map = GoMap.find(params[:id])
  end

  # POST /go_maps
  # POST /go_maps.xml
  def create
    @go_map = GoMap.new(params[:go_map])

    respond_to do |format|
      if @go_map.save
        flash[:notice] = 'GoMap was successfully created.'
        format.html { redirect_to(@go_map) }
        format.xml  { render :xml => @go_map, :status => :created, :location => @go_map }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @go_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /go_maps/1
  # PUT /go_maps/1.xml
  def update
    @go_map = GoMap.find(params[:id])

    respond_to do |format|
      if @go_map.update_attributes(params[:go_map])
        flash[:notice] = 'GoMap was successfully updated.'
        format.html { redirect_to(@go_map) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @go_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /go_maps/1
  # DELETE /go_maps/1.xml
  def destroy
    @go_map = GoMap.find(params[:id])
    @go_map.destroy

    respond_to do |format|
      format.html { redirect_to(go_maps_url) }
      format.xml  { head :ok }
    end
  end
end
