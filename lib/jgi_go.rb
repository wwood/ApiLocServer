# 

class JgiGo
  # Initialise with the name of the JGI file
  def initialize(path)
    @jgi_go_file = path
  end
  

end


class GeneAssociationIterator
  def initialize(jgi_go)
    @jgi_go = jgi_go
  end
end