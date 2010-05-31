require 'species_data'
require 'localisation_spreadsheet'

# A class similar to LocalisationSpreadsheet, except it parses the 
# second class citizens special format
class SecondClassLocalisationSpreadsheet < LocalisationSpreadsheet
  # yield LocalisationSpreadsheetRow objects for each
  # row of a spreadsheet
  def parse_spreadsheet(filename, whiny=true)
    line_number = 1 #start at 1 because there'll be a heading row
    
    #    FasterCSV.open(filename, :col_sep => "\t", :headers => true) do |row|
    CSV.open(filename, 'r', "\t").each do |row|
      line_number += 1
      unless comment_line?(row)
        yield(
              SecondClassLocalisationSpreadsheetRow.new.create_from_array(
                                                                    species_name, row, whiny
        ),
        line_number)
      end
    end
  end
  
  def upload_localisations_for_species(sp, filename)
    if sp.nil?
      create_genbank_type_coding_regions(filename)
    end
    upload_list_gene_ids sp, filename
    
    # this could be faster but eh.
    # If sp.nil? == true that means the species are in each line.
    if sp.nil?
      collection = []
      parse_spreadsheet(nil, filename, false) do |r,line_number|
        collection.push r.species_name
      end
      collection.uniq.each do |name|
        LiteratureDefinedCodingRegionAlternateStringId.new.check_for_inconsistency name
      end
    else
      LiteratureDefinedCodingRegionAlternateStringId.new.check_for_inconsistency sp.name
    end
    second_class_citizen_spreadsheet_upload_list_localisations(sp, filename)
  end
  
  def second_class_citizen_spreadsheet_upload_list_localisations(sp, filename)
    upload_list_localisations(overall_species, filename) do |sp, code, info|
      # Create the publication(s) we are relying on
      if info.pubmed_id
        pubs = Publication.find_create_from_ids_or_urls info.pubmed_id
        if pubs.nil?
          puts "No publications found for line #{info.inspect}, ignoring this line"
          next
        end
      else
        puts "No publications found for line #{info.inspect}, ignoring this line"
        next
      end
      
      # create the localisation annotations for this line.
      # Each expression context is tied to this line
      la = LocalisationAnnotation.find_or_create_by_localisation_and_gene_mapping_comments_and_microscopy_type_and_microscopy_method_and_quote_and_strain_and_coding_region_id(
                                                                                                                                                                               info.localisation_and_timing,
                                                                                                                                                                               info.mapping_comments,
                                                                                                                                                                               info.microscopy_types_raw,
                                                                                                                                                                               info.localisation_method,
                                                                                                                                                                               info.quote,
                                                                                                                                                                               info.strains_raw,
                                                                                                                                                                               code.id
      ) or raise
      
      info.comments.each do |comment|
        next if !comment
        Comment.find_or_create_by_localisation_annotation_id_and_comment(
                                                                         la.id,
                                                                         comment
        ) or raise
      end
      
      # add the coding region and publication for each of the names
      loc.parse_name(info.localisation_and_timing, sp).each do |context|
        pubs.each do |pub|
          e = ExpressionContext.find_or_create_by_coding_region_id_and_developmental_stage_id_and_localisation_id_and_publication_id_and_localisation_annotation_id(
                                                                                                                                                                    code.id,
                                                                                                                                                                    context.developmental_stage_id,
                                                                                                                                                                    context.localisation_id,
                                                                                                                                                                    pub.id,
                                                                                                                                                                    la.id
          ) or raise
        end
      end
    end
  end
end

class SecondClassLocalisationSpreadsheetRow < LocalisationSpreadsheetRow
  attr_accessor :reasoning
  
  def species
    return @species_data if @species_data
    @species_data = SpeciesData.new(@species.split(' ')[1])
    if species_data.nil?
      puts "Species couldn't be parsed: #{@species_name}"
    end
  end
  
  # override the super's methods, because less information is
  # stored in second class citizens rows
  #
  # ==columns of the spreadsheet
  #Species
  #Gene 
  #Common Name
  #Gene ID
  #Pubmed ID
  #Localisation/developmental stage
  #hypothesis/reasoning
  #Gene ID mapping comments
  def create_from_array(species_name, array, whiny)
    start_column = 0
    
    
    
    # There is never a species name already known, so always parse it
    @species_name = array[start_column]; start_column += 1
    
    names = array[start_column]; start_column += 1
    @case_sensitive_common_names = parse_common_names_column(@species_name, names)
    @gene_id = array[start_column]; start_column += 1
    @gene_id.strip! unless @gene_id.nil?
    @pubmed_id = array[start_column]; start_column += 1
    @localisation_and_timing = array[start_column]; start_column += 1
    @reasoning = array[start_column]; start_column += 1
    @mapping_comments = array[start_column]; start_column += 1
    
    # checking. Unless it is just a gene model thing, there should be certain
    # columns that are filled
    if whiny
      # a normal loc line should contain various things
      if @case_sensitive_common_names.empty? and @gene_id.nil?
        puts "No gene model or common name for #{array.inspect}"
      end
      
      [:localisation_and_timing, :pubmed_id].each do |required_attribute|
        if send(expected_attribute).nil?
          $stderr.puts "No #{expected_attribute.to_s} found for #{array}, expected something."
        end
      end
      
      [:reasoning, :mapping_comments].each do |expected_attribute|
        if send(expected_attribute).nil?
          puts "No #{expected_attribute.to_s} found for #{array}, expected something."
        end
      end
    end
    
    return self #for convenience
  end
end