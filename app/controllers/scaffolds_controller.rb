class ScaffoldsController < ApplicationController
  # GET /scaffolds
  # GET /scaffolds.xml
  def index
    @scaffolds = Scaffold.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @scaffolds }
    end
  end

  # GET /scaffolds/1
  # GET /scaffolds/1.xml
  def show
    @scaffold = Scaffold.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @scaffold }
    end
  end

  # GET /scaffolds/new
  # GET /scaffolds/new.xml
  def new
    @scaffold = Scaffold.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @scaffold }
    end
  end

  # GET /scaffolds/1/edit
  def edit
    @scaffold = Scaffold.find(params[:id])
  end

  # POST /scaffolds
  # POST /scaffolds.xml
  def create
    @scaffold = Scaffold.new(params[:scaffold])

    respond_to do |format|
      if @scaffold.save
        flash[:notice] = 'Scaffold was successfully created.'
        format.html { redirect_to(@scaffold) }
        format.xml  { render :xml => @scaffold, :status => :created, :location => @scaffold }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @scaffold.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scaffolds/1
  # PUT /scaffolds/1.xml
  def update
    @scaffold = Scaffold.find(params[:id])

    respond_to do |format|
      if @scaffold.update_attributes(params[:scaffold])
        flash[:notice] = 'Scaffold was successfully updated.'
        format.html { redirect_to(@scaffold) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @scaffold.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scaffolds/1
  # DELETE /scaffolds/1.xml
  def destroy
    @scaffold = Scaffold.find(params[:id])
    @scaffold.destroy

    respond_to do |format|
      format.html { redirect_to(scaffolds_url) }
      format.xml  { head :ok }
    end
  end
end
