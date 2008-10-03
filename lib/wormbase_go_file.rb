require 'api_db_genes'
require 'fastercsv'

# Iterates through the gene GO entries, as taken from a wormbase text
# file such as ftp://ftp.wormbase.org/pub/wormbase/genomes/c_elegans/annotations/GO/GO.WS190.txt.gz
# (gunzipp'ed).
module Bio
  class WormbaseGoFile
    attr_reader :genes
    
    def initialize(filename)
      @genes = []
      cur_gene = nil
      FasterCSV.foreach(filename, :col_sep=> "\t") do |row|
        if !row[0]
          # Molecular_function: ATP binding (GO:0005524)
          if !matches = row[1].match(/.*\((GO\:\d+)\)$/)
            raise Exception, "Couldn't parse GO line: #{row.inspect}"
          end
          
          cur_gene.go_identifiers = cur_gene.go_identifiers.push(matches[1])
        elsif cur_gene
          # if not first one in the file
          @genes.push cur_gene
          cur_gene = parse_gene_line(row[0])
        else
          # First gene
          cur_gene = parse_gene_line(row[0])
        end
      end
      
      # Record the last one
      @genes.push cur_gene
    end
    
    private
    
    # WBGene00000005 aat-4 (T13A10.10)
    def parse_gene_line(line)
      cur_gene = WormbaseProteinWithOntology.new
      if !matches = line.match(/^(WBGene\d+) \S+ \((\S+)\)/)
        if !matches = line.match(/^(WBGene\d+) (\S+)/) and !matches = line.match(/^(WBGene\d+)\s*/)
          raise Exception, "Could not parse gene line: #{line}"
        else
          cur_gene.gene_name = matches[1]
          cur_gene.go_identifiers = []        
        end
      else
        cur_gene.gene_name = matches[1]
        cur_gene.protein_name = matches[2]
        cur_gene.go_identifiers = []   
      end
      return cur_gene
    end
  end
  
  
  class WormbaseProteinWithOntology
    attr_accessor :protein_name, :gene_name, :go_identifiers
  end
end