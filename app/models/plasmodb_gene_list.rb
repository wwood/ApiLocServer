class PlasmodbGeneList < ActiveRecord::Base
  has_many :plasmodb_gene_list_entries, :dependent => :destroy
  has_many :coding_regions, :through => :plasmodb_gene_list_entries
  
  VOSS_NUCLEAR_PROTEOME_OCTOBER_2008 = 'voss_nuclear_proteome_october_2008'
  
  # A generic method for uploading a bunch of genes using stdin
  # description - the name of the list
  # organism - the common name for the organism the gene is for. nil means organism isn't considered when uploading the data
  def self.create_gene_list(description, organism=nil)
    if !description or description ===''
      raise Exception, "Bad gene list description: '#{description}'"
    end
    
    list = PlasmodbGeneList.create(
      :description => description
    )
    
    $stdin.each do |line|
      line.strip!
      
      if organism
        code = CodingRegion.find_by_name_or_alternate_and_organism(line, organism)
      else
        code = CodingRegion.find_by_name_or_alternate(line)
      end
      
      if !code
        $stderr.puts "Warning no coding region found for #{line}"
      else
        PlasmodbGeneListEntry.find_or_create_by_plasmodb_gene_list_id_and_coding_region_id(
          list.id,
          code.id
        )
      end
    end
    
    hits = PlasmodbGeneListEntry.count(:conditions => "plasmodb_gene_list_id=#{list.id}")
    
    puts "Uploaded #{hits} different coding regions"
  end
end
