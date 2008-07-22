class GenericGoMapsController < ApplicationController
  # GET /generic_go_maps
  # GET /generic_go_maps.xml
  def index
    @generic_go_maps = GenericGoMap.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @generic_go_maps }
    end
  end

  # GET /generic_go_maps/1
  # GET /generic_go_maps/1.xml
  def show
    @generic_go_map = GenericGoMap.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @generic_go_map }
    end
  end

  # GET /generic_go_maps/new
  # GET /generic_go_maps/new.xml
  def new
    @generic_go_map = GenericGoMap.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @generic_go_map }
    end
  end

  # GET /generic_go_maps/1/edit
  def edit
    @generic_go_map = GenericGoMap.find(params[:id])
  end

  # POST /generic_go_maps
  # POST /generic_go_maps.xml
  def create
    @generic_go_map = GenericGoMap.new(params[:generic_go_map])

    respond_to do |format|
      if @generic_go_map.save
        flash[:notice] = 'GenericGoMap was successfully created.'
        format.html { redirect_to(@generic_go_map) }
        format.xml  { render :xml => @generic_go_map, :status => :created, :location => @generic_go_map }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @generic_go_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /generic_go_maps/1
  # PUT /generic_go_maps/1.xml
  def update
    @generic_go_map = GenericGoMap.find(params[:id])

    respond_to do |format|
      if @generic_go_map.update_attributes(params[:generic_go_map])
        flash[:notice] = 'GenericGoMap was successfully updated.'
        format.html { redirect_to(@generic_go_map) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @generic_go_map.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /generic_go_maps/1
  # DELETE /generic_go_maps/1.xml
  def destroy
    @generic_go_map = GenericGoMap.find(params[:id])
    @generic_go_map.destroy

    respond_to do |format|
      format.html { redirect_to(generic_go_maps_url) }
      format.xml  { head :ok }
    end
  end
end
