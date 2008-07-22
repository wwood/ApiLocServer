class TaxonNamesController < ApplicationController
  # GET /taxon_names
  # GET /taxon_names.xml
  def index
    @taxon_names = TaxonName.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @taxon_names }
    end
  end

  # GET /taxon_names/1
  # GET /taxon_names/1.xml
  def show
    @taxon_name = TaxonName.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @taxon_name }
    end
  end

  # GET /taxon_names/new
  # GET /taxon_names/new.xml
  def new
    @taxon_name = TaxonName.new
    @taxon_name.name = "ben w"
    @taxon_name.taxon_id = 1;
    @taxon_name.set_defaults
    @taxon_name.save!

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @taxon_name }
    end
  end

  # GET /taxon_names/1/edit
  def edit
    @taxon_name = TaxonName.find(params[:id])
  end

  # POST /taxon_names
  # POST /taxon_names.xml
  def create
    @taxon_name = TaxonName.new(params[:taxon_name])

    respond_to do |format|
      if @taxon_name.save
        flash[:notice] = 'TaxonName was successfully created.'
        format.html { redirect_to(@taxon_name) }
        format.xml  { render :xml => @taxon_name, :status => :created, :location => @taxon_name }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @taxon_name.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /taxon_names/1
  # PUT /taxon_names/1.xml
  def update
    @taxon_name = TaxonName.find(params[:id])

    respond_to do |format|
      if @taxon_name.update_attributes(params[:taxon_name])
        flash[:notice] = 'TaxonName was successfully updated.'
        format.html { redirect_to(@taxon_name) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @taxon_name.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /taxon_names/1
  # DELETE /taxon_names/1.xml
  def destroy
    @taxon_name = TaxonName.find(params[:id])
    @taxon_name.destroy

    respond_to do |format|
      format.html { redirect_to(taxon_names_url) }
      format.xml  { head :ok }
    end
  end
end
