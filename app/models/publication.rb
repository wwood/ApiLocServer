class Publication < ActiveRecord::Base
  has_many :expression_contexts, :dependent => :destroy
  
  # Given a pubmed id, or url (or more than one separated by commas. Create them and return an array of them
  def self.create_from_ids_or_urls(publications_string)
    pubs = []
    publications_string.split(',').each do |str|
      str.strip!
      pub = Publication.new
      if str.to_i.to_s === str #if it is an integer, it's a pubmed id
        pub.pubmed_id = str.to_i
      else
        # make sure the parsing problem is a-ok
        if !str.match('^http')
          raise ParseException, "Couldn't parse #{pub} as a publication"
        end
        pub.url = str
      end
      pub.save!
      pubs.push pub
    end
    return pubs
  end
end


class ParseException <Exception; end
