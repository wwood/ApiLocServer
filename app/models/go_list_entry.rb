class GoListEntry < ActiveRecord::Base
  belongs_to :go_list
  belongs_to :go_term
end
