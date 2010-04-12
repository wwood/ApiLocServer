class OrthomclGroupsController < ApplicationController
  # GET /orthomcl_groups
  # GET /orthomcl_groups.xml
  def index
    @orthomcl_groups = OrthomclGroup.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orthomcl_groups }
    end
  end

  # GET /orthomcl_groups/1
  # GET /orthomcl_groups/1.xml
  def show
    @orthomcl_group = OrthomclGroup.find_by_orthomcl_name(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @orthomcl_group }
    end
  end

  # GET /orthomcl_groups/new
  # GET /orthomcl_groups/new.xml
  def new
    @orthomcl_group = OrthomclGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @orthomcl_group }
    end
  end

  # GET /orthomcl_groups/1/edit
  def edit
    @orthomcl_group = OrthomclGroup.find(params[:id])
  end

  # POST /orthomcl_groups
  # POST /orthomcl_groups.xml
  def create
    @orthomcl_group = OrthomclGroup.new(params[:orthomcl_group])

    respond_to do |format|
      if @orthomcl_group.save
        flash[:notice] = 'OrthomclGroup was successfully created.'
        format.html { redirect_to(@orthomcl_group) }
        format.xml  { render :xml => @orthomcl_group, :status => :created, :location => @orthomcl_group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @orthomcl_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /orthomcl_groups/1
  # PUT /orthomcl_groups/1.xml
  def update
    @orthomcl_group = OrthomclGroup.find(params[:id])

    respond_to do |format|
      if @orthomcl_group.update_attributes(params[:orthomcl_group])
        flash[:notice] = 'OrthomclGroup was successfully updated.'
        format.html { redirect_to(@orthomcl_group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @orthomcl_group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /orthomcl_groups/1
  # DELETE /orthomcl_groups/1.xml
  def destroy
    @orthomcl_group = OrthomclGroup.find(params[:id])
    @orthomcl_group.destroy

    respond_to do |format|
      format.html { redirect_to(orthomcl_groups_url) }
      format.xml  { head :ok }
    end
  end
end
