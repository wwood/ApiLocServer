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
    end
    
    {
      'hepatocyte stage' => 'hepatocyte',
      'early ring' => 'ring',
      'trophs' => 'trophozoite',
      'rings' => 'ring',
      'merozoites' => 'merozoite',
      'mature schizonts' => 'schizont',
      'early schizonts' => 'schizont',
      'troph' => 'trophozoite',
      'schizonts' => 'schizont',
      'late troph' => 'trophozoite',
      'rings' => 'ring',
      'late schizont' => 'schizont'
    }.each do |key, value|
      dev = DevelopmentalStage.find_by_name(value)
      raise if !dev
      raise if !DevelopmentalStageSynonym.find_or_create_by_name_and_developmental_stage_id(
        key, dev.id
      )
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
end
