class CodingRegionsController < ApplicationController
  
  def upload
    Script.new.upload_hardy
    render :index
  end
  
  # GET /coding_regions
  # GET /coding_regions.xml
  def index
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
      @coding_regions = CodingRegion.all(
        :include => [:annotation, :coding_region_alternate_string_ids,
          {:gene => {:scaffold => :species}}
        ],
        :conditions => ['(coding_regions.string_id like ? or annotations.annotation like ? or coding_region_alternate_string_ids.name like ?) and species.name = ?',
          q2, q2, q2, Species.falciparum_name
        ]
      )
    end
  end
  
  
  def orthomcl
    q = params[:coding_region]['name']
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
      end    
    end
  end

  # GET /coding_regions/1
  # GET /coding_regions/1.xml
  def show
    @coding_region = CodingRegion.find(params[:id])

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
end
