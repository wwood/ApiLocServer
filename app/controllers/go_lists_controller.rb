class GoListsController < ApplicationController
  # GET /go_lists
  # GET /go_lists.xml
  def index
    @go_lists = GoList.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @go_lists }
    end
  end

  # GET /go_lists/1
  # GET /go_lists/1.xml
  def show
    @go_list = GoList.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @go_list }
    end
  end

  # GET /go_lists/new
  # GET /go_lists/new.xml
  def new
    @go_list = GoList.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @go_list }
    end
  end

  # GET /go_lists/1/edit
  def edit
    @go_list = GoList.find(params[:id])
  end

  # POST /go_lists
  # POST /go_lists.xml
  def create
    @go_list = GoList.new(params[:go_list])

    respond_to do |format|
      if @go_list.save
        flash[:notice] = 'GoList was successfully created.'
        format.html { redirect_to(@go_list) }
        format.xml  { render :xml => @go_list, :status => :created, :location => @go_list }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @go_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /go_lists/1
  # PUT /go_lists/1.xml
  def update
    @go_list = GoList.find(params[:id])

    respond_to do |format|
      if @go_list.update_attributes(params[:go_list])
        flash[:notice] = 'GoList was successfully updated.'
        format.html { redirect_to(@go_list) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @go_list.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /go_lists/1
  # DELETE /go_lists/1.xml
  def destroy
    @go_list = GoList.find(params[:id])
    @go_list.destroy

    respond_to do |format|
      format.html { redirect_to(go_lists_url) }
      format.xml  { head :ok }
    end
  end
end
