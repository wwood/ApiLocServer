class GoAlternatesController < ApplicationController
  # GET /go_alternates
  # GET /go_alternates.xml
  def index
    @go_alternates = GoAlternate.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @go_alternates }
    end
  end

  # GET /go_alternates/1
  # GET /go_alternates/1.xml
  def show
    @go_alternate = GoAlternate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @go_alternate }
    end
  end

  # GET /go_alternates/new
  # GET /go_alternates/new.xml
  def new
    @go_alternate = GoAlternate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @go_alternate }
    end
  end

  # GET /go_alternates/1/edit
  def edit
    @go_alternate = GoAlternate.find(params[:id])
  end

  # POST /go_alternates
  # POST /go_alternates.xml
  def create
    @go_alternate = GoAlternate.new(params[:go_alternate])

    respond_to do |format|
      if @go_alternate.save
        flash[:notice] = 'GoAlternate was successfully created.'
        format.html { redirect_to(@go_alternate) }
        format.xml  { render :xml => @go_alternate, :status => :created, :location => @go_alternate }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @go_alternate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /go_alternates/1
  # PUT /go_alternates/1.xml
  def update
    @go_alternate = GoAlternate.find(params[:id])

    respond_to do |format|
      if @go_alternate.update_attributes(params[:go_alternate])
        flash[:notice] = 'GoAlternate was successfully updated.'
        format.html { redirect_to(@go_alternate) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @go_alternate.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /go_alternates/1
  # DELETE /go_alternates/1.xml
  def destroy
    @go_alternate = GoAlternate.find(params[:id])
    @go_alternate.destroy

    respond_to do |format|
      format.html { redirect_to(go_alternates_url) }
      format.xml  { head :ok }
    end
  end
end
