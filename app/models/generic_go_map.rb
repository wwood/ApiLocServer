class GenericGoMap < ActiveRecord::Base
  has_many :children, :class_name => 'GoTerm'
  belongs_to :parent, :class_name => 'GoTerm'
end
