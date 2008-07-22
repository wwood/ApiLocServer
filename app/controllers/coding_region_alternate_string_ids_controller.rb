class CodingRegionAlternateStringIdsController < ApplicationController
  # GET /coding_region_alternate_string_ids
  # GET /coding_region_alternate_string_ids.xml
  def index
    @coding_region_alternate_string_ids = CodingRegionAlternateStringIds.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @coding_region_alternate_string_ids }
    end
  end

  # GET /coding_region_alternate_string_ids/1
  # GET /coding_region_alternate_string_ids/1.xml
  def show
    @coding_region_alternate_string_ids = CodingRegionAlternateStringIds.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @coding_region_alternate_string_ids }
    end
  end

  # GET /coding_region_alternate_string_ids/new
  # GET /coding_region_alternate_string_ids/new.xml
  def new
    @coding_region_alternate_string_ids = CodingRegionAlternateStringIds.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @coding_region_alternate_string_ids }
    end
  end

  # GET /coding_region_alternate_string_ids/1/edit
  def edit
    @coding_region_alternate_string_ids = CodingRegionAlternateStringIds.find(params[:id])
  end

  # POST /coding_region_alternate_string_ids
  # POST /coding_region_alternate_string_ids.xml
  def create
    @coding_region_alternate_string_ids = CodingRegionAlternateStringIds.new(params[:coding_region_alternate_string_ids])

    respond_to do |format|
      if @coding_region_alternate_string_ids.save
        flash[:notice] = 'CodingRegionAlternateStringIds was successfully created.'
        format.html { redirect_to(@coding_region_alternate_string_ids) }
        format.xml  { render :xml => @coding_region_alternate_string_ids, :status => :created, :location => @coding_region_alternate_string_ids }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @coding_region_alternate_string_ids.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /coding_region_alternate_string_ids/1
  # PUT /coding_region_alternate_string_ids/1.xml
  def update
    @coding_region_alternate_string_ids = CodingRegionAlternateStringIds.find(params[:id])

    respond_to do |format|
      if @coding_region_alternate_string_ids.update_attributes(params[:coding_region_alternate_string_ids])
        flash[:notice] = 'CodingRegionAlternateStringIds was successfully updated.'
        format.html { redirect_to(@coding_region_alternate_string_ids) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @coding_region_alternate_string_ids.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /coding_region_alternate_string_ids/1
  # DELETE /coding_region_alternate_string_ids/1.xml
  def destroy
    @coding_region_alternate_string_ids = CodingRegionAlternateStringIds.find(params[:id])
    @coding_region_alternate_string_ids.destroy

    respond_to do |format|
      format.html { redirect_to(coding_region_alternate_string_ids_url) }
      format.xml  { head :ok }
    end
  end
end
