require 'rsruby'
 

module Bio
  class Go
    def initialize
      @r = RSRuby.instance
    end
    
    # Return an array of GO identifiers that are the children 
    # of the given GO term given that it is a cellular component
    # GO term.
    def self.go_cc_children(go_term)
      
    end
  end
end
