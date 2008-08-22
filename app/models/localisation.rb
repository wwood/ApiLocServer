class Localisation < ActiveRecord::Base
  has_many :coding_regions, :through => :coding_region_localisations
  has_many :coding_region_localisations, :dependent => :destroy
  
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
      'tER' => 'endoplasmic reticulum'
    }.each do |key, value|
      loc = Localisation.find_by_name(value)
      if loc
        if !LocalisationSynonym.find_or_create_by_localisation_id_and_name(
            loc.id, 
            key
          )
          raise
        end
      else
        raise Exception, "Could not find localisation #{value}"
      end
    end
  end
  
  # Upload all the data from the localisation list manually collected by ben
  def upload_other_falciparum_list(filename='/home/ben/phd/gene lists/other/other.csv')
    CSV.open(filename) do |row|
      
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
          DevelopmentalStageLocalisationPublication.find_or_create_by_developmental_stage_localisation_id_and_publication_id(
            dsl.id, pub.id
          )
        end
      end
    end
  end
  
  # Parse a line from the dirty localisation files. Return an array of (unsaved) DevelopmentalStageLocalisation objects
  def parse_name(dirt)
    locstages = []
    
    # split on commas
    dirt.split(',').each do |fragment|
      if matches = fragment.match('^(.*) during (.*)')
        locs = []
        stages = []
        
        # split each of the localisations by 'and'
        matches[1].split(' and ').each do |loc|
          l = Localisation.find_by_name_or_alternate(loc)
          if !l
            raise Exception, "No such localisation '#{loc}' found."
          else
            locs.push l
          end
        end
        
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
        fragment.split(' and ').each do |loc|
          l = Localisation.find_by_name_or_alternate(loc)
          if !l
            raise Exception, "No such localisation '#{loc}' found."
          else
            locstages.push DevelopmentalStageLocalisation.new(:localisation => l)
          end
        end
      end
    end
    
    return locstages.flatten
  end
  
  
  def self.find_by_name_or_alternate(localisation_string)
    Localisation.find_by_name(localisation_string)
  end
end
