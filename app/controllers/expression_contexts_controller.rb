class ExpressionContextsController < ApplicationController
  # GET /expression_contexts
  # GET /expression_contexts.xml
  def index
    @expression_contexts = ExpressionContext.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @expression_contexts }
    end
  end

  # GET /expression_contexts/1
  # GET /expression_contexts/1.xml
  def show
    @expression_context = ExpressionContext.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @expression_context }
    end
  end

  # GET /expression_contexts/new
  # GET /expression_contexts/new.xml
  def new
@coding_region = CodingRegion.f(params[:id])
@species = @coding_region.species
    @expression_context = ExpressionContext.new
@localisations = Localisation.all(:joins => {
:expressed_coding_regions => {:gene => {:scaffold => :species}}},
:conditions => {:species => {:id => @species.id}}
)
@developmental_stages = DevelopmentalStage.all(:joins => {
:expressed_coding_regions => {:gene => {:scaffold => :species}}},
:conditions => {:species => {:id => @species.id}}
)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @expression_context }
    end
  end

  # GET /expression_contexts/1/edit
  def edit
    @expression_context = ExpressionContext.find(params[:id])
  end

  # POST /expression_contexts
  # POST /expression_contexts.xml
  def create
    @expression_context = ExpressionContext.new(params[:expression_context])
    @coding_region = CodingRegion.find(params[:coding_region_id])

    respond_to do |format|
      if @expression_context.save
        flash[:notice] = 'ExpressionContext was successfully created.'
        format.html { redirect_to(@expression_context) }
        format.xml  { render :xml => @expression_context, :status => :created, :location => @expression_context }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @expression_context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /expression_contexts/1
  # PUT /expression_contexts/1.xml
  def update
    @expression_context = ExpressionContext.find(params[:id])

    respond_to do |format|
      if @expression_context.update_attributes(params[:expression_context])
        flash[:notice] = 'ExpressionContext was successfully updated.'
        format.html { redirect_to(@expression_context) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @expression_context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /expression_contexts/1
  # DELETE /expression_contexts/1.xml
  def destroy
    @expression_context = ExpressionContext.find(params[:id])
    @expression_context.destroy

    respond_to do |format|
      format.html { redirect_to(expression_contexts_url) }
      format.xml  { head :ok }
    end
  end
end
