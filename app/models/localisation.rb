require 'csv'

class Localisation < ActiveRecord::Base
  has_many :coding_regions, :through => :coding_region_localisations
  has_many :coding_region_localisations, :dependent => :destroy
  has_many :expression_contexts, :dependent => :destroy
  has_many :expressed_coding_regions, :through => :expression_contexts, :source => :coding_region
  
  has_one :malaria_localisation_top_level_localisation
  has_one :malaria_top_level_localisation, 
    :through => :malaria_localisation_top_level_localisation,
    :source => :top_level_localisation
  
  has_many :localisation_synonyms, :dependent => :destroy
  
  named_scope :recent, lambda { { :conditions => ['created_at > ?', 1.week.ago] } }
  named_scope :known, lambda { { :conditions => ['name in (?)', KNOWN_FALCIPARUM_LOCALISATIONS] } }
  
  KNOWN_FALCIPARUM_LOCALISATIONS = [
    'knob', #start of ring, troph, schizont stage locs
    'erythrocyte cytoplasm',
    'erythrocyte cytosol',
    'maurer\'s clefts',
    'tubulovesicular membrane',
    'erythrocyte plasma membrane',
    'exposed erythrocyte plasma membrane',
    'erythrocyte periphery',
    'erythrocyte cytoplasmic structures',
    'single small vesicles in erythrocyte',
    'exported',
    'cytoplasmic side of erythrocyte membrane',
    'beyond erythrocyte membrane',
    'cleft like parasitophorous vacuole membrane protrusions',
    'punctate parasitophorous vacuole',
    'parasitophorous vacuole',
    'parasitophorous vacuole subdomains',
    'parasitophorous vacuole membrane',
    'parasite plasma membrane',
    'patchy on parasite plasma membrane',
    'apicoplast membrane',
    'proximal to plasma membrane',
    'apical plasma membrane',
    'diffuse cytoplasm',
    'under parasite plama membrane',
    'microtubule',
    'replication foci in nucleus',
    'area near nucleus', # nucleus + surrounds
    'anterior to nucleus',
    'mitotic spindle in nucleus',
    'food vacuole',
    'food vacuole membrane',
    'food vacuole lumen',
    'spot in parasitophorous vacuole close to food vacuole',
    'cytostome',
    'mitochondria',
    'mitochondrial inner membrane',
    'mitochondrial membrane',
    'apicoplast',
    'cytosol',
    'cytoplasm',
    'nucleus',
    'nuclear membrane',
    'cis golgi',
    'trans golgi',
    'golgi',
    'golgi matrix',
    'endoplasmic reticulum',
    'vesicles',
    'intracellular vacuole',
    'intracellular inclusions',
    'punctate intracellular inclusions',
    'vesicles near parasite surface',
    'peripheral',
    'merozoite surface', #start of merozoite locs
    'merozoite associated material',
    'apical end of surface',
    'moving junction',
    'inner membrane complex',
    'pellicle',
    'rhoptry',
    'rhoptry neck',
    'rhoptry bulb',
    'nowhere except rhoptry',
    'microneme',
    'mononeme',
    'dense granule',
    'apical',
    'posterior structure',
    'anterior structure',
    'gametocyte osmiophilic body',
    'gametocyte attached erythrocytic vesicles',
    'sporozoite surface', #sporozoite locs
    'oocyst wall',
    'osmiophilic bodies',
    'zygote remnant', # the zygote part when the ookinete is budding off from the zygote
    'ookinete protrusion', # the opposite of zygote remnant
    'oocyst protrusion', # during ookinete to oocyst transition, oocyst starts out as a round protrusion
    'peripheral of oocyst protrusion', # possibly an analogue of IMC?
    'trail', # the trail that sporozoites leave behind when they move
    'cytoplasmic vesicles',
    'erythrocyte cytoplasmic vesicles',
    'intraerythrocytic cysternae',
    'vesicles under erythrocyte surface',
    'area around nucleus', # not a very specific localisation compared to 'nuclear envelope' or 'ER'
    'nuclear envelope',
    'internal organelles',
    'intracellular',
    'cytoplasmic structures',
    'spread around parasite',
    'throughout parasite',
    'poles',
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
      'dotty pv' => 'punctate parasitophorous vacuole',
      'patchy on plasma membrane' => 'patchy on parasite plasma membrane',
      'apical end of surface' => 'apical plasma membrane',
      'outside of erythrocyte membranes' => 'beyond erythrocyte membrane',
      'rim' => 'proximal to plasma membrane',
      'apex' => 'apical',
      'rhoptry body' => 'rhoptry bulb',
      'throughout cell' => 'throughout parasite',
      'crescent shaped cap associated with apical pole' => 'apical',
      'mam' => 'merozoite associated material',
      'single small vesicles' => 'single small vesicles in erythrocyte',
      'exposed rbc surface' => 'exposed erythrocyte plasma membrane',
      'rbc vesicles' => 'erythrocyte cytoplasmic structures',
      'spread around each individual merozoite' => 'spread around parasite',
      'spot in pv close to fv' => 'spot in parasitophorous vacuole close to food vacuole',
      'rbc vesicles connected to the gametocyte' => 'gametocyte attached erythrocytic vesicles',
      'cleft like pvm protrusions' => 'cleft like parasitophorous vacuole membrane protrusions',
      'red blood cell cytosol' => 'erythrocyte cytosol',
      'rbcm' => 'erythrocyte plasma membrane',
      'tvm' => 'tubulovesicular membrane',
      'rhoptry ductule' => 'rhoptry neck',
      'zygote side' => 'zygote remnant',
      'apical tip' => 'apical',
      'parasite surface' => 'parasite plasma membrane',
      'microtubules' => 'microtubule',
      'not rbc cytosol' => 'not erythrocyte cytoplasm',
      'rbc cytoplasm' => 'erythrocyte cytoplasm',
      'vesicles in rbc cytoplasm' => 'erythrocyte cytoplasmic structures',
      'mc' => 'maurer\'s clefts',
      'ppm' => 'parasite plasma membrane',
      'rbc cytoplasmic aggregates' => 'erythrocyte cytoplasmic structures',
      'foci in erythrocyte cytosol' => 'erythrocyte cytoplasmic structures',
      'tight junction' => 'moving junction',
      'beyond rbc membrane' => 'beyond erythrocyte membrane',
      'under pm' => 'under parasite plama membrane',
      'rhoptry pundicle' => 'rhoptry neck',
      'ER' => 'endoplasmic reticulum',
      'tER' => 'endoplasmic reticulum',
      'imc' => 'inner membrane complex',
      'early golgi' => 'cis golgi',
      'late golgi' => 'trans golgi',
      'pv' => 'parasitophorous vacuole',
      'maurer\'s cleft' => 'maurer\'s clefts',
      'knobs' => 'knob',
      'RBC Surface' => 'erythrocyte cytoplasm',
      'FV' => 'food vacuole',
      'erythrocyte membrane' => 'erythrocyte plasma membrane',
      'rbc membrane' => 'erythrocyte plasma membrane',
      'erythrocyte surface' => 'erythrocyte plasma membrane',
      'rbc cytoplasm vesicles' => 'erythrocyte cytoplasmic vesicles',
      'rhoptries' => 'rhoptry',
      'micronemes' => 'microneme',
      'mitochondrion' => 'mitochondria',
      'cytosol membranous structures' => 'cytosol',
      'cytoplasmic foci' => 'cytoplasm',
      'nucleolus' => 'nucleus',
      'telomeric foci' => 'nucleus',
      'pv membrane' => 'parasitophorous vacuole membrane',
      'erythrocyte cytoplasm punctate' => 'erythrocyte cytoplasm',
      'vesicle' => 'cytoplasmic vesicles',
      'plasma membrane' => 'parasite plasma membrane',
      'surface' => 'parasite plasma membrane',
      'pm' => 'parasite plasma membrane',
      'fv membrane' => 'food vacuole membrane',
      'limiting membranes' => 'parasite plasma membrane',
      'dense granules' => 'dense granule',
      'rhoptry neck' => 'rhoptry',
      'rhoptry bulb' => 'rhoptry',
      'osmiophilic body' => 'gametocyte osmiophilic body',
      'cytosol diffuse' => 'cytosol',
      'vesicles under rbc surface' => 'vesicles under erythrocyte surface',
      'punctate peripheral cytoplasm' => 'cytoplasm',
      'parasite periphery' => 'cytoplasm',
      'nucleoplasm' => 'nucleus',
      'nuclear' => 'nucleus',
      'perinuclear' => 'nucleus',
      'nuclear periphery' => 'nucleus',
      'rbc' => 'erythrocyte cytoplasm',
      'red blood cell surface' => 'erythrocyte plasma membrane',
      'er foci' => 'endoplasmic reticulum',
      'food vacuole foci' => 'food vacuole',
      'erythrocyte cytosol' => 'erythrocyte cytoplasm',
      'pvm' => 'parasitophorous vacuole membrane',
      'moving junction' => 'merozoite surface',
      'merozoite membrane' => "merozoite surface",
      'fv lumen' => 'food vacuole lumen',
      'rbc periphery' => 'erythrocyte periphery',
      'cytostomal vacuole' => 'cytostome',
      'pv subdomains' => 'parasitophorous vacuole subdomains',
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
  def upload_falciparum_list(filename='/home/ben/phd/gene lists/falciparum.csv')
    upload_localisations_for_species Species::FALCIPARUM_NAME, filename
  end

  def upload_localisations_for_species(species_name, filename)
    upload_list_gene_ids species_name, filename
    LiteratureDefinedCodingRegionAlternateStringId.new.check_for_inconsistency species_name
    upload_list_localisations species_name, filename
  end

  # Remove words like 'sometimes' or 'strong' from localisation strings.
  # A strength modifier can either be accepted or ignored.
  # for ignored ones (like sometimes), this returns false
  # for accepted ones (like strong), this returns the localisation
  # string without the modifier.
  #
  # It is the localisation that should be ignored, not the modifier.
  # Having trouble thinking of a better word for this.
  def remove_strength_modifiers(localisation_string)
    modifiers_ignore = %w(weak sometimes some little)
    modifiers_accept = %w(strong)
    modifiers_ignore.each do |modifier|
      return false if localisation_string.match(/^#{modifier}/)
    end
    modifiers_accept.each do |modifier|
      if localisation_string.match(/^#{modifier} /) or localisation_string.match(/^#{modifier}/)
        return localisation_string.gsub(/^#{modifier} /,'').gsub(/^#{modifier}/,'')
      end
    end
    return localisation_string #only returns here when modifier is legit
  end
  
  # Parse a line from the dirty localisation files. Return an array of (unsaved) ExpressionContext objects
  def parse_name(dirt)
    contexts = []
    
    # split on commas
    dirt.split(',').each do |fragment|
      fragment.strip!
      
      # If gene is not expressed during a certain developmental stage
      if matches = fragment.match('not during (.*)')
        stages = []
        matches[1].split(' and ').each do |stage|
          positive_devs = DevelopmentalStage.find_all_by_name_or_alternate(stage)

          if positive_devs.empty?
            $stderr.puts "No such dev stage '#{stage}' found."
            next
          else
            positive_devs.each do |found|
              negated = DevelopmentalStage.add_negation(found.name)
              d = DevelopmentalStage.find_by_name_or_alternate(negated)
              contexts.push ExpressionContext.new(
                :developmental_stage => d
              )
            end
          end
        end
      elsif matches = fragment.match('^during (.*)')
        stages = []
        matches[1].split(' and ').each do |stage|
          if matches = stage.match(/^not (.+)/)
            positive_devs = DevelopmentalStage.find_all_by_name_or_alternate(matches[1])
            if positive_devs.empty?
              $stderr.puts "No such dev stage '#{matches[1]}' found."
              next
            end
            positive_devs.each do |found|
              negated = DevelopmentalStage.add_negation(found.name)
              d = DevelopmentalStage.find_by_name_or_alternate(negated)
              contexts.push ExpressionContext.new(
                :developmental_stage => d
              )
            end
          else
            str = remove_strength_modifiers(stage)
            next unless str #ignore when they say weak, accept when they say strong
            positive_devs = DevelopmentalStage.find_all_by_name_or_alternate(str)
            if positive_devs.empty?
              $stderr.puts "No such dev stage '#{stage}' found."
              next
            end
            positive_devs.each do |found|
              d = DevelopmentalStage.find_by_name_or_alternate(found.name)
              contexts.push ExpressionContext.new(
                :developmental_stage => d
              )
            end
          end
        end
        
        # gene is expressed in a localisation during a particular developmental
        # stage
      elsif matches = fragment.match('^(.*) during (.*)')
        stages = []
        
        # split each of the localisations by 'and', 'then', etc.
        locs = parse_small_name(matches[1])
        
        # split each of the stages by 'and'
        matches[2].split(' and ').each do |stage|
          d = []
          if matches = stage.match(/^not (.+)/)
            # for things like during late schizont and not ring and not troph
            d = DevelopmentalStage.find_all_by_name_or_alternate(stage)
            d.each do |found|
              d.push DevelopmentalStage.find_all_by_name_or_alternate(
                DevelopmentalStage.add_negation(found.name)
              )
            end
            DevelopmentalStage.add_negation(stage.name)
          else
            # for normaler things without negation like during late schizont
            d = DevelopmentalStage.find_all_by_name_or_alternate(stage)
          end

          if d.empty?
            $stderr.puts "No such dev stage '#{stage}' found."
            next
          else
            stages.push d
          end
        end
        stages.flatten!

        # add each of the resulting pairs
        locs.pairs(stages).each do |arr|
          if arr[0] == true
            contexts.push ExpressionContext.new(
              :developmental_stage => arr[1]
            )
          else
            contexts.push ExpressionContext.new(
              :localisation => arr[0],
              :developmental_stage => arr[1]
            )
          end
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
      loc.split(' then ').each do |loc2|
        l = parse_small_small_name(loc2)
        locs.push l unless l.nil?
      end
    end
    return locs
  end
  
  def parse_small_small_name(frag)
    frag.strip!
    frag.downcase!
    str = remove_strength_modifiers(frag)
    return nil unless str #ignore weak localisations

    # when there is a strong signal without a localisation
    # to go with it, return true
    return true if str == ''
    
    l = Localisation.find_by_name_or_alternate(str)
    if !l and matches = str.match(/^not (.+)$/)
      syn = LocalisationSynonym.find_by_name(matches[1])
      if syn
        l = Localisation.find_by_name("not #{syn.localisation.name}")
      end
    end
    
    unless l
      $stderr.puts "Localisation not understood: '#{str}' from '#{frag}'"
      return nil
    end
    return l
  end
  
end

  
class ParseException < Exception
end
