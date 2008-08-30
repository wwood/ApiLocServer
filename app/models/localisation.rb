class Localisation < ActiveRecord::Base
  has_many :coding_regions, :through => :coding_region_localisations
  has_many :coding_region_localisations, :dependent => :destroy
  belongs_to :top_level_localisation
  has_many :expression_contexts, :dependent => :destroy
  
  named_scope :recent, lambda { { :conditions => ['created_at > ?', 1.week.ago] } }
  
  # Return a list of ORFs that have this and only this localisation
  def get_individual_localisations
    coding_regions = CodingRegion.find_by_sql(
      "select foo.coding_region_id from (select coding_region_id, count(*) from coding_region_localisations group by coding_region_id having count(*)=1) as foo join coding_region_localisations as food on foo.coding_region_id = food.coding_region_id where food.localisation_id=#{id}"
    )
    return coding_regions
  end
  
  def upload_known_localisations
    [
      'knob', #start of ring, troph, schizont stage locs
      'erythrocyte cytoplasm',
      'maurer\'s clefts',
      'erythrocyte plasma membrane',
      'parasitophorous vacuole',
      'parasitophorous vacuole membrane',
      'parasite plasma membrane',
      'food vacuole',
      'food vacuole membrane',
      'mitochondria',
      'apicoplast',
      'cytosol',
      'cytoplasm',
      'nucleus',
      'golgi',
      'endoplasmic reticulum',
      'vesicles',
      'merozoite surface', #start of merozoite locs
      'inner membrane complex',
      'rhoptry',
      'microneme',
      'mononeme',
      'dense granule',
      'gametocyte surface', #gametocyte locs
      'sporozoite surface', #sporozoite locs
      'sporozoite cytoplasm',
      'ookinete' #mosquito stage locs
    ].each do |loc|
      if !Localisation.find_or_create_by_name(loc)
        raise Exception, "Failed to upload loc '#{loc}' for some reason"
      end
    end
  end
  
  def upload_localisation_synonyms
    {
      'ER' => 'endoplasmic reticulum',
      'tER' => 'endoplasmic reticulum',
      'IMC' => 'inner membrane complex',
      'cis-golgi' => 'golgi',
      'trans-golgi' => 'golgi', 
      'pv' => 'parasitophorous vacuole',
      'maurer\'s cleft' => 'maurer\'s clefts',
      'knobs' => 'knob'
    }.each do |key, value|
      l = value.downcase
      loc = Localisation.find_by_name(l)
      if loc
        if !LocalisationSynonym.find_or_create_by_localisation_id_and_name(
            loc.id, 
            key.downcase
          )
          raise
        end
      else
        raise Exception, "Could not find localisation #{l}"
      end
    end
  end
  
  # Upload all the data from the localisation list manually collected by ben
  def upload_other_falciparum_list(filename='/home/ben/phd/gene lists/other/other.csv')
    require 'csv'
    CSV.open(filename, 'r', "\t") do |row|
      p row
      
      next if row[0].match(/^\#/) # ignore lines starting with # (comment) characters
      next if row.length < 1 #ignore blank lines
      
      # name the columns sensibly
      common_name = row[0]
      plasmodb_id = row[1]
      pubmed_id = row[2]
      localisation_string = row[3]
      
      # make sure the coding region is in the database properly.
      code = CodingRegion.find_by_name_or_alternate_and_organism(plasmodb_id, Species.falciparum_name)
      if !code
        raise Exception, "No coding region '#{plasmodb_id}' found."
      end
      
      # Create the publication(s) we are relying on
      pubs = Publication.create_from_ids_or_urls pubmed_id
      if !pubs or pubs.empty?
        raise Exception, "No publications found for line #{row.inspect}"
      end

      
      # parse the localisation properly
      parse_name(localisation_string).each do |dsl|
        dsl.save!
        pubs.each do |pub|
          DevelopmentalStageLocalisationPublication.find_or_create_by_developmental_stage_localisations_id_and_publication_id(
            dsl.id, pub.id
          )
        end
      end
    end
    
    puts code.name_with_localisation
  end
  
  # Parse a line from the dirty localisation files. Return an array of (unsaved) DevelopmentalStageLocalisation objects
  def parse_name(dirt)
    locstages = []
    
    unknown_dev_stage = DevelopmentalStage.find_or_create_by_name(DevelopmentalStage::UNKNOWN_NAME)
    
    # split on commas
    dirt.split(',').each do |fragment|
      if matches = fragment.match('^(.*) during (.*)')
        stages = []
        
        # split each of the localisations by 'and', 'then', etc.
        locs = parse_small_name(matches[1])
        
        # split each of the stages by 'and'
        matches[2].split(' and ').each do |stage|
          d = DevelopmentalStage.find_by_name(stage)
          if !d
            raise Exception, "No such dev stage '#{stage}' found."
          else
            stages.push d
          end
        end
        
        # add each of the resulting pairs
        locs.pairs(stages).each do |arr|
          locstages.push DevelopmentalStageLocalisation.new(
            :localisation => arr[0],
            :developmental_stage => arr[1]
          )
        end
        
      else #no during - it's just a straight localisation
        # split each of the localisations by 'and'
        locs = parse_small_name(fragment)
        locs.each do |l|
          locstages.push DevelopmentalStageLocalisation.new(
            :localisation => l,
            :developmental_stage => unknown_dev_stage
          )
        end
      end
    end
    
    return locstages.flatten
  end
  
  
  def self.find_by_name_or_alternate(localisation_string)
    locs = Localisation.find_all_by_name(localisation_string)
    return locs[0] if locs.length == 1
    if s = LocalisationSynonym.find_by_name(localisation_string)
      return s.localisation
    else
      return nil
    end
  end
  
  
  # To parse names like 
  def parse_small_name(fragment)
    locs = []
    fragment.split(' and ').each do |loc|
      loc.strip!
      loc.downcase!
      loc.split(' then ').each do |another_loc|
        l = Localisation.find_by_name_or_alternate(another_loc)
        if !l
          raise Exception, "No such localisation '#{another_loc}' found."
        else
          locs.push l
        end
      end
    end
    return locs
  end
  
end
