class CodingRegionsController < ApplicationController
  
  def upload
    Script.new.upload_hardy
    render :index
  end
  
  # GET /coding_regions
  # GET /coding_regions.xml
  def index
    # obsolete? Useful for catching bugs when script/runner
    # fails uselessly sometimes
    Script.new

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @coding_regions }
    end
  end
  
  def find
    q = params[:coding_region]['string_id']
    CodingRegion.first
    logger.debug "my q: #{q}"
    if !q
      flash[:error] = 'ERROR: No query specified'
      render :action => :index
    else
      q2 = "%#{q}%"
      @coding_regions = CodingRegion.apicomplexan.all(
        :include => [:annotation, :coding_region_alternate_string_ids],
        :conditions => ['(coding_regions.string_id like ? or annotations.annotation like ? or coding_region_alternate_string_ids.name like ?)',
          "%#{q2}%", "%#{q2}%", "%#{q2}%"
        ]
      )
    end
  end
  
  
  def orthomcl
    q = params[:coding_region]['string_id']
    logger.debug "my q: #{q}"
    if !q
      flash[:error] = 'ERROR: No query specified'
      render :action => :index
    else
      @codes = CodingRegion.find_all_by_name_or_alternate(q)
      if  @codes.empty?
        q2 = "%#{q}%"
        @codes = CodingRegion.all(:include => :orthomcl_genes, 
          :conditions => ['orthomcl_genes.orthomcl_name like ?', q2]
        )
        if @codes.empty?
          flash[:error] = "No sequences found matching: #{q}"
          render :action => :index
        end
      end
    end
    
    
  end
  
  def annotate
    parse_string_ids params[:ids]
  end
  
  def export
    parse_string_ids params[:string_ids]
  end

  # GET /coding_regions/1
  # GET /coding_regions/1.xml
  def show
    @coding_region = CodingRegion.f(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @coding_region }
    end
  end

  # GET /coding_regions/new
  # GET /coding_regions/new.xml
  def new
    @coding_region = CodingRegion.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @coding_region }
    end
  end

  # GET /coding_regions/1/edit
  def edit
    @coding_region = CodingRegion.find(params[:id])
  end

  # POST /coding_regions
  # POST /coding_regions.xml
  def create
    @coding_region = CodingRegion.new(params[:coding_region])

    respond_to do |format|
      if @coding_region.save
        flash[:notice] = 'CodingRegion was successfully created.'
        format.html { redirect_to(@coding_region) }
        format.xml  { render :xml => @coding_region, :status => :created, :location => @coding_region }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @coding_region.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /coding_regions/1
  # PUT /coding_regions/1.xml
  def update
    @coding_region = CodingRegion.find(params[:id])

    respond_to do |format|
      if @coding_region.update_attributes(params[:coding_region])
        flash[:notice] = 'CodingRegion was successfully updated.'
        format.html { redirect_to(@coding_region) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @coding_region.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /coding_regions/1
  # DELETE /coding_regions/1.xml
  def destroy
    @coding_region = CodingRegion.find(params[:id])
    @coding_region.destroy

    respond_to do |format|
      format.html { redirect_to(coding_regions_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  # to remove duplication in export and annotate
  def parse_string_ids(string)
    @coding_regions = []
    @coding_regions_not_found = []
    string.split(/[\s\,]+/).each do |string_id|
      code = CodingRegion.f(string_id)
      if code
        @coding_regions.push code
      else
        @coding_regions_not_found.push string_id
      end
    end
    
    if !@coding_regions_not_found.empty?
      flash[:error] = "Could not find coding regions: #{@coding_regions_not_found.join(', ')}"
    end
  end
end
