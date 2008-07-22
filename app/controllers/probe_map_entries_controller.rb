class ProbeMapEntriesController < ApplicationController
  # GET /probe_map_entries
  # GET /probe_map_entries.xml
  def index
    @probe_map_entries = ProbeMapEntry.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @probe_map_entries }
    end
  end

  # GET /probe_map_entries/1
  # GET /probe_map_entries/1.xml
  def show
    @probe_map_entry = ProbeMapEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @probe_map_entry }
    end
  end

  # GET /probe_map_entries/new
  # GET /probe_map_entries/new.xml
  def new
    @probe_map_entry = ProbeMapEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @probe_map_entry }
    end
  end

  # GET /probe_map_entries/1/edit
  def edit
    @probe_map_entry = ProbeMapEntry.find(params[:id])
  end

  # POST /probe_map_entries
  # POST /probe_map_entries.xml
  def create
    @probe_map_entry = ProbeMapEntry.new(params[:probe_map_entry])

    respond_to do |format|
      if @probe_map_entry.save
        flash[:notice] = 'ProbeMapEntry was successfully created.'
        format.html { redirect_to(@probe_map_entry) }
        format.xml  { render :xml => @probe_map_entry, :status => :created, :location => @probe_map_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @probe_map_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /probe_map_entries/1
  # PUT /probe_map_entries/1.xml
  def update
    @probe_map_entry = ProbeMapEntry.find(params[:id])

    respond_to do |format|
      if @probe_map_entry.update_attributes(params[:probe_map_entry])
        flash[:notice] = 'ProbeMapEntry was successfully updated.'
        format.html { redirect_to(@probe_map_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @probe_map_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /probe_map_entries/1
  # DELETE /probe_map_entries/1.xml
  def destroy
    @probe_map_entry = ProbeMapEntry.find(params[:id])
    @probe_map_entry.destroy

    respond_to do |format|
      format.html { redirect_to(probe_map_entries_url) }
      format.xml  { head :ok }
    end
  end
end
