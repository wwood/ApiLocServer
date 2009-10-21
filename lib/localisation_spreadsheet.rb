require 'fastercsv'
require 'localisation_spreadsheet_species' #for the top level functions
require 'reach'

# A class for parsing my localisation spreadsheets, and uploading them
# to my database
class LocalisationSpreadsheet
  include LocalisationSpreadsheetSpecies

  # yield LocalisationSpreadsheetRow objects for each
  # row of a spreadsheet
  def parse_spreadsheet(species_name, filename, whiny=true)
    line_number = 1 #start at 1 because there'll be a heading row

    #    FasterCSV.open(filename, :col_sep => "\t", :headers => true) do |row|
    CSV.open(filename, 'r', "\t").each do |row|
      line_number += 1
      unless comment_line?(row)
        yield(
          LocalisationSpreadsheetRow.new.create_from_array(
            species_name, row, whiny
          ),
          line_number)
      end
    end
  end

  # true if the line is a comment line i.e. has a '#' at the start,
  # or is empty
  def comment_line?(row_array)
    return true if row_array.length == 0
    return true if row_array[0] and row_array[0].strip.match(/^\#/)
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
    upload_list_localisations sp, filename
  end

  # For species without genome projects, the GenBank ID is used as the
  # Gene ID.
  def create_genbank_type_coding_regions(filename)
    parse_spreadsheet(nil, filename) do |info, line_number|
      raise unless info.species_name
      species = Species.find_or_create_by_name(info.species_name)
      unless info.gene_id.nil?
        scaf = Scaffold.find_or_create_by_species_id_and_name(
          species.id, "Dummy"
        )
        gene = Gene.find_or_create_by_scaffold_id_and_name(
          scaf.id, "Dummy"
        )
        CodingRegion.find_or_create_by_gene_id_and_string_id(
          gene.id, info.gene_id
        )
      end
    end
  end

  def deconvolve_species_and_name(overall_species, localisation_line)
    if overall_species.nil?
      return Species.find_by_name(localisation_line.species_name),
        localisation_line.species_name
    else
      return overall_species, overall_species.name
    end
  end

  # If species is nil, this indicates that the name of the species is in the
  # first column of the spreadsheet itself.
  def upload_list_gene_ids(overall_species, filename)
    ignore_mapping_complaints = overall_species.nil? #don't care about mapping problems if there is just a genbank in the gene id column

    overall_species_name = nil
    overall_species_name = overall_species.name unless overall_species.nil?
     
    # first pass. Upload each row that has a gene id in it
    parse_spreadsheet(overall_species_name, filename) do |info, line_number|
      species, species_name = deconvolve_species_and_name(overall_species, info)

      # skip if there is no gene id or common name
      next unless info.common_names
      next unless info.gene_id or info.no_matching_gene_model?

      unless info.mapping_comments or ignore_mapping_complaints
        $stderr.puts "Unexpected lack of gene mapping comment for #{info.gene_id} (#{info.common_names}). Line #{line_number}."
      end

      # Try to find the coding region if possible just from the gene_id column
      code = CodingRegion.find_by_name_or_alternate_and_organism(info.gene_id, species_name)
      # If there is no matching gene id, then find or create a dummy coding
      # region that holds all of that information
      if info.no_matching_gene_model?
        scaf = Scaffold.find_or_create_by_species_id_and_name(
          species.id, Scaffold::UNANNOTATED_GENES_DUMMY_SCAFFOLD_NAME
        )
        g = Gene.find_or_create_by_scaffold_id_and_name(
          scaf.id, Gene::UNANNOTATED_GENES_DUMMY_GENE_NAME
        )
        code = CodingRegion.find_or_create_by_gene_id_and_string_id(
          g.id, "A common gene for all genes not assigned to a gene model"
        )
      end

      # If there is a gene model specified that I don't understand, then
      # say so.
      unless code
        $stderr.puts "Couldn't find coding region with ID #{info.gene_id} from #{species_name}, skipping"
        next
      end

      info.common_names.each do |common|
        LiteratureDefinedCodingRegionAlternateStringId.find_or_create_by_name_and_coding_region_id(
          common, code.id
        )
      end

      info.case_sensitive_common_names.each do |common|
        CaseSensitiveLiteratureDefinedCodingRegionAlternateStringId.find_or_create_by_name_and_coding_region_id(
          common, code.id
        )
      end

      # If there is no matching gene id, then find or create a dummy coding
      # region that holds all of that information
      if info.no_matching_gene_model?
        scaf = Scaffold.find_or_create_by_species_id_and_name(
          species.id, Scaffold::UNANNOTATED_GENES_DUMMY_SCAFFOLD_NAME
        )
        g = Gene.find_or_create_by_scaffold_id_and_name(
          scaf.id, Gene::UNANNOTATED_GENES_DUMMY_GENE_NAME
        )
        code = CodingRegion.find_or_create_by_gene_id_and_string_id(
          g.id, CodingRegion::UNANNOTATED_CODING_REGIONS_DUMMY_GENE_NAME
        )
      end
    end

    # second pass. Upload each common name where there is more than 1,
    # because they are synonyms. As a side effect this checks that there
    # is no standalone name pairs (but not singletons, so this is not a
    # general solution
    parse_spreadsheet(overall_species_name, filename) do |info, line_number|
      species, species_name = deconvolve_species_and_name(overall_species, info)
      next if info.gene_id
      next if info.common_names.length < 2

      begin
        # First, find the gene id
        code = locate_coding_region(info, species_name)

        if code
          info.common_names.each do |common|
            LiteratureDefinedCodingRegionAlternateStringId.find_or_create_by_name_and_coding_region_id(
              common, code.id
            )
          end

          info.case_sensitive_common_names.each do |common|
            CaseSensitiveLiteratureDefinedCodingRegionAlternateStringId.find_or_create_by_name_and_coding_region_id(
              common, code.id
            )
          end
        else
          $stderr.puts "Couldn't find matching gene id for '#{info.common_names.inspect}' in the second pass, skipping."
        end
      rescue CodingRegionConflictException => e
        $stderr.puts e.to_s
      end
    end
  end

  # try to find (not create) the coding region that corresponds to this
  # spreadsheet row. raise a CodingRegionConflict if multiple are found.
  def locate_coding_region(localisation_spreadsheet_row, species_name)
    collected_coding_regions = []

    # Start with the coding regions from the gene_id - the easiest. If there
    # is one, use it, and don't bother trying to find it by the common name
    # method. Otherwise it'll complain when it finds multiple gene models.
    unless localisation_spreadsheet_row.gene_id.nil?
      collected_coding_regions << CodingRegion.find_all_by_name_or_alternate_and_species(
        localisation_spreadsheet_row.gene_id, species_name)
    else
      localisation_spreadsheet_row.common_names.each do |common|
        codes = CodingRegion.find_all_by_name_or_alternate_and_organism(
          common, species_name
        )
        collected_coding_regions << codes[0]
      end
    end

    # If no common names match, do we know already there is no gene model?
    if localisation_spreadsheet_row.no_matching_gene_model?
      code = CodingRegion.find_by_name_or_alternate_and_organism(
        CodingRegion::UNANNOTATED_CODING_REGIONS_DUMMY_GENE_NAME,
        species_name
      )
    end

    collected_coding_regions = collected_coding_regions.flatten.uniq.reject{|c| c.nil?}
    unless collected_coding_regions.length == 1
      $stderr.puts "Unexpected number of hits to the common name #{localisation_spreadsheet_row.common_names[0]}: #{collected_coding_regions.inspect} from #{localisation_spreadsheet_row.common_names.inspect}, #{localisation_spreadsheet_row.gene_id}"
      return nil
    end

    return collected_coding_regions[0]
  end

  def upload_list_localisations(overall_species, filename)
    loc = Localisation.new
    overall_species_name = nil
    overall_species_name = overall_species.name unless overall_species.nil?
    
    # Upload each of the localisations as an expression context
    parse_spreadsheet(overall_species_name, filename, false) do |info, line_number|
      species, species_name = deconvolve_species_and_name(overall_species, info)
      species_name ||= info.species_name
      sp ||= Species.find_by_name(species_name)

      next unless info.normal_localisation_line?

      #      $stderr.puts info.inspect
      if info.localisation_and_timing.nil?
        $stderr.puts "No localisation data found. I expected some. Ignoring this line"
        next
      end

      # make sure the coding region is in the database properly.
      code = locate_coding_region(info, species_name)
      next if code.nil?

      # Create the publication(s) we are relying on
      if info.pubmed_id
        pubs = Publication.find_create_from_ids_or_urls info.pubmed_id
      else
        $stderr.puts "No publications found for line #{info.inspect}, ignoring this line"
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

# A class representing a row of the spreadsheet, that has been parsed as much
# as possible but only using the structure of the spreadsheet, without
# regard to the meaning of that data
class LocalisationSpreadsheetRow
  attr_accessor :species_name,
    :case_sensitive_common_names,
    :gene_id, :pubmed_id,
    :localisation_and_timing, :mapping_comments,
    :microscopy_types, :microscopy_types_raw,
    :localisation_method, :quote, :strains_raw, :comments

  NO_LOC_JUST_GENE_MODEL = 'no localisation done, just a confirmation of gene model'
  THIS_ENTRY_IS_A_COMMON_NAME_MATCHING_THING = 'these common names refer to the same gene'

  NO_MATCHING_GENE_MODEL = 'no matching gene model found'
  NO_LOC_METHOD = "localisation method not found"

  def create_from_array(species_name, array, whiny)
    start_column = 0
    unless species_name #if there's no species name, it'll just be in the firt column
      @species_name = array[start_column]; start_column += 1
    else
      @species_name = species_name
    end
    
    names = array[start_column]; start_column += 1
    @case_sensitive_common_names = parse_common_names_column(@species_name, names)
    @gene_id = array[start_column]; start_column += 1
    @gene_id.strip! unless @gene_id.nil?
    @pubmed_id = array[start_column]; start_column += 1
    @localisation_and_timing = array[start_column]; start_column += 1
    @mapping_comments = array[start_column]; start_column += 1
    @microscopy_types_raw = array[start_column]; start_column += 1
    @localisation_method = array[start_column]; start_column += 1
    @quote = array[start_column]; start_column += 1
    @strains_raw = array[start_column]; start_column += 1
    @comments = array[start_column..(array.length-1)]; start_column += 1
    @comments ||= [] #stupid nil arrays

    # checking. Unless it is just a gene model thing, there should be certain
    # columns that are filled
    if whiny
      if @comments.include?(NO_LOC_JUST_GENE_MODEL)
        $stderr.puts "No pubmed for gene model only row: #{array.inspect}" unless @pubmed_id
        $stderr.puts "No mapping comments for gene model only row: #{array.inspect}" unless @mapping_comments
      elsif @comments.include?(THIS_ENTRY_IS_A_COMMON_NAME_MATCHING_THING)
        $stderr.puts "Not enough names to make a pair in #{array.inspect}, expected 2 or more." unless @case_sensitive_common_names.length > 1
      else
        # a normal loc line should contain various things
        if @case_sensitive_common_names.empty? and @gene_id.nil?
          $stderr.puts "No gene model or common name for #{array.inspect}"
        end

        if @localisation_method.nil? and
            @microscopy_types != ['ChIP'] and
            !@comments.include?(NO_LOC_METHOD)
          $stderr.puts "No localisation method found for #{array.inspect}"
        end
        if @quote.nil?
          $stderr.puts "No quote found for #{array}"
        end
        if @pubmed_id.nil?
          $stderr.puts "No pubmed found for #{array}"
        end
        if microscopy_types.empty?
          $stderr.puts "No microscopy types for localisation line #{array.inspect}"
        end
        if strains.empty? and !(@comments.include?('strain information not found'))
          $stderr.puts "Strain info missing for #{array.inspect}. Comments #{@comments.inspect}"
        end
      end
    end
    
    return self #for convenience
  end

  def gene_id
    return nil if no_matching_gene_model?
    return @gene_id
  end

  def no_matching_gene_model?
    @gene_id == NO_MATCHING_GENE_MODEL
  end

  def microscopy_types
    parse_microscopy_type_column(@microscopy_types_raw)
  end

  # return the strains as an array
  def strains
    parse_strain_column(@strains_raw)
  end

  # lower case common names in this row
  def common_names
    @case_sensitive_common_names.reach.downcase.retract
  end

  # A localisation spreadsheet has a common name column. Return a list of
  # common names that come from one cell (with upper and lower case)
  def parse_common_names_column(species_name, common_name)
    return [] unless common_name
    common_name.split(',').reach.strip.collect do |c|
      remove_species_prefix species_name, c
    end
  end

  def parse_strain_column(strain_column)
    if strain_column.nil?
      []
    else
      strain_column.split(',').reach.strip.retract
    end
  end

  def parse_microscopy_type_column(column)
    return [] if column.nil?
    column.split(',').reach.strip.retract
  end

  # Return the common name that does not have the species name in it
  def remove_species_prefix(species_name, common_name)
    prefix = generate_prefix_from_binomial_name(species_name)
    raise Exception,
      "Unknown species '#{species_name}'- can't remove common name prefix" unless prefix
    if matches = common_name.match(/^#{prefix}(.*)/)
      return matches[1]
    else
      return common_name
    end
  end

  def generate_prefix_from_binomial_name(species_name)
    splits = species_name.split(' ')
    raise unless splits.length == 2
    raise Exception, "Incorrect first name in #{species_name}" unless splits[0][0..0].upcase!.nil?
    raise unless splits[1][0..0].downcase!.nil?
    "#{splits[0][0..0].upcase}#{splits[1][0..0]}"
  end

  def normal_localisation_line?
    return false if @comments.include?(NO_LOC_JUST_GENE_MODEL) or
      @comments.include?(THIS_ENTRY_IS_A_COMMON_NAME_MATCHING_THING)
    return true
  end
end

class CodingRegionConflictException < Exception; end