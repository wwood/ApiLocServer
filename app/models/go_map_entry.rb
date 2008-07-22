class GoMapEntry < ActiveRecord::Base
  belongs_to :go_map
  
  belongs_to :parent, :class_name => :go_term
  belongs_to :child, :class_name => :go_term
end
