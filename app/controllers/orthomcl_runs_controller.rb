class OrthomclRunsController < ApplicationController

  # GET /orthomcl_groups
  # GET /orthomcl_groups.xml
  def show
    @orthomcl_run = OrthomclRun.find(params[:id])
    
    @orthomcl_groups = @orthomcl_run.orthomcl_groups

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orthomcl_groups }
    end
  end
  
    # GET /orthomcl_groups
  # GET /orthomcl_groups.xml
  def index
    @orthomcl_runs = OrthomclRun.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @orthomcl_groups }
    end
  end
end
