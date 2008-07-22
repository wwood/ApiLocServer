class GoMapEntriesController < ApplicationController
  # GET /go_map_entries
  # GET /go_map_entries.xml
  def index
    @go_map_entries = GoMapEntry.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @go_map_entries }
    end
  end

  # GET /go_map_entries/1
  # GET /go_map_entries/1.xml
  def show
    @go_map_entry = GoMapEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @go_map_entry }
    end
  end

  # GET /go_map_entries/new
  # GET /go_map_entries/new.xml
  def new
    @go_map_entry = GoMapEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @go_map_entry }
    end
  end

  # GET /go_map_entries/1/edit
  def edit
    @go_map_entry = GoMapEntry.find(params[:id])
  end

  # POST /go_map_entries
  # POST /go_map_entries.xml
  def create
    @go_map_entry = GoMapEntry.new(params[:go_map_entry])

    respond_to do |format|
      if @go_map_entry.save
        flash[:notice] = 'GoMapEntry was successfully created.'
        format.html { redirect_to(@go_map_entry) }
        format.xml  { render :xml => @go_map_entry, :status => :created, :location => @go_map_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @go_map_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /go_map_entries/1
  # PUT /go_map_entries/1.xml
  def update
    @go_map_entry = GoMapEntry.find(params[:id])

    respond_to do |format|
      if @go_map_entry.update_attributes(params[:go_map_entry])
        flash[:notice] = 'GoMapEntry was successfully updated.'
        format.html { redirect_to(@go_map_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @go_map_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /go_map_entries/1
  # DELETE /go_map_entries/1.xml
  def destroy
    @go_map_entry = GoMapEntry.find(params[:id])
    @go_map_entry.destroy

    respond_to do |format|
      format.html { redirect_to(go_map_entries_url) }
      format.xml  { head :ok }
    end
  end
end
