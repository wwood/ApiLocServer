class Localisation < ActiveRecord::Base
  has_many :coding_regions, :through => :coding_region_localisations
  has_many :coding_region_localisations, :dependent => :destroy
  belongs_to :top_level_localisation
  has_many :expression_contexts, :dependent => :destroy
  has_many :expressed_coding_regions, :through => :expression_contexts, :source => :coding_region
  
  named_scope :recent, lambda { { :conditions => ['created_at > ?', 1.week.ago] } }
  named_scope :known, lambda { { :conditions => ['name in (?)', KNOWN_FALCIPARUM_LOCALISATIONS] } }
  
  KNOWN_FALCIPARUM_LOCALISATIONS = [
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
      'mitochondrial membrane',
      'apicoplast',
      'cytosol',
      'cytoplasm',
      'nucleus',
      'nuclear membrane',
      'golgi',
      'endoplasmic reticulum',
      'vesicles',
      'intracellular vacuole',
      'merozoite surface', #start of merozoite locs
      'inner membrane complex',
      'rhoptry',
      'microneme',
      'mononeme',
      'dense granule',
      'apical',
      'merozoite cytoplasm',
      'gametocyte surface', #gametocyte locs
      'gametocyte nucleus',
      'gametocyte cytoplasm',
      'gametocyte parasitophorous vacuole',
      'gametocyte osmiophilic body',
      'sporozoite surface', #sporozoite locs
      'sporozoite cytoplasm',
      'ookinete', #mosquito stage locs
      'ookinete microneme',
      'hepatocyte cytoplasm',
      'hepatocyte nucleus',
      'hepatocyte parasitophorous vacuole membrane'
    ]
  
  # Return a list of ORFs that have this and only this localisation
  def get_individual_localisations
    coding_regions = CodingRegion.find_by_sql(
      "select foo.coding_region_id from (select coding_region_id, count(*) from coding_region_localisations group by coding_region_id having count(*)=1) as foo join coding_region_localisations as food on foo.coding_region_id = food.coding_region_id where food.localisation_id=#{id}"
    )
    return coding_regions
  end
  
  def upload_known_localisations
    KNOWN_FALCIPARUM_LOCALISATIONS.each do |loc|
      if !Localisation.find_or_create_by_name(loc)
        raise Exception, "Failed to upload loc '#{loc}' for some reason"
      end
      
      # not that localisation is also a localisation
      if !Localisation.find_or_create_by_name("not #{loc}")
        raise Exception, "Failed to upload NOT loc '#{loc}' for some reason"
      end
    end
  end
  
  def upload_localisation_synonyms
    {
      'ER' => 'endoplasmic reticulum',
      'tER' => 'endoplasmic reticulum',
      'imc' => 'inner membrane complex',
      'cis-golgi' => 'golgi',
      'trans-golgi' => 'golgi', 
      'pv' => 'parasitophorous vacuole',
      'maurer\'s cleft' => 'maurer\'s clefts',
      'knobs' => 'knob',
      'RBC Surface' => 'erythrocyte cytoplasm',
      'FV' => 'food vacuole',
      'erythrocyte membrane' => 'erythrocyte plasma membrane',
      'erythrocyte surface' => 'erythrocyte plasma membrane',
      'rhoptries' => 'rhoptry',
      'micronemes' => 'microneme',
      'mitochondrion' => 'mitochondria',
      'cytosol membranous structures' => 'cytosol',
      'cytoplasmic foci' => 'cytoplasm',
      'nucleolus' => 'nucleus',
      'telomeric foci' => 'nucleus',
      'male gametocyte surface' => 'gametocyte surface',
      'female gametocyte surface' => 'gametocyte surface',
      'gametocyte pv' => 'gametocyte parasitophorous vacuole',
      'cytoplasmic vesicles' => 'cytoplasm',
      'pv membrane' => 'parasitophorous vacuole membrane',
      'erythrocyte cytoplasm punctate' => 'erythrocyte cytoplasm',
      'vesicle' => 'cytoplasm',
      'plasma membrane' => 'parasite plasma membrane',
      'fv membrane' => 'food vacuole membrane',
      'limiting membranes' => 'parasite plasma membrane',
      'dense granules' => 'dense granule',
      'rhoptry neck' => 'rhoptry',
      'hepatocyte pv membrane' => 'hepatocyte parasitophorous vacuole membrane',
      'osmiophilic body' => 'gametocyte osmiophilic body',
      'cytosol diffuse' => 'cytosol',
      'vesicles under rbc surface' => 'erythrocyte cytoplasm',
      'punctate peripheral cytoplasm' => 'cytoplasm',
      'parasite periphery' => 'cytoplasm',
      'nucleoplasm' => 'nucleus',
      'nuclear' => 'nucleus',
      'rbc' => 'erythrocyte cytoplasm',
      'red blood cell surface' => 'erythrocyte plasma membrane',
      'er foci' => 'endoplasmic reticulum',
      'food vacuole foci' => 'food vacuole',
      'erythrocyte cytosol' => 'erythrocyte cytoplasm'
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
      
      if row[0]
        next if row[0].match(/^\#/) # ignore lines starting with # (comment) characters
      end
      next if row.length < 1 #ignore blank lines
      
      # name the columns sensibly
      common_name = row[0]
      plasmodb_id = row[1]
      pubmed_id = row[2]
      localisation_string = row[3]
      
      # make sure the coding region is in the database properly.
      plasmodb_id.strip!
      next if ['PF13_0115'].include?(plasmodb_id)
      code = CodingRegion.ff(plasmodb_id)
      if !code
        raise Exception, "No coding region '#{plasmodb_id}' found."
      end
      
      # Create the publication(s) we are relying on
      pubs = Publication.create_from_ids_or_urls pubmed_id
      if !pubs or pubs.empty?
        raise Exception, "No publications found for line #{row.inspect}"
      end

      
      # add the coding region and publication for each of the names
      parse_name(localisation_string).each do |context|
        pubs.each do |pub|
          ExpressionContext.find_or_create_by_coding_region_id_and_developmental_stage_id_and_localisation_id_and_publication_id(
            code.id,
            context.developmental_stage_id,
            context.localisation_id,
            pub.id
          )
        end
      end
    end
    
    puts code.name_with_localisation
  end
  
  # Parse a line from the dirty localisation files. Return an array of (unsaved) ExpressionContext objects
  def parse_name(dirt)
    contexts = []
    
    # split on commas
    dirt.split(',').each do |fragment|
      if matches = fragment.match('^(.*) during (.*)')
        stages = []
        
        # split each of the localisations by 'and', 'then', etc.
        locs = parse_small_name(matches[1])
        
        # split each of the stages by 'and'
        matches[2].split(' and ').each do |stage|
          d = DevelopmentalStage.find_by_name_or_alternate(stage)
          if !d
            raise Exception, "No such dev stage '#{stage}' found."
          else
            stages.push d
          end
        end
        
        # add each of the resulting pairs
        locs.pairs(stages).each do |arr|
          contexts.push ExpressionContext.new(
            :localisation => arr[0],
            :developmental_stage => arr[1]
          )
        end
        
      else #no during - it's just a straight localisation
        # split each of the localisations by 'and' and 'then'
        locs = parse_small_name(fragment)
        locs.each do |l|
          contexts.push ExpressionContext.new(
            :localisation => l
          )
        end
      end
    end
    
    return contexts.flatten
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
  
  
  # To parse names like 'cytoplasm and rbc surface' or 'pv then rbc surface'
  def parse_small_name(fragment)
    locs = []
    fragment.split(' and ').each do |loc|
      loc.strip!
      loc.downcase!
      splits = loc.split(' then ')
      
      if splits.length == 1
        l = parse_small_small_name(splits[0])
      elsif splits.length == 2 #forget the first localisation - we'll just take the second
        l = parse_small_small_name(splits[1])
      else
        raise ParseException, "fragment not understood: #{fragment}"
      end

      locs.push l
    end
    return locs
  end
  
  def parse_small_small_name(frag)
    frag.strip!
    frag.downcase!
    l = Localisation.find_by_name_or_alternate(frag)
    if !l and matches = frag.match(/^not (.+)$/)
      syn = LocalisationSynonym.find_by_name(matches[1])
      if syn
        l = Localisation.find_by_name("not #{syn.localisation.name}")
      end
    end
    
    raise ParseException, "Localisation not understood: '#{frag}'" if !l
    return l
  end
  
end

  
class ParseException < Exception
end
