require 'developmental_stage_constants'

class DevelopmentalStage < ActiveRecord::Base
  include DevelopmentalStageConstants

  has_many :expression_contexts, :dependent => :destroy
  has_many :developmental_stage_synonyms
  belongs_to :species

  # Unknown developmental stage
  UNKNOWN_NAME = 'unknown'
  
  def upload_known_developmental_stages(sp)
    species_name = sp.name
    KNOWN_DEVELOPMENTAL_STAGES[species_name].each do |name|
      name.downcase!
      DevelopmentalStage.find_or_create_by_name_and_species_id(name, sp.id) or raise
      DevelopmentalStage.find_or_create_by_name_and_species_id(DevelopmentalStage.add_negation(name), sp.id) or raise
    end
    
    KNOWN_DEVELOPMENTAL_STAGE_SYNONYMS[species_name].each do |key, value|
      if value.kind_of?(Array)
        value.each do |name|
          name.downcase!
          upload_stage_synonym(key, name, sp)
        end
      else
        upload_stage_synonym(key.downcase, value.downcase, sp)
      end
    end
  end

  def upload_known_developmental_stages_unsequenced
    KNOWN_DEVELOPMENTAL_STAGES[Species::OTHER_SPECIES].each do |species_name, devs|
      sp = Species.find_or_create_by_name(species_name)
      devs.each do |name|
        name.downcase!
        DevelopmentalStage.find_or_create_by_name_and_species_id(name, sp.id) or raise
        DevelopmentalStage.find_or_create_by_name_and_species_id(DevelopmentalStage.add_negation(name), sp.id) or raise
      end
    end

    KNOWN_DEVELOPMENTAL_STAGE_SYNONYMS[Species::OTHER_SPECIES].each do |species_name, devil_sinners|
      sp = Species.find_by_name(species_name)
      devil_sinners.each do |key, value|
        if value.kind_of?(Array)
          value.each do |name|
            name.downcase!
            upload_stage_synonym(key, name, sp)
          end
        else
          upload_stage_synonym(key.downcase, value.downcase, sp)
        end
      end
    end
  end
  
  def self.find_by_name_or_alternate(name, species)
    me = DevelopmentalStage.find_by_name_and_species_id(name, species.id)
    return me if me
    if s = DevelopmentalStageSynonym.species(species.name).find_by_name(name)
      return s.developmental_stage
    end
    return nil
  end
  
  def self.find_all_by_name_or_alternate(name, species)
    all = DevelopmentalStage.find_all_by_name_and_species_id(name, species.id)
    all.push(
      DevelopmentalStageSynonym.species(
        species.name
      ).find_all_by_name(name).reach.developmental_stage.retract
    )
    all.flatten
  end
  
  def <=>(another)
    id <=>another.id
  end
  
  # Defining the grammar for defining negation of a developmental
  # stage, like 'not ring'. Generally means it is not expressed during this
  # time
  def self.add_negation(name)
    "not #{name}"
  end
  
  private
  # small method to DRY another method. species is a Species object
  def upload_stage_synonym(synonym, name, species)
    dev = DevelopmentalStage.find_by_name_and_species_id(name, species.id)
    raise Exception, "No primary dev stage #{name} found from #{synonym}" unless dev
    raise unless DevelopmentalStageSynonym.find_or_create_by_name_and_developmental_stage_id(
      synonym, dev.id
    )
  end
end
