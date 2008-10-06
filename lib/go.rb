require 'rsruby'
require 'bio'
 

module Bio
  class Go
    def initialize
      @r = RSRuby.instance
      @r.library('GO.db')
    end
    
    # Return an array of GO identifiers that are the offspring (all the descendents)
    # of the given GO term given that it is a cellular component
    # GO term. 
    def cellular_component_offspring(go_term)
      go_get(go_term, 'GOCCOFFSPRING')
    end

    # Return an array of GO identifiers that are the offspring (all the descendents)
    # of the given GO term given that it is a molecular function
    # GO term.     
    def molecular_function_offspring(go_term)
      go_get(go_term, 'GOMFOFFSPRING')
    end
    
    # Return an array of GO identifiers that are the offspring (all the descendents)
    # of the given GO term given that it is a biological process
    # GO term. 
    def biological_process_offspring(go_term)
      go_get(go_term, 'GOBPOFFSPRING')
    end
    
    # Generic method for retrieving
    # e.g offspring('GO:0042717', 'GOCCCHILDREN')
    def go_get(go_term, partition)
      answers = @r.eval_R("get('#{go_term}', #{partition})")
      return [] if answers.kind_of?(Bignum) # returns this for some reason when there's no children
      return answers
    end
    
    # Retrieve the string description of the given go identifier
    def term(go_id)
      @r.eval_R("Term(get('#{go_id}', GOTERM))")
    end
    
    # Retrieve the GO annotations associated with a PDB id,
    # using Bio::Fetch PDB and UniprotKB at EBI
    def cc_pdb_to_go(pdb_id)
      # retrieve the pdb file from EBI, to extract the UniprotKB Identifiers
      pdb = Bio::Fetch.new('http://www.ebi.ac.uk/cgi-bin/dbfetch').fetch('pdb', pdb_id)
      
      # parse the PDB and return the uniprot accessions (there may be >1 because of chains)
      uniprots = Bio::PDB.new(pdb).dbref.select{|s| s.database=='UNP'}.collect{|s| s.dbAccession}
      
      gos = []
      uniprots.uniq.each do |uniprot|
        u = Bio::Fetch.new('http://www.ebi.ac.uk/cgi-bin/dbfetch').fetch('uniprot', uniprot)
        
        unp = Bio::SPTR.new(u)
        
        gos.push unp.dr('GO').select{|a|
          a['Version'].match(/^C\:/)
        }.collect{ |g|
          g['Accession']
        }
      end
      
      return gos.flatten.uniq
    end
  end
end
