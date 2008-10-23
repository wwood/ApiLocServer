class GoTerm < ActiveRecord::Base
  
  has_many :coding_region_go_terms, :dependent => :destroy
  has_many :coding_regions, :through => :coding_region_go_terms
  
  
  # I wonder will this work? Twould be cool azz yo.
  #  has_and_belongs_to_many :go_terms, :class_name => 'GenericGoMap'
  
  has_many :go_alternates, :dependent => :destroy

  ENZYME_GO_TERM = 'GO:0003824'  
  
  # Find a GO term by searching the go_term, or failing that
  # using the alternate as a proxy and returning the go_term that corresponds
  # to that
  def self.find_by_go_identifier_or_alternate(go_identifier)
    if (g = GoTerm.find_by_go_identifier(go_identifier))
      return g
    elsif (a = GoAlternate.find_by_go_identifier(go_identifier))
      return a.go_term
    else
      # Nothing found. Bad news for you - is the database up to scratch?
      return nil
    end
  end
end
