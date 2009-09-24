class DevelopmentalStage < ActiveRecord::Base
  has_many :expression_contexts, :dependent => :destroy
  has_many :developmental_stage_synonyms
  
  # Unknown developmental stage
  UNKNOWN_NAME = 'unknown'
  
  def upload_known_falciparum_developmental_stages
    [
      'ring',
      'early ring',
      'late ring',
      'trophozoite',
      'early trophozoite',
      'late trophozoite',
      'schizont',
      'early schizont',
      'late schizont',
      'sporozoite',
      'merozoite',
      'extracellular merozoite',
      'hepatocyte',
      'early hepatocyte',
      'late hepatocyte',
      'hepatocyte merozoite',
      'gametocytogenesis',
      'gametocyte stage I',
      'gametocyte stage II',
      'gametocyte stage III',
      'gametocyte stage IV',
      'gametocyte',
      'female gametocyte',
      'male gametocyte',
      'retort',
      'oocyst protrusion', #perhaps there is a better name for this. It is like retort except it is the ookinete->oocyst, not zygote->ookinete
      'merozoite invasion', #blood stage only, not liver->blood merozoite
      'ookinete',
      'gametocyte committed early ring',
      'salivary gland sporozoite',
      'oocyst sporozoite',
      'hemocoel sporozoite',
      'oocyst',
      'early oocyst',
      'sporulating oocyst',
      'ookinete retort',
      'midgut oocyst',
      'mature ookinete',
      'zygote',
      'sporozoite invasion',
      'after sporozoite invasion',
      'developing oocyst',
    ].each do |name|
      DevelopmentalStage.find_or_create_by_name(name) or raise
      DevelopmentalStage.find_or_create_by_name(DevelopmentalStage.add_negation(name)) or raise
    end
    
    {
      'hemolymph sporozoite' => 'oocyst sporozoite',
      'ookinete protrusion' => 'retort',
      'young oocyst' => 'early oocyst',
      'early hepatic stages' => 'early hepatocyte',
      'oocyst derived sporozoite' => 'oocyst sporozoite',
      'midgut sporozoite' => 'oocyst sporozoite',
      'microgametes' => 'male gametocyte',
      'macrogametes' => 'female gametocyte',
      'salivary gland sporozoites' => 'salivary gland sporozoite',
      'macrogamete' => 'female gametocyte',
      'microgamete' => 'male gametocyte',
      'intracellular merozoite' => 'late schizont',
      'free merozoite' => 'extracellular merozoite',
      'hepatocyte stage' => 'hepatocyte',
      'trophs' => 'trophozoite',
      'rings' => 'ring',
      'merozoites' => 'merozoite',
      'mature schizonts' => 'late schizont',
      'mature schizont' => 'late schizont',
      'immature schizont' => 'early schizont',
      'segmented schizont' => 'late schizont',
      'mature trophozoite' => 'late trophozoite',
      'troph' => 'trophozoite',
      'young trophozoite' => 'early trophozoite',
      'schizonts' => 'schizont',
      'young schizont' => 'early schizont',
      'early troph' => 'early trophozoite',
      'blood stages' => ['ring', 'trophozoite', 'schizont'],
      'asexual stages' => ['ring', 'trophozoite', 'schizont', 'merozoite'],
      'erythrocytic stages' => ['ring', 'trophozoite', 'schizont', 'merozoite'],
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
