class GoTerm < ActiveRecord::Base
  
  has_many :coding_region_go_terms, :dependent => :destroy
  has_many :coding_regions, :through => :coding_region_go_terms
  
  
  # I wonder will this work? Twould be cool azz yo.
  #  has_and_belongs_to_many :go_terms, :class_name => 'GenericGoMap'
  
  has_many :go_alternates, :dependent => :destroy
  has_many :go_synonyms, :dependent => :destroy

  ENZYME_GO_TERM = 'GO:0003824'
  GPCR_GO_TERM = 'GO:0004930'
  TRANSPORTER_GO_TERM = 'GO:0006810'
  
  ASPECTS = [
    'molecular_function',
    'cellular_component',
    'biological_process'
  ]
  
  validates_each :aspect do |record, attr, value|
    record.errors.add attr, 'invalid aspect string' unless ASPECTS.include?(value)
  end
  
  
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

  def self.find_all_by_term_and_aspect_or_synonym(go_identifier, aspect)
    g = GoTerm.find_all_by_term_and_aspect(go_identifier,aspect)
    g.push GoSynonym.find_all_by_synonym_and_aspect(go_identifier).reach.go_term.select{|g|
      g.aspect == aspect
    }
    return g.flatten.uniq
  end
end
