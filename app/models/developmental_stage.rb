class DevelopmentalStage < ActiveRecord::Base
  has_many :expression_contexts, :dependent => :destroy
  has_many :developmental_stage_synonyms
  
  # Unknown developmental stage
  UNKNOWN_NAME = 'unknown'
  
  def upload_known_falciparum_developmental_stages
    [
      'ring',
      'trophozoite',
      'schizont',
      'sporozoite',
      'merozoite',
      'hepatocyte',
      'gametocytogenesis',
      'gametocyte stage I',
      'gametocyte stage II',
      'gametocyte stage III',
      'gametocyte stage IV',
      'gametocyte'
    ].each do |name|
      DevelopmentalStage.find_or_create_by_name(name) or raise
      DevelopmentalStage.find_or_create_by_name(DevelopmentalStage.add_negation(name)) or raise
    end
    
    {
      'hepatocyte stage' => 'hepatocyte',
      'early ring' => 'ring',
      'late ring' => 'ring',
      'trophs' => 'trophozoite',
      'rings' => 'ring',
      'merozoites' => 'merozoite',
      'mature schizonts' => 'schizont',
      'early schizonts' => 'schizont',
      'troph' => 'trophozoite',
      'schizonts' => 'schizont',
      'late troph' => 'trophozoite',
      'late trophozoite' => 'trophozoite',
      'late schizont' => 'schizont',
      'mature schizont' => 'schizont',
      'blood stages' => ['ring', 'trophozoite', 'schizont']
    }.each do |key, value|
      if value.kind_of?(Array)
        value.each {|name| upload_stage_synonym(key, name)}
      else
        upload_stage_synonym(key, value)
      end
    end
  end
  
  def self.find_by_name_or_alternate(name)
    me = DevelopmentalStage.find_by_name(name)
    return me if me
    if s = DevelopmentalStageSynonym.find_by_name(name)
      return s.developmental_stage
    end
    return nil
  end
  
  def self.find_all_by_name_or_alternate(name)
    all = DevelopmentalStage.find_all_by_name(name)
    all.push(
      DevelopmentalStageSynonym.find_all_by_name(name).reach.developmental_stage.retract
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
  # small method to DRY another method
  def upload_stage_synonym(synonym, name)
    dev = DevelopmentalStage.find_by_name(name)
    raise if !dev
    raise if !DevelopmentalStageSynonym.find_or_create_by_name_and_developmental_stage_id(
      synonym, dev.id
    )
  end
end
