class MousePhenotypeInfosController < ApplicationController
  # GET /mouse_phenotype_infos
  # GET /mouse_phenotype_infos.xml
  def index
    @mouse_phenotype_infos = MousePhenotypeInfo.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mouse_phenotype_infos }
    end
  end

  # GET /mouse_phenotype_infos/1
  # GET /mouse_phenotype_infos/1.xml
  def show
    @mouse_phenotype_info = MousePhenotypeInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mouse_phenotype_info }
    end
  end

  # GET /mouse_phenotype_infos/new
  # GET /mouse_phenotype_infos/new.xml
  def new
    @mouse_phenotype_info = MousePhenotypeInfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mouse_phenotype_info }
    end
  end

  # GET /mouse_phenotype_infos/1/edit
  def edit
    @mouse_phenotype_info = MousePhenotypeInfo.find(params[:id])
  end

  # POST /mouse_phenotype_infos
  # POST /mouse_phenotype_infos.xml
  def create
    @mouse_phenotype_info = MousePhenotypeInfo.new(params[:mouse_phenotype_info])

    respond_to do |format|
      if @mouse_phenotype_info.save
        flash[:notice] = 'MousePhenotypeInfo was successfully created.'
        format.html { redirect_to(@mouse_phenotype_info) }
        format.xml  { render :xml => @mouse_phenotype_info, :status => :created, :location => @mouse_phenotype_info }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mouse_phenotype_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mouse_phenotype_infos/1
  # PUT /mouse_phenotype_infos/1.xml
  def update
    @mouse_phenotype_info = MousePhenotypeInfo.find(params[:id])

    respond_to do |format|
      if @mouse_phenotype_info.update_attributes(params[:mouse_phenotype_info])
        flash[:notice] = 'MousePhenotypeInfo was successfully updated.'
        format.html { redirect_to(@mouse_phenotype_info) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mouse_phenotype_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mouse_phenotype_infos/1
  # DELETE /mouse_phenotype_infos/1.xml
  def destroy
    @mouse_phenotype_info = MousePhenotypeInfo.find(params[:id])
    @mouse_phenotype_info.destroy

    respond_to do |format|
      format.html { redirect_to(mouse_phenotype_infos_url) }
      format.xml  { head :ok }
    end
  end
end
