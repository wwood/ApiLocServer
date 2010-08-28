class DevelopmentalStageTopLevelDevelopmentalStage < ActiveRecord::Base
  belongs_to :developmental_stage
  belongs_to :top_level_developmental_stage
  
  APILOC_DEVELOPMENTAL_STAGE_TOP_LEVEL_DEVELOPMENTAL_STAGES = {
    '11-16 days after mosquito infective blood meal' => "sporozoite",
    '12 hours after merozoite invasion' => "ring",
    '16 hours after tachyzoite infection' => "tachyzoite",
    '18-36 hours after merozoite invasion' => "trophozoite",
    '20 hours after tachyzoite infection' => "tachyzoite",
    '24 hours after merozoite invasion' => "trophozoite",
    '24 hours after tachyzoite infection' => "tachyzoite",
    '2 hours after sporozoite invasion of hepatocyte' => "liver stage",
    '30 hours after merozoite invasion' => "trophozoite",
    '40 hours after merozoite invasion' => "schizont",
    '48 hours after merozoite invasion' => "schizont",
    '60 hours after sporozoite invasion of hepatocyte' => "liver stage",
    '7 day old oocyst' => "oocyst",
    '7 hours post sporozoite infection' => "liver stage",
    '14 hours post sporozoite infection' => "liver stage",
    '24 hours post sporozoite infection' => "liver stage",
    '40 hours post sporozoite infection' => "liver stage",
    '48 hours post sporozoite infection' => "liver stage",
    '8 hours after sporozoite invasion of hepatocyte' => "liver stage",
    'activated microgametocyte' => "gametocyte",
    'after assembly of tachyzoite daughter cells' => "tachyzoite",
    'after tachyzoite cell division' => 'tachyzoite',
    'after liver stage completion of daughter parasite development' => 'liver stage',
    'after microneme exocytosis' => "merozoite",
    'after parasitophorous vacuole membrane breakdown' => "schizont",
    'after rupture' => "merozoite", #after the RBC has ruptured. Not the same as free merozoite, but sort of I guess
    'after tachyzoite division' => "tachyzoite",
    'after tachyzoite invasion' => "tachyzoite",
    'after trophozoite' => "schizont",
    'after sporozoite invasion of hepatocyte' => "liver stage",
    'after sporozoite invasion of enteric cells' => 'trophozoite',
    'blood stages' => "unspecified",
    'bradyzoite' => "bradyzoite",
    'cytomere' => "liver stage",
    'daughter cell formation' => "unspecified",
    'daughter tachyzoites before acquisition of plasma membrane' => "tachyzoite",
    'daughter tachyzoite' => "tachyzoite",
    'day 15 oocyst' => "oocyst",
    'day 4 bradyzoite' => "bradyzoite",
    'day 2 oocyst' => "oocyst",
    'day 12 oocyst' => "oocyst",
    'day 5 oocyst' => "oocyst",
    'developing gametocyte' => "gametocyte",
    'developing oocyst' => "oocyst",
    'developing schizont' => "schizont",
    'double infected erythrocyte trophozoites' => "trophozoite",
    'early blood stages' => "ring",
    'early first generation schizont' => "schizont",
    'early gametocyte' => "gametocyte",
    'early hepatic' => "liver stage",
    'early hepatocyte' => "liver stage",
    'early intracellular tachyzoite' => "tachyzoite",
    'early intraerythrocytic' => "ring",
    'early liver schizont' => 'liver stage',
    'early macrogamete' => "gamete",
    'early macrogametocyte' => "gametocyte",
    'early merozoite' => "merozoite",
    'early microgamete' => "gamete",
    'early multinucleate tachyzoite' => "tachyzoite",
    'early oocyst' => "oocyst",
    'early retort' => "ookinete",
    'early ring' => "ring",
    'early schizont' => "schizont",
    'early second generation schizont' => "schizont",
    'early single intracellular merozoite' => "merozoite",
    'early tachyzoite cell division' => 'tachyzoite',
    'early tachyzoite g1 phase' => "tachyzoite",
    'early tachyzoite invasion' => "tachyzoite",
    'early- to mid- stage schizont' => "schizont",
    'early trophozoite' => "trophozoite",
    'emerged gametocyte' => "gametocyte",
    'emerged male gametocyte' => "gametocyte",
    'emerging gametocyte' => "gametocyte",
    'emerging male gametocyte' => "gametocyte",
    'empty oocyst' => "oocyst",
    'enlarging schizont' => "schizont",
    'enteric' => "unspecified",
    'exflagellating male gametocyte' => "gametocyte",
    'extracellular merozoite' => "merozoite",
    'extracellular microgamete' => "gamete",
    'extracellular sporozoite' => "sporozoite",
    'extracellular tachyzoite' => "tachyzoite",
    'female gamete' => "gamete",
    'female gametocyte' => "gametocyte",
    'female gametocyte stage I' => "gametocyte",
    'female gametocyte stage II' => "gametocyte",
    'female gametocyte stage III' => "gametocyte",
    'female gametocyte stage IV' => "gametocyte",
    'female gametocyte stage V' => "gametocyte",
    'first division of bradyzoite' => "bradyzoite",
    'first generation merozoite' => "merozoite",
    'flagellate growth' => "gametocyte",
    'free microgamete' => "gamete",
    'freshly excysted sporozoite' => "sporozoite",
    'fully sporulated oocyst' => "oocyst",
    'gamete formation' => "gamete",
    'gamete' => "gamete",
    'gametocyte committed early ring' => "ring",
    'gametocyte' => "gametocyte",
    'gametocyte ring' => "gametocyte",
    'gametocyte stage I' => "gametocyte",
    'gametocyte stage II' => "gametocyte",
    'gametocyte stage III' => "gametocyte",
    'gametocyte stage III-V' => "gametocyte",
    'gametocyte stage IV' => "gametocyte",
    'gametocyte stage V' => "gametocyte",
    'gametocytogenesis' => "gametocyte",
    'hemocoel sporozoite' => "sporozoite",
    'hemolymph sporozoite' => "sporozoite",
    'hepatic' => "liver stage",
    'hepatocyte' => "liver stage",
    'hepatocyte merozoite' => "liver stage",
    'hepatocyte schizont' => "liver stage",
    'hepatocyte sporozoite' => "sporozoite",
    'hepatocyte stage day 2' => "liver stage",
    'hepatocyte stage day 3' => "liver stage",
    'hepatocyte stage day 4' => "liver stage",
    'hepatocyte stage day 5' => "liver stage",
    'hepatocyte stage day 7' => "liver stage",
    'host cell exposed extracellular sporozoite' => "sporozoite",
    'immature daughter tachyzoites' => "tachyzoite",
    'immature oocyst from day 6 onwards' => "oocyst",
    'immature oocyst' => "oocyst",
    'inner membrane complex formation before arrival of IMC1' => "tachyzoite",
    'intracellular bradyzoite' => "bradyzoite",
    'intracellular meront' => "meront",
    'intracellular merozoite' => "merozoite",
    'intracellular sporozoite' => "sporozoite",
    'intracellular stages' => "unspecified",
    'intracellular tachyzoite after 0.5-4 hours' => "tachyzoite",
    'intracellular tachyzoite' => "tachyzoite",
    'intracellular tachyzoite until 0.5-4 hours' => "tachyzoite",
    'intraerythrocytic' => "unspecified",
    'invasion' => "merozoite",
    'invading merozoite' => 'merozoite',
    'newly invaded merozoite' => 'merozoite',
    'late blood stages' => 'schizont',
    'late gametocyte' => "gametocyte",
    'late hepatic' => "liver stage",
    'late hepatic schizont' => "liver stage",
    'late hepatocyte' => "liver stage",
    'late intracellular tachyzoite' => "tachyzoite",
    'late intraerythrocytic' => "ring",
    'late macrogamete' => "gamete",
    'late multinucleate tachyzoite' => "tachyzoite",
    'late oocyst' => "oocyst",
    'late ring' => "ring",
    'late schizont' => "schizont",
    'late tachyzoite cell division' => 'tachyzoite',
    'late trophozoite or early schizont' => "trophozoite",
    'late trophozoite or schizont' => "trophozoite",
    'late trophozoite' => "trophozoite",
    'liver trophozoite' => 'liver stage',
    'liver schizont' => 'liver stage',
    'macrogamete' => "gamete",
    'macrogametocyte' => "gametocyte",
    'macroschizont' => "schizont",
    'male gametocyte' => "gametocyte",
    'male gametocyte stage I' => "gametocyte",
    'male gametocyte stage II' => "gametocyte",
    'male gametocyte stage III' => "gametocyte",
    'male gametocyte stage IV' => "gametocyte",
    'male gametocyte stage V' => "gametocyte",
    'mature bradyzoite' => "bradyzoite",
    'mature first generation schizont' => "schizont",
    'mature gametocyte' => "gametocyte",
    'mature macrogamete' => "gamete",
    'mature microgamete' => "gamete",
    'mature microgametogeny' => "gametocyte",
    'mature oocyst' => "oocyst",
    'mature ookinete' => "ookinete",
    'mature schizont merozoite' => "schizont",
    'mature schizont' => "schizont",
    'mature second generation schizont' => "schizont",
    'mature sporoblast' => "oocyst",
    'mature type i meront' => "meront",
    'maturing parasites' => "unspecified",
    'merogeny' => 'schizont',
    'meront' => "meront",
    'merozoite containing meront' => "meront",
    'merozoite invasion' => "merozoite",
    'merozoite' => "merozoite",
    'merozome' => "liver stage",
    'microgamete' => "gamete",
    'microgamete mitosis' => "gamete",
    'microgametocyte' => "gametocyte",
    'microgametocytogeny' => "gametocyte",
    'microgametogeny' => "gametocyte",
    'middle schizont' => "schizont",
    'midgut oocyst' => "oocyst",
    'midgut sporozoite' => "sporozoite",
    'mid hepatic' => "liver stage",
    'mid stage schizont' => "schizont",
    'mosquito stages' => "unspecified",
    'mother tachyzoite mitotic division' => "tachyzoite",
    'mother tachyzoite' => "tachyzoite",
    'multinucleate mid-stage schizont' => "schizont",
    'multiple infected erythrocyte ring' => "ring",
    'non-activated gametocyte'  => "gametocyte", #a unemerged gametocyte
    'non-dividing tachyzoite' => "tachyzoite",
    'oocyst maturation' => "oocyst",
    'oocyst' => "oocyst",
    'oocyst protrusion' => "oocyst",
    'oocyst sporozoite' => "sporozoite",
    'ookinete 20 hours after fertilization' => "ookinete",
    'ookinete 24 hours after fertilization' => "ookinete",
    'ookinete 11 days after infection' => "ookinete",
    'ookinete 21 days after infection' => "ookinete",
    'ookinete' => "ookinete",
    'ookinete protrusion' => "ookinete",
    'ookinete retort' => "ookinete",
    'proliferative microgametocyte' => "gametocyte",
    'retort' => "ookinete",
    'ring intracellular merozoite' => "ring",
    'ring' => "ring",
    'ring stage of trophozoite' => "ring",
    'rupturing schizont' => "schizont",
    'salivary gland sporozoite' => "sporozoite",
    'schizont' => "schizont",
    'second generation merozoite' => "merozoite",
    'segmenter' => "schizont",
    'segmenting schizonts' => "schizont",
    'several hours post invasion' => "ring",
    'shortly after invasion of tachyzoite' => "tachyzoite",
    'sporoblast' => "oocyst",
    'sporozoite 12 hours post inoculation' => "sporozoite",
    'sporozoite 18 hours post inoculation' => "sporozoite",
    'sporozoite 2 hours post inoculation' => "sporozoite",
    'sporozoite 6 hours post inoculation' => "sporozoite",
    'sporozoite 21 days after infection' => "sporozoite",
    'sporozoites in the presence of host hepatocytes' => "sporozoite",
    'sporozoite invasion' => "sporozoite",
    'sporozoite parasitophorous vacuole 1' => "sporozoite",
    'sporozoite' => "sporozoite",
    'sporozoites ruptured into midgut epithelial cells' => "sporozoite",
    'sporozoites ruptured into the midgut lumen' => "sporozoite",
    'sporulating oocyst' => "oocyst",
    'tachyzoite 24 hours after invasion' => "tachyzoite",
    'tachyzoite attachment' => "tachyzoite", #during invasion => "tachyzoite",
    'tachyzoite cell division' => "tachyzoite",
    'tachyzoite daughter cell inner membrane complex formation' => "tachyzoite",
    'tachyzoite g1 phase' => "tachyzoite",
    'tachyzoite gliding motility' => "tachyzoite",
    'tachyzoite invasion' => "tachyzoite",
    'tachyzoite mitosis' => "tachyzoite",
    'tachyzoites undergoing intracellular replication' => 'tachyzoite',
    'tachyzoite schizont' => "tachyzoite",
    'tachyzoite s-phase' => "tachyzoite",
    'tachyzoite' => "tachyzoite",
    'terminal hepatic' => "liver stage",
    'trophozoite' => "trophozoite",
    'type i merozoite' => "merozoite",
    'unexcysted sporozoite' => "sporozoite",
    'zygote' => "zygote",
  }
  
  def upload_apiloc_top_level_developmental_stages
    # positive
    APILOC_DEVELOPMENTAL_STAGE_TOP_LEVEL_DEVELOPMENTAL_STAGES.each do |low, high|
      top = TopLevelDevelopmentalStage.find_or_create_by_name(high.downcase)
      bottoms = DevelopmentalStage.find_all_by_name(low.downcase)
      if bottoms.length == 0
        $stderr.puts "Unable to find low level developmental stage '#{low}' - remove it from the top_level hash?"
        next
      end
      
      bottoms.each do |b|
        DevelopmentalStageTopLevelDevelopmentalStage.find_or_create_by_developmental_stage_id_and_top_level_developmental_stage_id(
                                                                                                                                   b.id, top.id
        ).save!
      end
    end
    #negative, not quite DRY but meh
    APILOC_DEVELOPMENTAL_STAGE_TOP_LEVEL_DEVELOPMENTAL_STAGES.each do |l, h|
      high = DevelopmentalStage.add_negation(h)
      low = DevelopmentalStage.add_negation(l)
      top = TopLevelDevelopmentalStage.find_or_create_by_name(high.downcase)
      bottoms = DevelopmentalStage.find_all_by_name(low.downcase)
      if bottoms.length == 0
        $stderr.puts "Unable to find low level developmental stage '#{low}' - remove it from the top_level hash?"
        next
      end
      
      bottoms.each do |b|
        DevelopmentalStageTopLevelDevelopmentalStage.find_or_create_by_developmental_stage_id_and_top_level_developmental_stage_id(
                                                                                                                                   b.id, top.id
        ).save!
      end
    end
    check_for_unclassified
  end
  
  # Check to make sure each developmental stage is assigned a top level
  # developmental stage
  def check_for_unclassified
    DevelopmentalStage.all.each do |dev|
      if dev.top_level_developmental_stage.nil?
        $stderr.puts "Couldn't find '#{dev.name}' from #{dev.species.name}, #{dev.id} classified in the top level: #{dev.top_level_developmental_stage.inspect}"
      end
    end
  end
end
