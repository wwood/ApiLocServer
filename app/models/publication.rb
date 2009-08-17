class Publication < ActiveRecord::Base
  has_many :expression_contexts, :dependent => :destroy
  
  # Given a pubmed id, or url (or more than one separated by commas. Create them and return an array of them
  def self.find_create_from_ids_or_urls(publications_string)
    pubs = []

    publications_string.strip!
    pub = nil
    if publications_string.to_i.to_s === publications_string #if it is an integer, it's a pubmed id
      pub = Publication.find_or_create_by_pubmed_id publications_string.to_i
    else
      # commas are deprecated and disallowed now (previously more than 1 publication could be in the same line
      raise ParseException, "Comma found in publication string. Only 1 publication per record please." if publications_string.match(/\,/)
      
      # make sure the parsing problem is a-ok
      if !publications_string.match('^http') and !publications_string.match('unpublished')
        raise ParseException, "Couldn't parse #{pub} as a publication"
      end
      pub = Publication.find_or_create_by_url publications_string
    end
    pubs.push pub

    return pubs
  end
  
  # A short definition - either a pubmed id or the url if no pubmed id is recorded
  def definition
    if pubmed_id.nil?
      return url
    else
      return pubmed_id
    end
  end
  
  def linkout_url
    if pubmed_id.nil?
      return url
    else
      to_return = "http://www.ncbi.nlm.nih.gov/sites/entrez?db=pubmed&term=#{pubmed_id}"
      return to_return
    end
  end
  
  def to_param
    if pubmed_id
      return "#{pubmed_id}"
    elsif url
      return "#{url}"
    else
      # don't think this should ever happen but oh well
      return "#{id}"
    end
  end
end


class ParseException <Exception; end
