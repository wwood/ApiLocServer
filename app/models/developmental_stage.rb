class DevelopmentalStage < ActiveRecord::Base
  has_many :expression_contexts, :dependent => :destroy
  has_many :developmental_stage_synonyms
  
  # Unknown developmental stage
  UNKNOWN_NAME = 'unknown'
  
  def upload_known_falciparum_developmental_stages
    [
      'intraerythrocytic',
      'early intraerythrocytic',
      'late intraerythrocytic',
      'ring',
      'early ring',
      'late ring',
      'trophozoite',
      'early trophozoite',
      'middle schizont',
      'late trophozoite',
      'late trophozoite or early schizont',
      'late trophozoite or schizont',
      'schizont',
      'early schizont',
      'late schizont',
      'segmenter',
      'segmenting schizonts',
      'rupturing schizont',
      'merozoite',
      'after parasitophorous vacuole membrane breakdown',
      'after microneme exocytosis',
      'sporozoite',
      'extracellular merozoite',
      'after rupture', #after the RBC has ruptured. Not the same as free merozoite, but sort of I guess
      'invasion',
      'hepatocyte sporozoite',
      'hepatocyte',
      'early hepatocyte',
      'late hepatocyte',
      'hepatocyte schizont',
      'hepatocyte stage day 3',
      'hepatocyte stage day 5',
      'hepatocyte stage day 7',
      'hepatocyte merozoite',
      'gametocytogenesis',
      'gametocyte stage I',
      'gametocyte stage II',
      'gametocyte stage III',
      'gametocyte stage IV',
      'gametocyte stage V',
      'male gametocyte stage I',
      'male gametocyte stage II',
      'male gametocyte stage III',
      'male gametocyte stage IV',
      'male gametocyte stage V',
      'female gametocyte stage I',
      'female gametocyte stage II',
      'female gametocyte stage III',
      'female gametocyte stage IV',
      'female gametocyte stage V',
      'exflagellating male gametocyte',
      'gametocyte',
      'developing gametocyte',
      'gametocyte ring',
      'emerging gametocyte',
      'non-activated gametocyte', #a unemerged gametocyte
      'emerged gametocyte',
      'mature gametocyte',
      'female gametocyte',
      'male gametocyte',
      'emerging male gametocyte',
      'emerged male gametocyte',
      'female gamete',
      'gamete',
      'gamete formation',
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
      '30h',
      '40h',
      '24h after invasion',
      '12h',
      '48h',
      '18-36 hours',
      '60hr post invasion',
      'several hours post invasion',
      'multiple infected erythrocyte ring',
      'double infected erythrocyte trophozoites',
    ].each do |name|
      DevelopmentalStage.find_or_create_by_name(name) or raise
      DevelopmentalStage.find_or_create_by_name(DevelopmentalStage.add_negation(name)) or raise
    end
    
    {
      'mid schizont' => 'middle schizont',
      'intraerythrocytic stages' => 'intraerythrocytic',
      'double infected trophozoites' => 'double infected erythrocyte trophozoites',
      'emerged gamete' => 'emerged gametocyte',
      'small troph' => 'early trophozoite',
      'large troph' => 'late trophozoite',
      'free merozoites' => 'extracellular merozoite',
      'dividing troph' => 'schizont',
      'dispersed merozoite' => 'extracellular merozoite',
      'late troph or early schizont' => 'late trophozoite or early schizont',
      'following schizont rupture' => 'after rupture',
      'gametocyte rings' => 'gametocyte ring',
      'very mature schizont' => 'segmenter',
      'late asexual stage' => 'late intraerythrocytic',
      'fully mature schizont' => 'segmenter',
      'fully mature merozoite' => 'segmenter',
      'early intraerythrocytic stages' => 'early intraerythrocytic',
      'mature intraerythrocytic' => 'late intraerythrocytic',
      'late segmented schizont' => 'segmenter',
      'hepatic' => 'hepatocyte',
      'after PVM breakdown' => 'after parasitophorous vacuole membrane breakdown',
      'liver stage sporozoite' => 'hepatocyte sporozoite',
      'activated gametocyte' => 'emerged gametocyte',
      'late troph or schizont' => 'late trophozoite or schizont',
      'released merozoite' => 'extracellular merozoite',
      'released merozoites' => 'extracellular merozoite',
      'liver stages' => 'hepatocyte',
      'free male gametocyte' => 'emerged male gametocyte',
      'after gametocyte emergence' => 'emerged gametocyte',
      'stage III male gametocyte' => 'male gametocyte stage III',
      'stage IV male gametocyte' => 'male gametocyte stage IV',
      'stage V male gametocyte' => 'male gametocyte stage V',
      'stage III female gametocyte' => 'female gametocyte stage III',
      'stage IV female gametocyte' => 'female gametocyte stage IV',
      'stage V female gametocyte' => 'female gametocyte stage V',
      'red cell-membrane free gametocytes' => 'emerged gametocyte',
      'liver merozoite' => 'hepatocyte merozoite',
      'liver schizont' => 'hepatocyte schizont',
      'gametocyte emergence' => 'emerging gametocyte',
      'emerging microgametocyte' => 'emerging male gametocyte',
      'emerged microgametocyte' => 'emerged male gametocyte',
      'emerged microgamete' => 'emerged male gametocyte',
      'developing gametocytes' => 'developing gametocyte',
      'intact schizont' => 'early schizont',
      'mature' => 'schizont',
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
      'young trophs' => 'early trophozoite',
      'young troph' => 'early trophozoite',
      'old trophs' => 'late trophozoite',
      'old troph' => 'late trophozoite',
      'old trophozoite' => 'late trophozoite',
      'mature troph' => 'late trophozoite',
      'rings' => 'ring',
      'merozoites' => 'merozoite',
      'mature schizonts' => 'late schizont',
      'mature intraerythcytic' => 'schizont',
      'mature schizont' => 'late schizont',
      'immature schizont' => 'early schizont',
      'segmented schizont' => 'late schizont',
      'extracellular schizont' => 'extracellular merozoite',
      'mature trophozoite' => 'late trophozoite',
      'troph' => 'trophozoite',
      'young trophozoite' => 'early trophozoite',
      'schizonts' => 'schizont',
      'young schizont' => 'early schizont',
      'early troph' => 'early trophozoite',
      'intracellular' => 'intraerythrocytic',
      'asexual' => 'intraerythrocytic',
      'erythrocytic stage' => 'intraerythrocytic',
      'blood stages' => ['ring', 'trophozoite', 'schizont'],
      'asexual stages' => ['ring', 'trophozoite', 'schizont', 'merozoite'],
      'erythrocytic stages' => ['ring', 'trophozoite', 'schizont', 'merozoite'],
      'stage I gametocyte' => 'gametocyte stage I',
      'stage II gametocyte' => 'gametocyte stage II',
      'stage III gametocyte' => 'gametocyte stage III',
      'stage IV gametocyte' => 'gametocyte stage IV',
      'stage V gametocyte' => 'gametocyte stage V',
      'stage V gametocytes' => 'gametocyte stage V',
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
    raise Exception, "No primary dev stage #{name} found from #{synonym}" unless dev
    raise if !DevelopmentalStageSynonym.find_or_create_by_name_and_developmental_stage_id(
      synonym, dev.id
    )
  end
end
