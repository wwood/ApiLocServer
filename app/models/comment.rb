class Comment < ActiveRecord::Base
  belongs_to :expression_context
end
