class GoTermsController < ApplicationController
  # GET /go_terms
  # GET /go_terms.xml
  def index
    @go_terms = GoTerm.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @go_terms }
    end
  end

  # GET /go_terms/1
  # GET /go_terms/1.xml
  def show
    @go_term = GoTerm.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @go_term }
    end
  end

  # GET /go_terms/new
  # GET /go_terms/new.xml
  def new
    @go_term = GoTerm.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @go_term }
    end
  end

  # GET /go_terms/1/edit
  def edit
    @go_term = GoTerm.find(params[:id])
  end

  # POST /go_terms
  # POST /go_terms.xml
  def create
    @go_term = GoTerm.new(params[:go_term])

    respond_to do |format|
      if @go_term.save
        flash[:notice] = 'GoTerm was successfully created.'
        format.html { redirect_to(@go_term) }
        format.xml  { render :xml => @go_term, :status => :created, :location => @go_term }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @go_term.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /go_terms/1
  # PUT /go_terms/1.xml
  def update
    @go_term = GoTerm.find(params[:id])

    respond_to do |format|
      if @go_term.update_attributes(params[:go_term])
        flash[:notice] = 'GoTerm was successfully updated.'
        format.html { redirect_to(@go_term) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @go_term.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /go_terms/1
  # DELETE /go_terms/1.xml
  def destroy
    @go_term = GoTerm.find(params[:id])
    @go_term.destroy

    respond_to do |format|
      format.html { redirect_to(go_terms_url) }
      format.xml  { head :ok }
    end
  end
end
