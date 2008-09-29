require 'rsruby'
 

module Bio
  class Go
    def initialize
      @r = RSRuby.instance
      @r.library('GO.db')
    end
    
    # Return an array of GO identifiers that are the offspring (all the descendents)
    # of the given GO term given that it is a cellular component
    # GO term. 
    def go_cellular_component_offspring(go_term)
      @r.eval_R("get('#{go_term}', GOCCOFFSPRING)")
    end

    # Return an array of GO identifiers that are the offspring (all the descendents)
    # of the given GO term given that it is a molecular function
    # GO term.     
    def go_molecular_function_offspring(go_term)
      @r.eval_R("get('#{go_term}', GOMFOFFSPRING)")
    end
    
    # Return an array of GO identifiers that are the offspring (all the descendents)
    # of the given GO term given that it is a biological process
    # GO term. 
    def go_biological_process_offspring(go_term)
      @r.eval_R("get('#{go_term}', GOBPOFFSPRING)")
    end
  end
end
