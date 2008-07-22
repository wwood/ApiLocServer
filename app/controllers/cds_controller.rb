class CdsController < ApplicationController
  # GET /cds
  # GET /cds.xml
  def index
    @cds = Cds.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @cds }
    end
  end

  # GET /cds/1
  # GET /cds/1.xml
  def show
    @cds = Cds.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cds }
    end
  end

  # GET /cds/new
  # GET /cds/new.xml
  def new
    @cds = Cds.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @cds }
    end
  end

  # GET /cds/1/edit
  def edit
    @cds = Cds.find(params[:id])
  end

  # POST /cds
  # POST /cds.xml
  def create
    @cds = Cds.new(params[:cds])

    respond_to do |format|
      if @cds.save
        flash[:notice] = 'Cds was successfully created.'
        format.html { redirect_to(@cds) }
        format.xml  { render :xml => @cds, :status => :created, :location => @cds }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cds.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /cds/1
  # PUT /cds/1.xml
  def update
    @cds = Cds.find(params[:id])

    respond_to do |format|
      if @cds.update_attributes(params[:cds])
        flash[:notice] = 'Cds was successfully updated.'
        format.html { redirect_to(@cds) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @cds.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /cds/1
  # DELETE /cds/1.xml
  def destroy
    @cds = Cds.find(params[:id])
    @cds.destroy

    respond_to do |format|
      format.html { redirect_to(cds_url) }
      format.xml  { head :ok }
    end
  end
end
