class MverificationsController < ApplicationController
  # GET /mverifications
  # GET /mverifications.xml
  def index
    @mverifications = Mverification.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mverifications }
    end
  end

  # GET /mverifications/1
  # GET /mverifications/1.xml
  def show
    @mverification = Mverification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @mverification }
    end
  end

  # GET /mverifications/new
  # GET /mverifications/new.xml
  def new
    @mverification = Mverification.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @mverification }
    end
  end

  # GET /mverifications/1/edit
  def edit
    @mverification = Mverification.find(params[:id])
  end

  # POST /mverifications
  # POST /mverifications.xml
  def create
    @mverification = Mverification.new(params[:mverification])

    respond_to do |format|
      if @mverification.save
        flash[:notice] = 'Mverification was successfully created.'
        format.html { redirect_to(@mverification) }
        format.xml  { render :xml => @mverification, :status => :created, :location => @mverification }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @mverification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /mverifications/1
  # PUT /mverifications/1.xml
  def update
    @mverification = Mverification.find(params[:id])

    respond_to do |format|
      if @mverification.update_attributes(params[:mverification])
        flash[:notice] = 'Mverification was successfully updated.'
        format.html { redirect_to(@mverification) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @mverification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /mverifications/1
  # DELETE /mverifications/1.xml
  def destroy
    @mverification = Mverification.find(params[:id])
    @mverification.destroy

    respond_to do |format|
      format.html { redirect_to(mverifications_url) }
      format.xml  { head :ok }
    end
  end
end
