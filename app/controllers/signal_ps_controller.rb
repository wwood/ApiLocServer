class SignalPsController < ApplicationController
  # GET /signal_ps
  # GET /signal_ps.xml
  def index
    @signal_ps = SignalP.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @signal_ps }
    end
  end

  # GET /signal_ps/1
  # GET /signal_ps/1.xml
  def show
    @signal_p = SignalP.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @signal_p }
    end
  end

  # GET /signal_ps/new
  # GET /signal_ps/new.xml
  def new
    @signal_p = SignalP.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @signal_p }
    end
  end

  # GET /signal_ps/1/edit
  def edit
    @signal_p = SignalP.find(params[:id])
  end

  # POST /signal_ps
  # POST /signal_ps.xml
  def create
    @signal_p = SignalP.new(params[:signal_p])

    respond_to do |format|
      if @signal_p.save
        flash[:notice] = 'SignalP was successfully created.'
        format.html { redirect_to(@signal_p) }
        format.xml  { render :xml => @signal_p, :status => :created, :location => @signal_p }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @signal_p.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /signal_ps/1
  # PUT /signal_ps/1.xml
  def update
    @signal_p = SignalP.find(params[:id])

    respond_to do |format|
      if @signal_p.update_attributes(params[:signal_p])
        flash[:notice] = 'SignalP was successfully updated.'
        format.html { redirect_to(@signal_p) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @signal_p.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /signal_ps/1
  # DELETE /signal_ps/1.xml
  def destroy
    @signal_p = SignalP.find(params[:id])
    @signal_p.destroy

    respond_to do |format|
      format.html { redirect_to(signal_ps_url) }
      format.xml  { head :ok }
    end
  end
end
