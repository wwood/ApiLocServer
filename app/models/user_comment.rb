class UserComment < ActiveRecord::Base
  belongs_to :coding_region
  
  validates_uniqueness_of :number, :scope => :coding_region_id
  
  # make sure that comment number auto-increments.
  # this is possibly buggy if 2 comments get uploaded at the same time
  # (ie it isn't thread safe). But eh.
  def before_validation_on_create
    da_max = UserComment.maximum(:number, :conditions => 
        {
        :coding_region_id => coding_region_id,
      }
    )
    if da_max
      self.number = da_max+1
    else
      self.number = 1
    end
  end
  
  def html
    "#{comment}"
  end

end
