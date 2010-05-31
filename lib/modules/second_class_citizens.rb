# Methods 
class BScript
  def upload(csv_filename="#{PHD_DIR}/gene lists/second class citizens.csv")
    # Ignore header line
    # For each line 
    
    # ==columns of the spreadsheet
    #Species
    #Gene 
    #Common Name
    #Gene ID
    #Pubmed ID
    #Localisation/developmental stage
    #hypothesis
    #Gene ID mapping comments
    
    FasterCSV.foreach(csv_filename, :col_sep => "\t") do |row|
      # skip header and other comment lines
      next if row[0].match(/^#/)
      
      species_abbreviation = row[0]
      gene_common_names = row[1]
      gene_id = row[2]
      pubmed_id = row[3]
      localisation_and_developmental_stage = row[4]
      reasoning = row[5]
      gene_mapping_comments = row[6]
      
      species_data = SpeciesData.new(species_abbreviation.split(' ').last)
      if species_data.nil?
        $stderr.puts "Couldn't understand species name, skipping: '#{species_abbreviation}'"
        next
      end
    end
  end
end