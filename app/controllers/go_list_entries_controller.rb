class GoListEntriesController < ApplicationController
  # GET /go_list_entries
  # GET /go_list_entries.xml
  def index
    @go_list_entries = GoListEntry.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @go_list_entries }
    end
  end

  # GET /go_list_entries/1
  # GET /go_list_entries/1.xml
  def show
    @go_list_entry = GoListEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @go_list_entry }
    end
  end

  # GET /go_list_entries/new
  # GET /go_list_entries/new.xml
  def new
    @go_list_entry = GoListEntry.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @go_list_entry }
    end
  end

  # GET /go_list_entries/1/edit
  def edit
    @go_list_entry = GoListEntry.find(params[:id])
  end

  # POST /go_list_entries
  # POST /go_list_entries.xml
  def create
    @go_list_entry = GoListEntry.new(params[:go_list_entry])

    respond_to do |format|
      if @go_list_entry.save
        flash[:notice] = 'GoListEntry was successfully created.'
        format.html { redirect_to(@go_list_entry) }
        format.xml  { render :xml => @go_list_entry, :status => :created, :location => @go_list_entry }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @go_list_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /go_list_entries/1
  # PUT /go_list_entries/1.xml
  def update
    @go_list_entry = GoListEntry.find(params[:id])

    respond_to do |format|
      if @go_list_entry.update_attributes(params[:go_list_entry])
        flash[:notice] = 'GoListEntry was successfully updated.'
        format.html { redirect_to(@go_list_entry) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @go_list_entry.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /go_list_entries/1
  # DELETE /go_list_entries/1.xml
  def destroy
    @go_list_entry = GoListEntry.find(params[:id])
    @go_list_entry.destroy

    respond_to do |format|
      format.html { redirect_to(go_list_entries_url) }
      format.xml  { head :ok }
    end
  end
end
