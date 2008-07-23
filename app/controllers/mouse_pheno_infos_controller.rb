class MousePhenoInfosController < ApplicationController
  # GET /mouse_pheno_infos
  # GET /mouse_pheno_infos.xml
  def index
    @mouse_pheno_infos = MousePhenoInfo.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mouse_pheno_infos }
    end
  end

  # GET /mouse_pheno_infos/1
  # GET /mouse_pheno_infos/1.xml
  def show
    @mouse_pheno_info = MousePhenoInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mouse_pheno_info }
    end
  end

  # GET /mouse_pheno_infos/new
  # GET /mouse_pheno_infos/new.xml
  def new
    @mouse_pheno_info = MousePhenoInfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mouse_pheno_info }
    end
  end

  # GET /mouse_pheno_infos/1/edit
  def edit
    @mouse_pheno_info = MousePhenoInfo.find(params[:id])
  end

  # POST /mouse_pheno_infos
  # POST /mouse_pheno_infos.xml
  def create
    @mouse_pheno_info = MousePhenoInfo.new(params[:mouse_pheno_info])

    respond_to do |format|
      if @mouse_pheno_info.save
        flash[:notice] = 'MousePhenoInfo was successfully created.'
        format.html { redirect_to(@mouse_pheno_info) }
        format.xml  { render :xml => @mouse_pheno_info, :status => :created, :location => @mouse_pheno_info }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mouse_pheno_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mouse_pheno_infos/1
  # PUT /mouse_pheno_infos/1.xml
  def update
    @mouse_pheno_info = MousePhenoInfo.find(params[:id])

    respond_to do |format|
      if @mouse_pheno_info.update_attributes(params[:mouse_pheno_info])
        flash[:notice] = 'MousePhenoInfo was successfully updated.'
        format.html { redirect_to(@mouse_pheno_info) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mouse_pheno_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mouse_pheno_infos/1
  # DELETE /mouse_pheno_infos/1.xml
  def destroy
    @mouse_pheno_info = MousePhenoInfo.find(params[:id])
    @mouse_pheno_info.destroy

    respond_to do |format|
      format.html { redirect_to(mouse_pheno_infos_url) }
      format.xml  { head :ok }
    end
  end
end
