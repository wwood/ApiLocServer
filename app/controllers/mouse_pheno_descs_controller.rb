class MousePhenoDescsController < ApplicationController
  # GET /mouse_pheno_descs
  # GET /mouse_pheno_descs.xml
  def index
    @mouse_pheno_descs = MousePhenoDesc.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mouse_pheno_descs }
    end
  end

  # GET /mouse_pheno_descs/1
  # GET /mouse_pheno_descs/1.xml
  def show
    @mouse_pheno_desc = MousePhenoDesc.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mouse_pheno_desc }
    end
  end

  # GET /mouse_pheno_descs/new
  # GET /mouse_pheno_descs/new.xml
  def new
    @mouse_pheno_desc = MousePhenoDesc.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mouse_pheno_desc }
    end
  end

  # GET /mouse_pheno_descs/1/edit
  def edit
    @mouse_pheno_desc = MousePhenoDesc.find(params[:id])
  end

  # POST /mouse_pheno_descs
  # POST /mouse_pheno_descs.xml
  def create
    @mouse_pheno_desc = MousePhenoDesc.new(params[:mouse_pheno_desc])

    respond_to do |format|
      if @mouse_pheno_desc.save
        flash[:notice] = 'MousePhenoDesc was successfully created.'
        format.html { redirect_to(@mouse_pheno_desc) }
        format.xml  { render :xml => @mouse_pheno_desc, :status => :created, :location => @mouse_pheno_desc }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mouse_pheno_desc.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mouse_pheno_descs/1
  # PUT /mouse_pheno_descs/1.xml
  def update
    @mouse_pheno_desc = MousePhenoDesc.find(params[:id])

    respond_to do |format|
      if @mouse_pheno_desc.update_attributes(params[:mouse_pheno_desc])
        flash[:notice] = 'MousePhenoDesc was successfully updated.'
        format.html { redirect_to(@mouse_pheno_desc) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mouse_pheno_desc.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mouse_pheno_descs/1
  # DELETE /mouse_pheno_descs/1.xml
  def destroy
    @mouse_pheno_desc = MousePhenoDesc.find(params[:id])
    @mouse_pheno_desc.destroy

    respond_to do |format|
      format.html { redirect_to(mouse_pheno_descs_url) }
      format.xml  { head :ok }
    end
  end
end
