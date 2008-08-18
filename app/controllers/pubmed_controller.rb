class PubmedController < ApplicationController
  def index
  end

  def find
    ids = params[:id]
    @pubs = []
    if !ids
      flash[:error] = "No PubMed IDs Specified"
      render :action => :index
    else
      ids.each do |i|
        m = Bio::MEDLINE.new(Bio::PubMed.query(i.strip))
        @pubs.push m
      end
    end
  end

end
