require 'csv'
require 'localisation_constants'

class Localisation < ActiveRecord::Base

  belongs_to :species
  
  has_many :coding_regions, :through => :coding_region_localisations
  has_many :coding_region_localisations, :dependent => :destroy
  has_many :expression_contexts, :dependent => :destroy
  has_many :second_class_citizen_expression_contexts, :dependent => :destroy
  has_many :metabolic_maps_expression_contexts, :dependent => :destroy
  has_many :expressed_coding_regions, :through => :expression_contexts, :source => :coding_region
  
  has_one :malaria_localisation_top_level_localisation
  has_one :malaria_top_level_localisation, 
    :through => :malaria_localisation_top_level_localisation,
    :source => :top_level_localisation

  has_one :apiloc_localisation_top_level_localisation
  has_one :apiloc_top_level_localisation,
    :through => :apiloc_localisation_top_level_localisation,
    :source => :top_level_localisation
  
  has_many :localisation_synonyms, :dependent => :destroy

  has_many  :go_term_localisations, :dependent => :destroy
  has_many :localisations, :through => :go_term_localisations
  
  named_scope :recent, lambda { { :conditions => ['created_at > ?', 1.week.ago] } }
  named_scope :known, lambda { { :conditions => [
        'name in (?)', KNOWN_LOCALISATIONS[Species::FALCIPARUM_NAME]] } }
  named_scope :positive, {
    :conditions => ['localisations.name not like ?', 'not %']
  }
  named_scope :negative, {
    :conditions => ['localisations.name like ?', 'not %']
  }
  
  CYTOPLASM_NOT_ORGANELLAR_PUBLIC_NAME = 'cytoplasm but not organellar' 
  
  # Return a list of ORFs that have this and only this localisation
  def get_individual_localisations
    coding_regions = CodingRegion.find_by_sql(
      "select foo.coding_region_id from (select coding_region_id, count(*) from coding_region_localisations group by coding_region_id having count(*)=1) as foo join coding_region_localisations as food on foo.coding_region_id = food.coding_region_id where food.localisation_id=#{id}"
    )
    return coding_regions
  end
  
  def upload_known_localisations(species)
    failed = false
    KNOWN_LOCALISATIONS[species.name].each do |loc|
      if !Localisation.find_or_create_by_name_and_species_id(loc, species.id)
        $stderr.puts "Failed to upload loc '#{loc}' for some reason"
        failed = true
      end
      
      # not that localisation is also a localisation
      if !Localisation.find_or_create_by_name_and_species_id("not #{loc}", species.id)
        $stderr.puts "Failed to upload NOT loc '#{loc}' for some reason"
        failed = true
      end
    end
    raise if failed
  end

  def upload_known_localisations_unsequenced
    KNOWN_LOCALISATIONS[Species::OTHER_SPECIES].each do |species_name, locs|
      species = Species.find_by_name(species_name)
      locs.each do |loc|
        if !Localisation.find_or_create_by_name_and_species_id(loc, species.id)
          raise Exception, "Failed to upload loc '#{loc}' for some reason"
        end

        # not that localisation is also a localisation
        if !Localisation.find_or_create_by_name_and_species_id("not #{loc}", species.id)
          raise Exception, "Failed to upload NOT loc '#{loc}' for some reason"
        end
      end
    end
  end
  
  def upload_localisation_synonyms(species)
    failed = false
    KNOWN_LOCALISATION_SYNONYMS[species.name].each do |key, value|
      l = value.downcase
      loc = Localisation.find_by_name_and_species_id(l, species.id)
      if loc
        if !LocalisationSynonym.find_or_create_by_localisation_id_and_name(
            loc.id,
            key.downcase
          )
          raise
        end
      else
        $stderr.puts "Could not find localisation #{l} when trying to upload synonym #{key}"
        failed = true
      end
    end
    raise if failed
  end

  def upload_localisation_synonyms_unsequenced
    KNOWN_LOCALISATION_SYNONYMS[Species::OTHER_SPECIES].each do |species_name, loc_sins|
      species = Species.find_by_name(species_name)
      loc_sins.each do |key, value|
        l = value.downcase
        loc = Localisation.find_by_name_and_species_id(l, species.id)
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
    LocalisationModifier.all(:order => 'id desc').each do |mod|
      if localisation_string.match(/^#{mod.modifier}/)
        tor = localisation_string.gsub(/^#{mod.modifier} /,'').gsub(/^#{mod.modifier}/,''), mod.id
        return tor
      end
    end
    # no modifiers found. 
    return localisation_string, nil
  end
  
  # Parse a line from the dirty localisation files. Return an array of (unsaved) ExpressionContext objects
  # also needs a species object (not a species name)
  def parse_name(dirt, species)
    contexts = []
    # split on commas
    dirt.split(',').each do |fragment|
      fragment.strip!
      fragment.downcase!
      
      # If gene is not expressed during a certain developmental stage
      if matches = fragment.match(/^not during (.*)/i)
        stages = []
        matches[1].split(' and ').each do |stage|
          positive_devs = DevelopmentalStage.find_all_by_name_or_alternate(stage, species)

          if positive_devs.empty?
            $stderr.puts "No such dev stage '#{stage}' found in #{species.name}."
            next
          else
            positive_devs.each do |found|
              negated = DevelopmentalStage.add_negation(found.name)
              d = DevelopmentalStage.find_by_name_or_alternate(negated, species)
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
            positive_devs = DevelopmentalStage.find_all_by_name_or_alternate(matches[1], species)
            if positive_devs.empty?
              $stderr.puts "No such dev stage '#{matches[1]}' found in #{species.name}"
              next
            end
            positive_devs.each do |found|
              negated = DevelopmentalStage.add_negation(found.name)
              d = DevelopmentalStage.find_by_name_or_alternate(negated, species)
              contexts.push ExpressionContext.new(
                :developmental_stage => d
              )
            end
          else
            str, modifier_id = remove_strength_modifiers(stage)
            positive_devs = DevelopmentalStage.find_all_by_name_or_alternate(str, species)
            if positive_devs.empty?
              $stderr.puts "No such dev stage '#{stage}' found in #{species.name}."
              next
            end
            positive_devs.each do |found|
              d = DevelopmentalStage.find_by_name_or_alternate(found.name, species)
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
        
        # split each of the localisations by 'and'
        locs = parse_small_name(matches[1], species)
        
        # split each of the stages by 'and'
        matches[2].split(' and ').each do |stage|
          d = []
          if matches = stage.match(/^not (.+)/)
            # for things like during late schizont and not ring and not troph
            d = DevelopmentalStage.find_all_by_name_or_alternate(stage, species)
            d.each do |found|
              $stderr.puts fragment.inspect if found == []
              d.push DevelopmentalStage.find_all_by_name_or_alternate(
                DevelopmentalStage.add_negation(found.name), species
              )
            end
            DevelopmentalStage.add_negation(stage.name)
          else
            # for normaler things without negation like during late schizont
            d = DevelopmentalStage.find_all_by_name_or_alternate(stage, species)
          end

          if d.empty?
            $stderr.puts "No such dev stage '#{stage}' found in #{species.name}."
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
        eees = parse_small_name(fragment, species)
        eees.each do |e|
          contexts.push e
        end
      end
    end
    
    return contexts.flatten
  end
  
  def self.find_by_name_or_alternate(localisation_string, species)
    raise unless species.class == Species
    locs = Localisation.find_all_by_name_and_species_id(localisation_string, species.id)
    return locs[0] if locs.length == 1
    if s = LocalisationSynonym.species_id(species.id).find_by_name(localisation_string)
      return s.localisation
    else
      return nil
    end
  end
  
  
  # To parse names like 'cytoplasm and rbc surface' or 'pv then rbc surface'
  def parse_small_name(fragment, species)
    locs = []

    if LOCALISATIONS_WITH_AND_IN_THEIR_NAME.include?(fragment)
      loc = fragment
      loc.strip!
      e = parse_small_small_name(loc, species)
      locs.push e unless e.nil?
    else
      fragment.split(' and ').each do |loc|
        loc.strip!
        e = parse_small_small_name(loc, species)
        locs.push e unless e.nil?
      end
    end
    return locs
  end
  
  def parse_small_small_name(frag, species)
    frag.strip!
    frag.downcase!
    e = ExpressionContext.new
    str, modifier_id = remove_strength_modifiers(frag)
    e.localisation_modifier_id = modifier_id

    unless str == '' #empty strings are ok, but there's no loc info in them
      l = Localisation.find_by_name_or_alternate(str, species)
      if !l and matches = str.match(/^not (.+)$/)
        syn = LocalisationSynonym.find_by_name(matches[1], species)
        if syn
          l = Localisation.find_by_name(
            Localisation.add_negation(syn.localisation.name), species)
        end
      end
    
      unless l
        $stderr.puts "Localisation not understood: '#{str}' from '#{frag}' in #{species.name}"
      else
        e.localisation_id = l.id
      end
    end
    return e
  end


  def self.add_negation(localisation)
    "not #{localisation}"
  end

  # return the negative of this localisation
  def negation
    if negative?
      matches = name.match(/^not (.*)/)
      raise Exception, "Programmming error!" if matches.nil?
      t = Localisation.find_by_name(matches[1])
      raise if t.nil?
      return t
    else
      t = Localisation.find_by_name(Localisation.add_negation(name))
      raise if t.nil?
      return t
    end
  end
  
  # Is this a negative localisation?
  def negative?
    !(name.match(/^not (.*)/).nil?)
  end 

  def map_to_go_term_multiple
    # manually mapped ones
    manual_mappings = {
      'apical' => 'GO:0020007',
      # add more manual mappings here
    }
    if manual_mappings[name]
      return [
        GoTerm.find_by_go_identifier(manual_mappings[name])
      ]
    end

    # automatic full hit to go term or synonym
    hits = GoTerm.find_all_by_term_and_aspect_or_synonym(name, GoTerm::CELLULAR_COMPONENT)

    # partial hit to go term or synonym
    if hits.empty?
      hits = [
        GoTerm.all(:conditions => ['term like ?',"%#{name}%"]),
        GoSynonym.all(:conditions => ['synonym like ?',"%#{name}%"]).reach.go_term.uniq,
      ].flatten
    end

    return hits
  end

  include LocalisationConstants
end

  
class ParseException < Exception
end
