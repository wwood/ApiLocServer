# To change this template, choose Tools | Templates
# and open the template in the editor.

module DevelopmentalStageConstants
  KNOWN_DEVELOPMENTAL_STAGES = {
    Species::FALCIPARUM_NAME => [
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
      'mature sporoblast',
      'ookinete retort',
      'midgut oocyst',
      'mature ookinete',
      'zygote',
      'sporozoite invasion',
      'after sporozoite invasion',
      'developing oocyst',
      'immature oocyst from day 6 onwards',
      'several hours post invasion',
      'multiple infected erythrocyte ring',
      'double infected erythrocyte trophozoites',
      '12 hours after merozoite invasion',
      '18-36 hours after merozoite invasion',
      '24 hours after merozoite invasion',
      '30 hours after merozoite invasion',
      '40 hours after merozoite invasion',
      '48 hours after merozoite invasion',
      '11-16 days after mosquito infective blood meal',
      '60 hours after sporozoite invasion',
    ],
    Species::TOXOPLASMA_GONDII_NAME => [
      'sporozoite',
      'sporozoite invasion',
      'sporozoite 2 hours post inoculation',
      'sporozoite 6 hours post inoculation',
      'sporozoite 12 hours post inoculation',
      'sporozoite 18 hours post inoculation',
      'sporozoite parasitophorous vacuole 1',
      'merozoite',
      'mature bradyzoite',
      'bradyzoite',
      'day 4 bradyzoite',
      'intracellular bradyzoite',
      'enteric',
      'tachyzoite',
      'non-dividing tachyzoite',
      'intracellular tachyzoite until 0.5-4 hours',
      'intracellular tachyzoite after 0.5-4 hours',
      '24 hours after tachyzoite infection',
      '20 hours after tachyzoite infection',
      '16 hours after tachyzoite infection',
      'tachyzoite 24 hours after invasion',
      'extracellular tachyzoite',
      'intracellular tachyzoite',
      'early intracellular tachyzoite',
      'late intracellular tachyzoite',
      'tachyzoite schizont',
      'early multinucleate tachyzoite',
      'late multinucleate tachyzoite',
      'immature daughter tachyzoites',
      'after assembly of tachyzoite daughter cells',
      'early multinucleate tachyzoite',
      'late multinucleate tachyzoite',
      'after tachyzoite division',
      'inner membrane complex formation before arrival of IMC1',
      'tachyzoite daughter cell inner membrane complex formation',
      'tachyzoite gliding motility',
      'tachyzoite invasion',
      'after tachyzoite invasion',
      'early tachyzoite invasion',
      'tachyzoite attachment', #during invasion
      'shortly after invasion of tachyzoite',
      'mother tachyzoite',
      'mother tachyzoite mitotic division',
      'daughter tachyzoite',
      'daughter tachyzoites before acquisition of plasma membrane',
      'first division of bradyzoite',
      'macrogamete',
      'microgamete',
      'microgametocytogeny',
      'macrogametocyte',
      'proliferative microgametocyte',
      'extracellular microgamete',
      'mature microgametogeny',
      'flagellate growth',
      'tachyzoite g1 phase',
      'early tachyzoite g1 phase',
      'tachyzoite mitosis',
      'tachyzoite s-phase',
      'tachyzoite cell division',
      'mature schizont merozoite',
      'early merozoite',
      'extracellular merozoite',
      'schizont',
      'early- to mid- stage schizont',
      'multinucleate mid-stage schizont',
      'trophozoite',
    ],
    Species::BABESIA_BOVIS_NAME => [
      'merozoite',
      'merozoite invasion',
      'intracellular merozoite',
      'sporozoite'
    ],
    Species::NEOSPORA_CANINUM_NAME => [
      'tachyzoite',
      'bradyzoite'
    ],
    Species::OTHER_SPECIES => { #for unsequenced species most likely
      'Plasmodium gallinaceum' => [
        'early ring',
        'trophozoite',
        'schizont',
        'ookinete',
        'mature ookinete',
        'oocyst sporozoite',
        'salivary gland sporozoite',
      ],
      'Plasmodium malariae' => [
        'oocyst maturation',
        'sporoblast',
        'sporozoites ruptured into the midgut lumen',
        'sporozoites ruptured into midgut epithelial cells',
      ],
      'Sarcocystis neurona' => [
        'merozoite'
      ],
      'Sarcocystis muris' => [
      ],
      'Babesia divergens' => [
        'merozoite'
      ],
      'Babesia equi' => [
        'merozoite',
        'intracellular merozoite',
      ],
      'Babesia gibsoni' => [
        'oocyte',
        'intracellular merozoite',
        'early single intracellular merozoite',
        'ring intracellular merozoite',
        'extracellular merozoite',
        'merozoite',
        'ring stage of trophozoite'
      ],
      'Babesia bigemina' => [
        'merozoite'
      ],
      'Theileria lestoquardi' => [
        'macroschizont',
      ],
      'Eimeria ascervulina' => [
        'daughter cell formation',
        'macrogamete',
        'proliferative microgametocyte',
        'flagellate growth',
        'microgametogeny',
        'mature microgametogeny',
        'free microgamete',
      ],
      'Eimeria maxima' => [
        'merozoite',
        'macrogamete',
        'proliferative microgametocyte',
        'flagellate growth',
        'microgametogeny',
        'mature microgametogeny',
        'free microgamete',
      ],
      'Eimeria tenella' => [
        'sporozoite',
        'extracellular sporozoite',
        'intracellular sporozoite',
        'host cell exposed extracellular sporozoite',
        'sporozoite invasion',
        'after sporozoite invasion',
        'schizont',
        'early first generation schizont',
        'mature first generation schizont',
        'early second generation schizont',
        'mature second generation schizont',
        'developing schizont',
        'mid stage schizont',
        'enlarging schizont',
        'mature schizont',
        'daughter cell formation',
        'merozoite',
        'early merozoite',
        'first generation merozoite',
        'second generation merozoite',
        'proliferative microgametocyte',
        'flagellate growth',
        'microgametogeny',
        'mature microgametogeny',
        'free microgamete',
        'gametocyte',
        'microgamete',
        'early microgamete',
        'mature microgamete',
        'macrogamete',
        'mature macrogamete',
        'oocyst'
      ]
    },
    Species::CRYPTOSPORIDIUM_PARVUM_NAME => [
      'sporozoite',
      'extracellular sporozoite',
      'unexcysted sporozoite',
      'freshly excysted sporozoite',
      'sporozoite invasion',
      'oocyst',
      'immature oocyst',
      'empty oocyst',
      'fully sporulated oocyst',
      'intracellular meront',
      'intracellular stages',
      'merozoite containing meront',
      'meront',
      'mature type i meront',
      'merozoite',
      'type i merozoite',
      'early macrogametocyte',
      'early macrogamete',
      'late macrogamete',
      'trophozoite',
    ],
    Species::THEILERIA_ANNULATA_NAME => [
      'macroschizont',
      'schizont'
    ],
    Species::THEILERIA_PARVA_NAME => [
    ],
    Species::PLASMODIUM_BERGHEI_NAME => [
      'blood stages',
      'ring',
      'trophozoite',
      'schizont',
      'early schizont',
      'late schizont',
      'cytomere',
      'merozoite',
      'gametocyte',
      'macrogametocyte',
      'microgametocyte',
      'activated microgametocyte',
      'macrogamete',
      'microgamete',
      'microgamete mitosis',
      'zygote',
      'retort',
      'ookinete protrusion',
      'ookinete',
      'ookinete 20 hours after fertilization',
      'mature ookinete',
      'oocyst protrusion',
      'oocyst',
      'early oocyst',
      'midgut oocyst',
      'sporulating oocyst',
      'extracellular sporozoite',
      'sporozoite',
      'oocyst sporozoite',
      'midgut sporozoite',
      'hemolymph sporozoite',
      'salivary gland sporozoite',
      'after sporozoite invasion',
      '2 hours after sporozoite invasion',
      '8 hours after sporozoite invasion',
      'hepatic',
      'early hepatic',
      'hepatocyte merozoite',
    ],
    Species::VIVAX_NAME => [
      'ring',
      'trophozoite',
      'schizont',
      'mature schizont',
      'merozoite',
      'extracellular merozoite',
      'zygote',
      'ookinete'
    ],
    Species::YOELII_NAME => [
      'ring',
      'trophozoite',
      'early trophozoite',
      'schizont',
      'early schizont',
      'late schizont',
      'merozoite',
      'sporozoite',
      'ookinete',
      '7 day old oocyst',
      'oocyst sporozoite',
      'hemolymph sporozoite',
      'salivary gland sporozoite',
      'hepatic',
    ],
    Species::KNOWLESI_NAME => [
      'merozoite',
      'blood stages',
      'sporozoite',
    ],
    Species::CHABAUDI_NAME => [
      'blood stages',
      'intraerythrocytic',
      'maturing parasites',
      'merozoite',
    ],
  }

  KNOWN_DEVELOPMENTAL_STAGE_SYNONYMS = {
    Species::CHABAUDI_NAME => {},
    Species::KNOWLESI_NAME => {},
    Species::YOELII_NAME => {
      'immature schizont' => 'early schizont',
      'mature schizont' => 'late schizont',
      'liver stages' => 'hepatic'
    },
    Species::VIVAX_NAME => {
      'rbc stages' => %w(ring trophozoite schizont).push('extracellular merozoite'),
      'all rbc stages' => %w(ring trophozoite schizont).push('extracellular merozoite'),
    },
    Species::PLASMODIUM_BERGHEI_NAME => {
      'erythrocytic' => 'blood stages',
      'hepatocyte' => 'hepatic',
      'mature schizont' => 'late schizont',
      '8h after sporozoite invasion' => '8 hours after sporozoite invasion',
      '2h post sporozoite invasion' => '2 hours after sporozoite invasion',
      'early hepatocyte' => 'early hepatic',
      'developing oocyst' => 'early oocyst',
      'young oocyst' => 'early oocyst',
      'salivary gland sporozoites' => 'salivary gland sporozoite',
      'macrogametes' => 'macrogamete',
      'erythrocytic stages' => 'blood stages',
      'troph' => 'trophozoite',
      'ookinete 20h after fertilization' => 'ookinete 20 hours after fertilization',
      'female gametocyte' => 'macrogametocyte',
      'female gamete' => 'macrogamete',
      'male gametocyte' => 'microgametocyte',
      'male gamete' => 'microgamete',
      'early hepatic stages' => 'early hepatic',
      'trophs' => 'trophozoite',
      'oocyst derived sporozoite' => 'oocyst sporozoite',
    },
    Species::THEILERIA_ANNULATA_NAME => {},
    Species::THEILERIA_PARVA_NAME => {},
    Species::CRYPTOSPORIDIUM_PARVUM_NAME => {
      'free sporozoite' => 'extracellular sporozoite',
      'sporozoite internalization' => 'sporozoite invasion',
    },
    Species::OTHER_SPECIES => {
      'Plasmodium gallinaceum' => {
        'troph' => 'trophozoite'
      },
      'Babesia gibsoni' => {
        'ring stage of trophozoites' => 'ring stage of trophozoite',
        'ring stage intracellular merozoite' => 'ring intracellular merozoite'
      },
      'Sarcocystis neurona' => {
        'merozoites' => 'merozoite'
      },
      'Eimeria tenella' => {
        'isolated extracellular sporozoite' => 'extracellular sporozoite',
        'host-cell exposed extracellular sporozoite' => 'host cell exposed extracellular sporozoite',
        'sporozoites' => 'sporozoite',
      }
    },
    Species::NEOSPORA_CANINUM_NAME => {},
    Species::BABESIA_BOVIS_NAME => {
      'invading merozoites' => 'merozoite invasion'
    },
    Species::TOXOPLASMA_GONDII_NAME => {
      '16h after tachyzoite infection' => '16 hours after tachyzoite infection',
      '20h after tachyzoite infection' => '20 hours after tachyzoite infection',
      'tachyzoite host cell entry' => 'tachyzoite invasion',
      'tachyzoite gliding' => 'tachyzoite gliding motility',
      'tachyzoite 24h after invasion' => 'tachyzoite 24 hours after invasion',
      'intracellular tachyzoite after invasion' => 'after tachyzoite invasion',
      '16h post infection intracellular tachyzoite' => '16 hours after tachyzoite infection',
      'tachyzoite daughter imc formation' => 'tachyzoite daughter cell inner membrane complex formation',
      'imc formation before arrival of imc1' => 'inner membrane complex formation before arrival of IMC1',
      'daughter IMC formation' => 'tachyzoite daughter cell inner membrane complex formation',
      'early stages of tachyzoite invasion' => 'early tachyzoite invasion',
      'daughter cell formation' => 'tachyzoite cell division',
      'microgametogeny' => 'microgametocytogeny',
      'mature merozoite schizont' => 'mature schizont merozoite',
      'enteric stages' => 'enteric',
      'after tachyzoite cell division' => 'after assembly of tachyzoite daughter cells',
      'mature intracellular tachyzoite' => 'late intracellular tachyzoite',
      'invading tachyzoite' => 'tachyzoite invasion',
      'free microgamete' => 'extracellular microgamete',
      'intracellular tachyzoites' => 'intracellular tachyzoite',
      'tachyzoites' => 'tachyzoite',
      'invaded tachyzoite' => 'intracellular tachyzoite',
      'free tachyzoite' => 'extracellular tachyzoite',
      'released mature tachyzoite' => 'extracellular tachyzoite',
      'shortly after tachyzoite invasion' => 'shortly after invasion of tachyzoite',
    },
    Species::FALCIPARUM_NAME => {
      'immature oocyst' => 'early oocyst',
      'late troph' => 'late trophozoite',
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
      '11-16 days post infective blood meal' => '11-16 days after mosquito infective blood meal',
    }
  }
end
