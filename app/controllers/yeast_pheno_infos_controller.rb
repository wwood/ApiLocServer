class YeastPhenoInfosController < ApplicationController
  # GET /yeast_pheno_infos
  # GET /yeast_pheno_infos.xml
  def index
    @yeast_pheno_infos = YeastPhenoInfo.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @yeast_pheno_infos }
    end
  end

  # GET /yeast_pheno_infos/1
  # GET /yeast_pheno_infos/1.xml
  def show
    @yeast_pheno_info = YeastPhenoInfo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @yeast_pheno_info }
    end
  end

  # GET /yeast_pheno_infos/new
  # GET /yeast_pheno_infos/new.xml
  def new
    @yeast_pheno_info = YeastPhenoInfo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @yeast_pheno_info }
    end
  end

  # GET /yeast_pheno_infos/1/edit
  def edit
    @yeast_pheno_info = YeastPhenoInfo.find(params[:id])
  end

  # POST /yeast_pheno_infos
  # POST /yeast_pheno_infos.xml
  def create
    @yeast_pheno_info = YeastPhenoInfo.new(params[:yeast_pheno_info])

    respond_to do |format|
      if @yeast_pheno_info.save
        flash[:notice] = 'YeastPhenoInfo was successfully created.'
        format.html { redirect_to(@yeast_pheno_info) }
        format.xml  { render :xml => @yeast_pheno_info, :status => :created, :location => @yeast_pheno_info }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @yeast_pheno_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /yeast_pheno_infos/1
  # PUT /yeast_pheno_infos/1.xml
  def update
    @yeast_pheno_info = YeastPhenoInfo.find(params[:id])

    respond_to do |format|
      if @yeast_pheno_info.update_attributes(params[:yeast_pheno_info])
        flash[:notice] = 'YeastPhenoInfo was successfully updated.'
        format.html { redirect_to(@yeast_pheno_info) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @yeast_pheno_info.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /yeast_pheno_infos/1
  # DELETE /yeast_pheno_infos/1.xml
  def destroy
    @yeast_pheno_info = YeastPhenoInfo.find(params[:id])
    @yeast_pheno_info.destroy

    respond_to do |format|
      format.html { redirect_to(yeast_pheno_infos_url) }
      format.xml  { head :ok }
    end
  end
end
