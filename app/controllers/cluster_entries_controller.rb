class ClusterEntriesController < ApplicationController
  # GET /cluster_entries
  # GET /cluster_entries.xml
  def index
    @cluster_entries = ClusterEntry.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cluster_entries }
    end
  end

  # GET /cluster_entries/1
  # GET /cluster_entries/1.xml
  def show
    @cluster_entry = ClusterEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cluster_entry }
    end
  end

  # GET /cluster_entries/new
  # GET /cluster_entries/new.xml
  def new
    @cluster_entry = ClusterEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cluster_entry }
    end
  end

  # GET /cluster_entries/1/edit
  def edit
    @cluster_entry = ClusterEntry.find(params[:id])
  end

  # POST /cluster_entries
  # POST /cluster_entries.xml
  def create
    @cluster_entry = ClusterEntry.new(params[:cluster_entry])

    respond_to do |format|
      if @cluster_entry.save
        flash[:notice] = 'ClusterEntry was successfully created.'
        format.html { redirect_to(@cluster_entry) }
        format.xml  { render :xml => @cluster_entry, :status => :created, :location => @cluster_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cluster_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cluster_entries/1
  # PUT /cluster_entries/1.xml
  def update
    @cluster_entry = ClusterEntry.find(params[:id])

    respond_to do |format|
      if @cluster_entry.update_attributes(params[:cluster_entry])
        flash[:notice] = 'ClusterEntry was successfully updated.'
        format.html { redirect_to(@cluster_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cluster_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cluster_entries/1
  # DELETE /cluster_entries/1.xml
  def destroy
    @cluster_entry = ClusterEntry.find(params[:id])
    @cluster_entry.destroy

    respond_to do |format|
      format.html { redirect_to(cluster_entries_url) }
      format.xml  { head :ok }
    end
  end
end
