require 'fastercsv'
require 'localisation_spreadsheet_species' #for the top level functions
require 'reach'

# A class for parsing my localisation spreadsheets, and uploading them
# to my database
class LocalisationSpreadsheet
  include LocalisationSpreadsheetSpecies

  # yield LocalisationSpreadsheetRow objects for each
  # row of a spreadsheet
  def parse_spreadsheet(species_name, filename)
    has_species_column_first = true if species_name.nil?
    raise if has_species_column_first
    line_number = 1 #start at 1 because there'll be a heading row

    #    FasterCSV.open(filename, :col_sep => "\t", :headers => true) do |row|
    CSV.open(filename, 'r', "\t").each do |row|
      line_number += 1
      unless comment_line?(row)
        yield(
          LocalisationSpreadsheetRow.new.create_from_array(
            species_name, row
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
    upload_list_gene_ids sp, filename
    LiteratureDefinedCodingRegionAlternateStringId.new.check_for_inconsistency sp.name
    upload_list_localisations sp, filename
  end

  def upload_list_gene_ids(sp, filename)
    species_name = sp.name
     
    # first pass. Upload each row that has a gene id in it
    parse_spreadsheet(species_name, filename) do |info, line_number|

      # skip if there is no gene id or common name
      next unless info.gene_id and info.common_names

      unless info.mapping_comments
        $stderr.puts "Unexpected lack of gene mapping comment for #{info.gene_id} (#{info.common_names}). Line #{line_number}."
      end

      code = CodingRegion.find_by_name_or_alternate_and_organism(info.gene_id, species_name)
      unless code
        $stderr.puts "Couldn't find coding region with ID #{info.gene_id}, skipping"
        next
      end

      info.common_names.each do |common|
        LiteratureDefinedCodingRegionAlternateStringId.find_or_create_by_name_and_coding_region_id(
          common, code.id
        )
      end
    end

    # second pass. Upload each common name where there is more than 1,
    # because they are synonyms. As a side effect this checks that there
    # is no standalone name pairs (but not singletons, so this is not a
    # general solution
    parse_spreadsheet(species_name, filename) do |info, line_number|
      next if info.gene_id
      next if info.common_names.length < 2

      # First, find the gene id
      code = nil
      conflict = false
      info.common_names.each do |common|
        c = CodingRegion.find_by_name_or_alternate_and_organism(
          common, species_name
        )
        if code and c
          # search for conflicts.
          unless c.id == code.id
            $stderr.puts "Conflicting names for common name #{common}. Coding regions #{c.string_id} and #{code.string_id}, #{c.id} and #{code.id}"
            conflict = true
          end
        elsif c
          code = c
        end
      end

      if code
        if !conflict
          # found the coding region. All is well
          info.common_names.each do |common|
            LiteratureDefinedCodingRegionAlternateStringId.find_or_create_by_name_and_coding_region_id(
              common, code.id
            )
          end
        else
          $stderr.puts "Skipping. You should know why, because I have already told you"
        end
      else
        $stderr.puts "Couldn't find matching gene id for #{info.common_names.inspect} in the second pass, skipping."
      end
    end
  end

  def upload_list_localisations(sp, filename)
    loc = Localisation.new
    species_name = sp.name
    
    # Upload each of the localisations as an expression context
    parse_spreadsheet(species_name, filename) do |info, line_number|
      next unless info.normal_localisation_line?

#      $stderr.puts info.inspect
      if info.localisation_and_timing.nil?
        $stderr.puts "No localisation data found. I expected some. Ignoring this line"
        next
      end

      # make sure the coding region is in the database properly.
      code = nil
      if info.gene_id
        code = CodingRegion.find_by_name_or_alternate_and_organism(info.gene_id, species_name)
        unless code
          $stderr.puts "Couldn't find a coding region for #{info.gene_id} in #{info.inspect}"
          next
        end
      else
        codes = LiteratureDefinedCodingRegionAlternateStringId.find_all_by_name(info.common_names[0],
          :joins => {:coding_region => {:gene => {:scaffold => :species}}},
          :conditions => {:species => {:name => species_name}}).reach.coding_region.uniq
        unless codes.length == 1
          $stderr.puts "Too many hits to the common name #{info.common_names[0]}: #{codes.inspect}"
          next
        end
        code = codes[0]
      end

      # Create the publication(s) we are relying on
      if info.pubmed_id
        pubs = Publication.find_create_from_ids_or_urls info.pubmed_id
      else
        $stderr.puts "No publications found for line #{info.inspect}, ignoring this line"
        next
      end

      # add the coding region and publication for each of the names
      loc.parse_name(info.localisation_and_timing, sp).each do |context|
        pubs.each do |pub|
          if code.string_id == 'PFA0445w'
            puts "'PFA0445w' found: #{pub} #{context.inspect}"
          end
          e = ExpressionContext.find_or_create_by_coding_region_id_and_developmental_stage_id_and_localisation_id_and_publication_id(
            code.id,
            context.developmental_stage_id,
            context.localisation_id,
            pub.id
          )
          info.comments.each do |comment|
            next if !comment
            Comment.find_or_create_by_expression_context_id_and_comment(
              e.id,
              comment
            )
          end
        end
      end
    end
  end
end

# A class representing a row of the spreadsheet, that has been parsed as much
# as possible but only using the structure of the spreadsheet, without
# regard to the meaning of that data
class LocalisationSpreadsheetRow
  attr_accessor :common_names, :gene_id, :pubmed_id,
    :localisation_and_timing, :mapping_comments, :microscopy_types,
    :localisation_method, :quote, :strains, :comments

  NO_LOC_JUST_GENE_MODEL = 'no localisation done, just a confirmation of gene model'
  THIS_ENTRY_IS_A_COMMON_NAME_MATCHING_THING = 'these common names refer to the same gene'

  def create_from_array(species_name, array)
    start_column = 0
    unless species_name #if there's no species name, it'll just be in the firt column
      @species_name = array[start_column]; start_column += 1
    end
    #    p array
    @common_names = parse_common_name_column(species_name, array[start_column]); start_column += 1
    @gene_id = array[start_column]; start_column += 1
    @gene_id.strip! unless @gene_id.nil?
    @pubmed_id = array[start_column]; start_column += 1
    @localisation_and_timing = array[start_column]; start_column += 1
    @mapping_comments = array[start_column]; start_column += 1
    @microscopy_types = parse_microscopy_type_column(array[start_column]); start_column += 1
    @localisation_method = array[start_column]; start_column += 1
    @quote = array[start_column]; start_column += 1
    @strains = parse_strain_column(array[start_column]); start_column += 1
    @comments = array[start_column..(array.length-1)]; start_column += 1
    @comments ||= [] #stupid nil arrays

    # checking. Unless it is just a gene model thing, there should be certain
    # columns that are filled
    if @comments.include?(NO_LOC_JUST_GENE_MODEL)
      $stderr.puts "No pubmed for gene model only row: #{array}" unless @pubmed_id
      $stderr.puts "No mapping comments for gene model only row: #{array}" unless @mapping_comments
    elsif @comments.include?(THIS_ENTRY_IS_A_COMMON_NAME_MATCHING_THING)
      $stderr.puts "Not enough names to make a pair in #{array}, expected 2 or more." unless @common_names.length > 1
    else
      # a normal loc line should contain various things
      if @common_names.empty? and @gene_id.nil?
        $stderr.puts "No gene model or common name for #{array}"
      end

      if @localisation_method.nil? and @microscopy_types != ['ChIP']
        $stderr.puts "No localisation method found for #{array}"
      end
      if @quote.nil?
        $stderr.puts "No quote found for #{array}"
      end
      if @pubmed_id.nil?
        $stderr.puts "No pubmed found for #{array}"
      end
      if @microscopy_types.empty?
        $stderr.puts "No microscopy types for localisation line #{array}"
      end
      if @strains.empty? and !(@comments.include?('strain information not found'))
        $stderr.puts "Strain info missing for #{array.inspect}. Comments #{@comments.inspect}"
      end
    end

    return self #for convenience
  end

  # A localisation spreadsheet has a common name column. Return a list of
  # common names that come from one cell
  def parse_common_name_column(species_name, common_name)
    return [] unless common_name
    common_name.split(',').reach.strip.collect do |c|
      (remove_species_prefix species_name, c).downcase
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

  # Common names sometimes have a species name prefix in front (e.g. PfACP
  # is the same as ACP, provided it is known that falciparum is the species
  # that we are dealing with.
  #
  # Manually created names here, but they are expected to match the official
  # ones used in species.rb
  SPECIES_PREFIXES = {
    'falciparum' => 'Pf',
    'Toxoplasma gondii' => 'Tg',
  }

  # Return the common name that does not have the species name in it
  def remove_species_prefix(species_name, common_name)
    prefix = SPECIES_PREFIXES[species_name]
    raise Exception,
      "Unknown species '#{species_name}'- can't remove common name prefix" unless prefix
    if matches = common_name.match(/^#{prefix}(.*)/)
      return matches[1]
    else
      return common_name
    end
  end

  def normal_localisation_line?
    return false if @comments.include?(NO_LOC_JUST_GENE_MODEL) or
      @comments.include?(THIS_ENTRY_IS_A_COMMON_NAME_MATCHING_THING)
    return true
  end
end