class GoSynonym < ActiveRecord::Base
  belongs_to :go_term
  
  named_scope :aspect, lambda { |aspect|
    {
      :joins => :go_term,
      :conditions => {:go_terms => {:aspect => aspect}}
    }
  }
end
