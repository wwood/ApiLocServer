class Cd < ActiveRecord::Base
  belongs_to :coding_region

  def length
    stop-start+1
  end
end
