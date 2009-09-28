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
    'erythrocyte cytoplasmic structures near parasitophorous vacuole',
    'erythrocyte',
    'single small vesicles in erythrocyte',
    'exported',
    'cytoplasmic side of erythrocyte membrane',
    'beyond erythrocyte membrane',
    'membrane of lysed erythrocyte',
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
    'nowhere except apicoplast',
    'near apicoplast membranes',
    'innermost apicoplast membrane',
    'outermost apicoplast membrane',
    'cytosol',
    'cytoplasm',
    'nucleus',
    'nuclear membrane',
    'electron-dense heterochromatic region at the nuclear periphery',
    'nuclear interior',
    'cis golgi',
    'trans golgi',
    'golgi',
    'golgi matrix',
    'endoplasmic reticulum',
    'endoplasmic reticulum associated vesicles',
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
    'apical parasite plasma membrane',
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
    'perinuclear',
    'far nuclear periphery',
    'interior of nucleus',
    'foci near nucleus',
    'internal organelles',
    'intracellular',
    'cytoplasmic structures',
    'spread around parasite',
    'throughout parasite',
    'poles',
    'discrete compartments at parasite periphery',
    'around cytomeres',
    'around merozoite',
    'exoneme',
    'telomeric cluster',
    'surrounding parasite',
    'residual body membrane',
    'residual body',
    'exflagellation centre',
    'membrane structure',
    'straight side of d shaped parasite', # A P. falciparum specific localisation
    'internal membrane networks',
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
      'discrete dots on ppm' => 'parasite plasma membrane',
      'spotted in the erythrocyte cytoplasm' => 'erythrocyte cytoplasmic structures',
      'granules near pv in erythrocyte cytoplasm' => 'erythrocyte cytoplasmic structures near parasitophorous vacuole',
      'small double membrane-bound small hemoglobin-containing vacuoles' => 'cytostome',
      'intraerythrocytic spots' => 'erythrocyte cytoplasmic structures',
      'released extracellularly' => 'beyond erythrocyte membrane',
      'small structures in parasite' => 'cytoplasmic structures',
      'parasite nucleus' => 'nucleus',
      'dispersed fluorescent patches underneath erythrocyte surface' => 'erythrocyte periphery',
      'membrane bound vesicles' => 'vesicles',
      'tvn' => 'tubulovesicular membrane',
      'fvm' => 'food vacuole membrane',
      'intraparasitic vacuoles' => 'intracellular vacuole',
      'tubulovesicular system' => 'tubulovesicular membrane',
      'er associated vesicles' => 'endoplasmic reticulum associated vesicles',
      'infected erythrocyte' => 'erythrocyte cytoplasm',
      'irbc' => 'erythrocyte cytoplasm',
      'anterior' => 'apical',
      'surrounding intracellular merozoite' => 'surrounding parasite',
      'small vesicles in erythrocyte cytoplasm' => 'single small vesicles in erythrocyte',
      'telomere cluster' => 'telomeric cluster',
      'nucleus surrounding regions' => 'area around nucleus',
      'periphery of cytoplasm' => 'peripheral',
      'circumference' => 'parasite plasma membrane',
      'discrete dots on parasite plasma membrane' => 'parasite plasma membrane',
      'cytoplasm of host infected erythrocyte' => 'erythrocyte cytoplasm',
      'surface membrane' => 'parasite plasma membrane',
      'peripheral cytoplasm' => 'peripheral',
      'golgi aparatus' => 'golgi',
      'vesicles like structures' => 'vesicles',
      'apical surface' => 'apical parasite plasma membrane',
      'rbc cytosol' => 'erythrocyte cytosol',
      'parasite rim' => 'peripheral',
      'telomeric clusters' => 'telomeric cluster',
      'widely distributed in apical' => 'apical',
      'apical foci' => 'apical',
      'parasite cytoplasm' => 'cytoplasm',
      'host cell cytoplasm' => 'erythrocyte cytoplasm',
      'cell' => 'intracellular',
      'pv related structures in erythrocyte cytoplasm' => 'cleft like parasitophorous vacuole membrane protrusions',
      'cytoplasmic face of erthrocyte plasma membrane' => 'cytoplasmic side of erythrocyte membrane',
      'with membrane' => 'parasite plasma membrane',
      'vesicles in infected erythrocyte cytoplasm' => 'erythrocyte cytoplasmic structures',
      'intracellular bright spots' => 'intracellular',
      'almost exclusively cytoplasm' => 'cytoplasm',
      'close to membrane in apicoplast' => 'near apicoplast membranes',
      'perinuclear spots' => 'perinuclear',
      'electron sparse nuclear interior' => 'nuclear interior',
      'apicoplast only' => 'nowhere except apicoplast',
      'parasite' => 'intracellular',
      'in association with the parasite plasmalemma' => 'parasite plasma membrane',
      'parasite membrane' => 'parasite plasma membrane',
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

  # Remove words like 'sometimes' or 'strong' from localisation strings, and
  # add them to the given expression context
  #
  # Assumes the context is a single word, and that the string given is at
  # least 1 word long.
  #
  # Returns the modified localisation string
  def remove_strength_modifiers(localisation_string)
    mod = LocalisationModifier.find_by_modifier(localisation_string.strip.split(' ')[0])
    if mod
      tor = localisation_string.gsub(/^#{mod.modifier} /,'').gsub(/^#{mod.modifier}/,''), mod.id
      return tor
    else
      return localisation_string, nil
    end
  end
  
  # Parse a line from the dirty localisation files. Return an array of (unsaved) ExpressionContext objects
  def parse_name(dirt)
    contexts = []
    
    # split on commas
    dirt.split(',').each do |fragment|
      fragment.strip!
      
      # If gene is not expressed during a certain developmental stage
      if matches = fragment.match(/^not during (.*)/i)
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
            str, modifier_id = remove_strength_modifiers(stage)
            positive_devs = DevelopmentalStage.find_all_by_name_or_alternate(str)
            if positive_devs.empty?
              $stderr.puts "No such dev stage '#{stage}' found."
              next
            end
            positive_devs.each do |found|
              d = DevelopmentalStage.find_by_name_or_alternate(found.name)
              contexts.push ExpressionContext.new(
                :developmental_stage => d,
                :localisation_modifier_id => modifier_id
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
          loc_e = arr[0]
          dev = arr[1]

          contexts.push ExpressionContext.new(
            :localisation_id => loc_e.localisation_id,
            :localisation_modifier_id => loc_e.localisation_modifier_id,
            :developmental_stage => dev
          )
        end
        
      else #no during - it's just a straight localisation
        # split each of the localisations by 'and' and 'then'
        eees = parse_small_name(fragment)
        eees.each do |e|
          contexts.push e
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
        e = parse_small_small_name(loc2)
        locs.push e unless e.nil?
      end
    end
    return locs
  end
  
  def parse_small_small_name(frag)
    frag.strip!
    frag.downcase!
    e = ExpressionContext.new
    str, modifier_id = remove_strength_modifiers(frag)
    e.localisation_modifier_id = modifier_id

    unless str == '' #empty strings are ok, but there's no loc info in them
      l = Localisation.find_by_name_or_alternate(str)
      if !l and matches = str.match(/^not (.+)$/)
        syn = LocalisationSynonym.find_by_name(matches[1])
        if syn
          l = Localisation.find_by_name("not #{syn.localisation.name}")
        end
      end
    
      unless l
        $stderr.puts "Localisation not understood: '#{str}' from '#{frag}'"
      else
        e.localisation_id = l.id
      end
    end
    return e
  end
  
end

  
class ParseException < Exception
end
