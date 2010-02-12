# To change this template, choose Tools | Templates
# and open the template in the editor.

module LocalisationConstants
  KNOWN_LOCALISATIONS = {
    Species::FALCIPARUM_NAME => [
      'cell poles', #antierior + posterior
      'posterior',
      'periphery',
      'knob', #start of ring, troph, schizont stage locs
      'erythrocyte cytoplasm',
      'erythrocyte cytosol',
      'maurer\'s cleft',
      'tubulovesicular membrane',
      'erythrocyte plasma membrane',
      'exposed erythrocyte plasma membrane',
      'erythrocyte periphery',
      'erythrocyte cytoplasmic structure',
      'erythrocyte cytoplasmic structure near parasitophorous vacuole',
      'erythrocyte',
      'single small vesicle in erythrocyte',
      'exported',
      'cytoplasmic side of erythrocyte membrane',
      'beyond erythrocyte membrane',
      'membrane of lysed erythrocyte',
      'cleft like parasitophorous vacuole membrane protrusion',
      'punctate parasitophorous vacuole',
      'parasitophorous vacuole',
      'parasitophorous vacuole subdomains',
      'parasitophorous vacuole membrane',
      'parasite plasma membrane',
      'apicoplast membrane',
      'proximal to plasma membrane',
      'apical plasma membrane',
      'under parasite plasma membrane',
      'microtubule',
      'replication foci in nucleus',
      'area near nucleus', # nucleus + surrounds
      'anterior to nucleus',
      'mitotic spindle in nucleus',
      'food vacuole',
      'food vacuole membrane',
      'food vacuole lumen',
      'parasitophorous vacuole close to food vacuole',
      'cytostome',
      'mitochondrion',
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
      'nuclear matrix',
      'trans golgi',
      'golgi apparatus',
      'golgi matrix',
      'cis-golgi',
      'endoplasmic reticulum',
      'endoplasmic reticulum associated vesicle',
      'vesicle',
      'intracellular vacuole',
      'intracellular vacuole membrane',
      'intracellular inclusion',
      'vesicle near parasite surface',
      'peripheral',
      'merozoite associated material',
      'apical end of surface',
      'merozoite surface', #should be separate (but overlapping with) surface, because of the differentiation in asexual reproduction.
      'moving junction',
      'inner membrane complex',
      'pellicle',
      'pellicle membrane',
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
      'gametocyte attached erythrocytic vesicle',
      'sporozoite surface', #sporozoite locs
      'nowhere except sporozoite surface', #sporozoite locs
      'oocyst wall',
      'zygote remnant', # the zygote part when the ookinete is budding off from the zygote
      'ookinete protrusion', # the opposite of zygote remnant
      'oocyst protrusion', # during ookinete to oocyst transition, oocyst starts out as a round protrusion
      'peripheral of oocyst protrusion', # possibly an analogue of IMC?
      'trail', # the trail that sporozoites/merozoites/etc. leave behind when they move
      'nowhere except sporozoite plasma membrane',
      'cytoplasmic vesicle',
      'erythrocyte cytoplasmic vesicle',
      'intraerythrocytic cysternae',
      'vesicle under erythrocyte surface',
      'area around nucleus', # not a very specific localisation compared to 'nuclear envelope' or 'ER'
      'nuclear envelope',
      'perinuclear',
      'far nuclear periphery',
      'interior of nucleus',
      'internal organelle',
      'intracellular',
      'cytoplasmic structure',
      'spread around parasite',
      'throughout parasite',
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
      'osmiophilic body' #"Pfmdv-1 was also detected in specific secretory vesicles, termed osmiophilic bodies (OB), within gametocytes (Fig. 3 A, B, and D)."
    ],
    Species::TOXOPLASMA_GONDII_NAME => [
      'nascent rhoptry',
      'rhoptry',
      'limiting membrane of rhoptry',
      'luminal membrane of rhoptry',
      'rhoptry neck',
      'rhoptry body',
      'microneme',
      'secretory organelle',
      'nowhere except microneme',
      'dense granule',
      'microdomains of dense granule membrane',
      'apicoplast',
      'reticular staining outside apicoplast',
      'apicoplast periphery',
      'innermost apicoplast membrane',
      'apicoplast membrane',
      'apicoplast intermembrane space',
      'apicoplast lumen',
      'mitochondrion',
      'anterior adjacent to mitochondrion',
      'adjacent to mitochondrion',
      'cytosol',
      'two unknown vesicular bodies',
      'nucleus',
      'nucleolus',
      'nuclear envelope',
      'posterior to nucleus',
      'nowhere except nucleus',
      'replication foci',
      'apical',
      'sub-apical',
      'apical annuli',
      'nowhere except apical',
      'posterior',
      'ring at basal end',
      'parasite plasma membrane',
      'cytoplasm',
      'ring structure at apical inner membrane complex',
      'ring structure at posterior inner membrane complex',
      'endoplasmic reticulum',
      'apical end of endoplasmic reticulum',
      'cortical endoplasmic reticulum',
      'perinuclear endoplasmic reticulum',
      'between endoplasmic reticulum and golgi',
      'golgi apparatus',
      'cytoplasmic region close to the golgi',
      'cisternal rims of the late golgi',
      'post golgi compartment',
      'golgi associated transport vesicle',
      'invasion furrow',
      'moving junction',
      'cytoplasmic face of the host plasma membrane at moving junction',
      'inner membrane complex',
      'adjacent to the inner membrane complex',
      'cytoplasmic face of inner membrane complex',
      'nowhere except cytoplasmic face of inner membrane complex',
      'inner membrane complex microtubules',
      'centrocone',
      'apical end of the nuclear envelope',
      'parasitophorous vacuole membrane',
      'parasitophorous vacuole',
      'periphery of parasitophorous vacuole',
      'sporozoite parasitophorous vacuole 1',
      'membranous parasitophorous vacuole tubules',
      'peroxisome',
      'trans-golgi network', #according to Cheryl, the trans should be in italics. meh.
      'wall forming body',
      'evacuole',
      'intravacuolar network',
      'cytoskeleton',
      'vesicle',
      'endosome-related compartment',
      'early endosome',
      'peripheral',
      'endosomal membrane',
      'endosomal vacuole',
      'transport vesicle',
      'cytoplasmic vesicle',
      'cytoplasmic structure',
      'cytoplasmic foci',
      'anterior vesicle',
      'posterior vesicle',
      'vesicle budding off zoite posterior',
      'multi-vesicular endosome',
      'vacuole',
      'lysosome',
      'intracellular',
      'host cell plasma membrane',
      'host cell nucleus',
      'conoid',
      'conoid fiber ends',
      'host cell',
      'cytosolic side of host cell membrane',
      'multi-lamellar vesicle',
      'periphery of parasite',
      'beneath alveoli',
      'centriole',
      'centrosome',
      'microtubule',
      'subpellicular microtubule',
      'attachment site of subpellicular microtubule',
      'mother inner membrane complex',
      'daughter inner membrane complex',
      'spindle pole',
      'cap at basal end of mother',
      'cap at basal end of daughter',
      'basal',
      'acidocalcisome',
      'cyst wall',
      'outer membrane of cyst wall',
      'cytoplasmic structure',
      'nuclear pole',
      'flagellate basal body',
      'electron dense collar',
      'residual body',
      'distal end of parasitophorous vacuole',
      'cone shaped body of basal complex',
      'acrosome',
      'tubular structure in parasitophorous vacuole',
      'posterior extremity of cup-shaped inner membrane cytoskeleton scaffolds',
      'cyst matrix',
      'developing cyst wall',
      'nascent conoid',
      'vesicle-like structure just under the parasite membrane',
      'apical conoid',
    ],
    Species::BABESIA_BOVIS_NAME => [
      'apical',
      'released into extracellular mileiu',
      'cytoplasm',
      'spherical body organelle',
      'host erythrocyte membrane',
      'plasma membrane', #ie. surface of parasite
      'cytoplasmic accumulation',
      'parasitophorous vacuole membrane',
      'nucleus',
      'cytoplasmic face of host erythrocyte membrane'
    ],
    Species::NEOSPORA_CANINUM_NAME => [
      'apical',
      'microneme',
      'dense granule',
      'rhoptry',
      'rhoptry neck',
      'parasitophorous vacuole',
      'area around nucleus',
      'cell surface',
      'cytoplasm',
      'posterior cytoplasm',
      'anterior cytoplasm',
      'cyst wall',
      'moving junction'
    ],
    Species::OTHER_SPECIES => { #for unsequenced species most likely
      'Plasmodium gallinaceum' => [
        'microneme',
        'microneme membrane',
        'microneme lumen',
        'sub-pellicular region at the anterior',
        'ookinete apical surface',
        'nucleus',
        'surface',
        'apical',
        'conoid collar',
        'extracellular',

      ],
      'Plasmodium cynomolgi' => [
        'merozoite surface'
      ],
      "Plasmodium malariae" => [
        'inner surface of peripheral vacuoles',
        'surface',
        'plasma membrane',
      ],
      'Sarcocystis muris' => [
        'cell surface',
        'pellicle',
        'microneme'
      ],
      'Sarcocystis neurona' => [
        'apical',
        'microneme',
      ],
      'Babesia divergens' => [
        'cytosolic face of plasma membrane'
      ],
      'Babesia gibsoni' => [
        'cell surface',
        'plasma membrane',
        'cytoplasm',
        'host cell cytoplasm',
        'apical',
      ],
      'Babesia equi' => [
        'cell surface',
        'host cell cytoplasm'
      ],
      'Babesia bigemina' => [
        'cytoplasm'
      ],
      'Theileria lestoquardi' => [
        'plasma membrane'
      ],
      'Eimeria ascervulina' => [
        'inner membrane complex',
        'nuclear pole',
        'flagellar basal bodies',
        'electron dense collar',
        'adjacent to mitochondrion',
        'anterior adjacent to mitochondria',
        
      ],
      'Eimeria maxima' => [
        'microneme',
        'nuclear pole',
        'flagellar basal bodies',
        'electron dense collar',
        'adjacent to mitochondrion',
        'anterior adjacent to mitochondria',
      ],
      'Eimeria tenella' => [
        'apical',
        'microneme',
        'surface',
        'cytoplasm',
        'peripheral',
        'sporozoite surface',
        'apicoplast',
        'wall forming body type ii',
        'cytosol',
        'parasitophorous vacuole',
        'parasitophorous vacuole membrane',
        'merozoite cytosol',
        'host cell surface',
        'nucleus',
        'free end of inner membrane complex',
        'nuclear pole',
        'flagellar basal bodies',
        'electron dense collar',
        'adjacent to mitochondrion',
        'anterior adjacent to mitochondria',
        'intracellular',
        'host tissue',
      ]
    },
    Species::CRYPTOSPORIDIUM_PARVUM_NAME => [
      'surface',
      'cytosol',
      'cytoplasm',
      'perinuclear',
      'nucleus',
      'anterior to nucleus',
      'apical',
      'apical surface',
      'microneme',
      'mitochondrion',
      'dense band',
      'posterior vacuole',
      'intracellular',
      'feeder organelle',
      'parasitophorous vacuole',
      'oocyst wall',
      'wall forming body',
      'cytoplasmic inclusion',
      'periphery of amylopectin-like granules',
      'cytoplasm proximal to amylopectin-like granules',
      'peripheral',
      'between pellicle and parasitophorous vacuole membrane',
      'parasitophorous vacuole membrane',
      'plasma membrane',
      'crystalloid body',
      'residual body',
      'anterior vacuole',
      'surrounding',
    ],
    Species::THEILERIA_ANNULATA_NAME => [
      'mitochondrion',
      'cytosol',
      'cytoplasm',
      'host cell',
      'host cell cytosol',
      'host cell cytoplasm',
      'host cell nucleus',
      'plasma membrane',
      'nucleus'
    ],
    Species::THEILERIA_PARVA_NAME => [
      'apical'
    ],
    Species::PLASMODIUM_BERGHEI_NAME => [
      'apical',
      'microneme',
      'peripheral of microneme',
      'rhoptry',
      'high electron dense microneme',
      'peripheral',
      'extracellular apical pole of ookinete protrusion',
      'osmiophilic body',
      'gliding trail',
      'cytoplasm',
      'surface',
      'parasitophorous vacuole',
      'close to parasitophorous vacuole membrane',
      'zygote side',
      'oocyst protrusion',
      'oocyst capsule',
      'individual merozoites inside merozomes',
      'anterior to nucleus',
      'nucleus',
      'outer nuclear envelope',
      'nuclear membrane',
      'perinuclear',
      'inner membrane complex',
      'sporozoite surface',
      'ookinete surface',
      'vesicles near parasite surface',
      'plasma membrane',
      'food vacuole',
      'parasitophorous vacuole membrane',
      'only parasitophorous vacuole membrane',
      'pellicle',
      'ookinete protrusion',
      'peripheral of oocyst protrusion',
      'maurer\'s cleft',
      'intracellular',
      'host cell cytoplasm',
      'host cell nucleus',
      'microtubule',
      'endoplasmic reticulum',
      'transformation bulb',
      'crystalloid',
      'internal structures',
    ],
    Species::VIVAX_NAME => [
      'surface',
      'ookinete surface',
      'intracellular',
      'apical',
      'microneme',
      'rhoptry',
      'cytoplasm',
      'cytosol',
      'host cell cytoplasm',
      'nucleus',
      'food vacuole',
    ],
    Species::YOELII_NAME => [
      'apical',
      'microneme',
      'rhoptry',
      'basal',
      'plasma membrane',
      'underneath plasma membrane',
      'merozoite surface',
      'nucleus',
      'surface',
      'parasitophorous vacuole',
      'parasitophorous vacuole membrane',
      'inner membrane complex',
      'host cell membrane',
      'host cell cytoplasm',
      'endoplasmic reticulum',
      'cytoplasmic matrix',
      'subcapsular areas',
      'intracellular',
      'cytoplasm',
      'plasma membrane',
      'nowhere except apicoplast',
    ],
    Species::KNOWLESI_NAME => [
      'microneme',
      'apical',
      'surface'
    ],
    Species::CHABAUDI_NAME => [
      'cytoplasm',
      'nucleus',
      'maurer\'s cleft',
      'parasitophorous vacuole membrane',
      'parasitophorous vacuole',
      'dense granule',
      'cytoplasmic side of host cell membrane',
    ],
  }

  KNOWN_LOCALISATION_SYNONYMS = {
    Species::CHABAUDI_NAME => {
      'pv' => 'parasitophorous vacuole',
      'pvm' => 'parasitophorous vacuole membrane',
      'nuclear' => 'nucleus',
      'dense granules' => 'dense granule',
      'cytoplasmic side of host erythrocyte membrane' =>
        'cytoplasmic side of host cell membrane'
    },
    Species::KNOWLESI_NAME => {},
    Species::YOELII_NAME => {
      'membrane of infected erythrocytes' => 'host cell membrane',
      'cytoplasm of erythrocyte' => 'host cell cytoplasm',
      'trophozoite' => 'intracellular',
      'trophozoite membrane' => 'plasma membrane',
      'merozoite membrane' => 'merozoite surface',
      'er' => 'endoplasmic reticulum',
      'erythrocyte membrane' => 'host cell membrane',
      'pvm' => 'parasitophorous vacuole membrane',
      'pv' => 'parasitophorous vacuole',
      'imc' => 'inner membrane complex',
      'nuclei' => 'nucleus',
      'plasma membranes' => 'plasma membrane',
      'rhoptries' => 'rhoptry'
    },
    Species::VIVAX_NAME => {
      'erythrocyte cytoplasm' => 'host cell cytoplasm',
      'parasite surface' => 'surface',
      'nuclear' => 'nucleus',
      'lysosome' => 'food vacuole',
      'rhoptries' => 'rhoptry',
    },
    Species::PLASMODIUM_BERGHEI_NAME => {
      'lysosome' => 'food vacuole',
      'only pvm' => 'only parasitophorous vacuole membrane',
      'internalized' => 'cytoplasm',
      'sporozoite trail' => 'gliding trail',
      'er' => 'endoplasmic reticulum',
      'parasite surface' => 'surface',
      'peripheral microneme' => 'peripheral of microneme',
      'parasite plasma membrane' => 'plasma membrane',
      'apical tip' => 'apical',
      'peripheral cytoplasm' => 'peripheral',
      'peripheral foci' => 'peripheral',
      'osmiophilic bodies' => 'osmiophilic body',
      'pv' => 'parasitophorous vacuole',
      'close to pvm' => 'close to parasitophorous vacuole membrane',
      'imc' => 'inner membrane complex',
      'pvm' => 'parasitophorous vacuole membrane',
      'pv membrane' => 'parasitophorous vacuole membrane',
      'fv' => 'food vacuole',
      'trail' => 'gliding trail',
    },
    Species::THEILERIA_ANNULATA_NAME => {
      'mitochondria' => 'mitochondrion',
      'parasite cytoplasm' => 'cytoplasm',
      'parasite plasma membrane' => 'plasma membrane',
    },
    Species::THEILERIA_PARVA_NAME => {},
    Species::CRYPTOSPORIDIUM_PARVUM_NAME => {
      'relict mitochondrian' => 'mitochondrion',
      'mitochondrion-like structure' => 'mitochondrion',
      'mitochondria' => 'mitochondrion',
      'pv' => 'parasitophorous vacuole',
      'anterior of surface' => 'apical surface',
      'periphery of parasite subjacent to the parasitophorous vacuole' => 'peripheral',
      'anterior to the nucleus' => 'anterior to nucleus',
      'periphery' => 'peripheral',
      'pvm' => 'parasitophorous vacuole membrane',
      'membrane' => 'plasma membrane',
      'wall forming bodies' => 'wall forming body',
    },
    Species::OTHER_SPECIES => {
      'Sarcocystis muris' => {
        'surface' => 'cell surface'
      },
      'Babesia gibsoni' => {
        'surface' => 'cell surface',
        'erythrocyte cytoplasm' => 'host cell cytoplasm',
        'pm' => 'plasma membrane',
        'membrane' => 'plasma membrane'
      },
      'Babesia equi' => {
        'surface' => 'cell surface'
      },
      'Plasmodium gallinaceum' => {
        'sub-pellicular region at the anterior portion' => 'sub-pellicular region at the anterior',
        'nuclear' => 'nucleus'
      },
      'Eimeria ascervulina' => {
        'imc' => 'inner membrane complex',
      },
      'Eimeria tenella' => {
        'pv' => 'parasitophorous vacuole',
        'pvm' => 'parasitophorous vacuole membrane',
        'cytosol in merozoite' => 'merozoite cytosol',
        'apex' => 'apical',
        'free end of imc' => 'free end of inner membrane complex',
        'wfbii' => 'wall forming body type ii',
        'wall-forming body type ii' => 'wall forming body type ii',
      }
    },
    Species::NEOSPORA_CANINUM_NAME => {
      'cytoplasm mostly near nuclear membrane' => 'area around nucleus',
      'mj' => 'moving junction',
      'surface' => 'cell surface',
      'parasite surface' => 'cell surface',
    },
    Species::BABESIA_BOVIS_NAME => {
      'cytoplasmic accumulations' => 'cytoplasmic accumulation',
      'spherical body organelles' => 'spherical body organelle',
      'surface' => 'plasma membrane',
      'host cell surface' => 'host erythrocyte membrane',
      'inner surface of host cell cytoplasm' => 'parasitophorous vacuole membrane'
    },
    Species::TOXOPLASMA_GONDII_NAME => {
      'golgi' => 'golgi apparatus',
      'cytoplasmic structures' => 'cytoplasmic structure',
      'vesicles' => 'vesicle',
      'cytoplasmic vesicles' => 'cytoplasmic vesicle',
      'anterior adjacent to mitochondria' => 'anterior adjacent to mitochondrion',
      'secretory organelles' => 'secretory organelle',
      'endosome-related compartments' => 'endosome-related compartment',
      'transport vesicles' => 'transport vesicle',
      'micronemes' => 'microneme',
      'acidocalcisomes' => 'acidocalcisome',
      'vesicles budding off zoite posterior' => 'vesicle budding off zoite posterior',
      'anterior vesicles' => 'anterior vesicle',
      'wall forming bodies' => 'wall forming body',
      'between er and golgi' => 'between endoplasmic reticulum and golgi',
      'vesicle-like structures just under the parasite membrane' => 'vesicle-like structure just under the parasite membrane',
      'attachment site of subpellicular microtubules' => 'attachment site of subpellicular microtubule',
      'subpellicular microtubules' => 'subpellicular microtubule',
      'endosomal membranes' => 'endosomal membrane',
      'golgi associated transport vesicles' => 'golgi associated transport vesicle',
      'multi-lamellar vesicles' => 'multi-lamellar vesicle',
      'nascent rhoptries' => 'nascent rhoptry',
      'rhoptries' => 'rhoptry',
      'mitochondria' => 'mitochondrion',
      'rear end of parasite' => 'posterior',
      'limiting membrane of pv' => 'parasitophorous vacuole membrane',
      'nuclear' => 'nucleus',
      'adjacent to mitochondrion' => 'adjacent to mitochondrion',
      'flagellar basal bodies' => 'flagellate basal body',
      'residual bodies' => 'residual body',
      'tubular structures in pv' => 'tubular structure in parasitophorous vacuole',
      'pm' => 'parasite plasma membrane',
      'limiting membrane' => 'parasite plasma membrane',
      'cortical er' => 'cortical endoplasmic reticulum',
      'perinuclear er' => 'perinuclear endoplasmic reticulum',
      'distal end of vacuole' => 'distal end of parasitophorous vacuole',
      'vesicles in apical end' => 'anterior vesicle',
      'vesicles in basal end' => 'posterior vesicle',
      'cell surface' => 'parasite plasma membrane',
      'nowhere except cytoplasmic face of imc' => 'nowhere except cytoplasmic face of inner membrane complex',
      'cytoplasmic face of imc' => 'cytoplasmic face of inner membrane complex',
      'ppm' => 'parasite plasma membrane',
      'spindle poles' => 'spindle pole',
      'intracellular compartment' => 'cytoplasmic structure',
      'microtubules' => 'microtubule',
      'apical end of er' => 'apical end of endoplasmic reticulum',
      'posterior within cytoplasm' => 'posterior',
      'plastid' => 'apicoplast',
      'centrioles' => 'centriole',
      'cytosolic vesicles' => 'cytoplasmic vesicle',
      'plasma membrane' => 'parasite plasma membrane',
      'mother imc' => 'mother inner membrane complex',
      'daughter imc' => 'daughter inner membrane complex',
      'host cell membrane' => 'host cell plasma membrane',
      'imc' => 'inner membrane complex',
      'growing bud of daughter cell' => 'intracellular',
      'tgn' => 'trans-golgi network',
      'cytosolic' => 'cytosol',
      'pellicle' => 'inner membrane complex',
      'mj' => 'moving junction',
      'apical end' => 'apical',
      'moving junction ring' => 'moving junction',
      'surface' => 'parasite plasma membrane',
      'dense granule' => 'dense granule',
      'er' => 'endoplasmic reticulum',
      'membrane' => 'parasite plasma membrane',
      'mitochondrial' => 'mitochondrion',
      'ring structure at apical imc' => 'ring structure at apical inner membrane complex',
      'pvm' => 'parasitophorous vacuole membrane',
      'pv' => 'parasitophorous vacuole',
      'pv membrane' => 'parasitophorous vacuole membrane',
      'periphery of pv' => 'periphery of parasitophorous vacuole',
      'membranous pv tubules' => 'membranous parasitophorous vacuole tubules',
      'ring structure at posterior imc' => 'ring structure at posterior inner membrane complex',
    },
    Species::FALCIPARUM_NAME => {
      'mitochondria' => 'mitochondrion',
      'cis golgi' => 'cis-golgi',
      'discrete dots on ppm' => 'parasite plasma membrane',
      'spotted in the erythrocyte cytoplasm' => 'erythrocyte cytoplasmic structure',
      'granules near pv in erythrocyte cytoplasm' => 'erythrocyte cytoplasmic structure near parasitophorous vacuole',
      'small double membrane-bound small hemoglobin-containing vacuoles' => 'cytostome',
      'intraerythrocytic spots' => 'erythrocyte cytoplasmic structure',
      'released extracellularly' => 'beyond erythrocyte membrane',
      'small structures in parasite' => 'cytoplasmic structure',
      'parasite nucleus' => 'nucleus',
      'dispersed fluorescent patches underneath erythrocyte surface' => 'erythrocyte periphery',
      'membrane bound vesicles' => 'vesicle',
      'tvn' => 'tubulovesicular membrane',
      'fvm' => 'food vacuole membrane',
      'intraparasitic vacuoles' => 'intracellular vacuole',
      'tubulovesicular system' => 'tubulovesicular membrane',
      'er associated vesicles' => 'endoplasmic reticulum associated vesicle',
      'infected erythrocyte' => 'erythrocyte cytoplasm',
      'irbc' => 'erythrocyte cytoplasm',
      'anterior' => 'apical',
      'surrounding intracellular merozoite' => 'surrounding parasite',
      'small vesicles in erythrocyte cytoplasm' => 'single small vesicle in erythrocyte',
      'telomere cluster' => 'telomeric cluster',
      'nucleus surrounding regions' => 'area around nucleus',
      'periphery of cytoplasm' => 'peripheral',
      'circumference' => 'parasite plasma membrane',
      'discrete dots on parasite plasma membrane' => 'parasite plasma membrane',
      'cytoplasm of host infected erythrocyte' => 'erythrocyte cytoplasm',
      'surface membrane' => 'parasite plasma membrane',
      'peripheral cytoplasm' => 'peripheral',
      'golgi' => 'golgi apparatus',
      'vesicles like structures' => 'vesicle',
      'apical surface' => 'apical parasite plasma membrane',
      'rbc cytosol' => 'erythrocyte cytosol',
      'parasite rim' => 'peripheral',
      'telomeric clusters' => 'telomeric cluster',
      'widely distributed in apical' => 'apical',
      'apical foci' => 'apical',
      'parasite cytoplasm' => 'cytoplasm',
      'host cell cytoplasm' => 'erythrocyte cytoplasm',
      'cell' => 'intracellular',
      'pv related structures in erythrocyte cytoplasm' => 'cleft like parasitophorous vacuole membrane protrusion',
      'cytoplasmic face of erthrocyte plasma membrane' => 'cytoplasmic side of erythrocyte membrane',
      'with membrane' => 'parasite plasma membrane',
      'vesicles in infected erythrocyte cytoplasm' => 'erythrocyte cytoplasmic structure',
      'intracellular bright spots' => 'intracellular',
      'almost exclusively cytoplasm' => 'cytoplasm',
      'close to membrane in apicoplast' => 'near apicoplast membranes',
      'perinuclear spots' => 'perinuclear',
      'electron sparse nuclear interior' => 'nuclear interior',
      'apicoplast only' => 'nowhere except apicoplast',
      'parasite' => 'intracellular',
      'in association with the parasite plasmalemma' => 'parasite plasma membrane',
      'parasite membrane' => 'parasite plasma membrane',
      'apical end of surface' => 'apical plasma membrane',
      'outside of erythrocyte membranes' => 'beyond erythrocyte membrane',
      'rim' => 'proximal to plasma membrane',
      'apex' => 'apical',
      'rhoptry body' => 'rhoptry bulb',
      'throughout cell' => 'throughout parasite',
      'crescent shaped cap associated with apical pole' => 'apical',
      'mam' => 'merozoite associated material',
      'single small vesicles' => 'single small vesicle in erythrocyte',
      'exposed rbc surface' => 'exposed erythrocyte plasma membrane',
      'rbc vesicles' => 'erythrocyte cytoplasmic structure',
      'spread around each individual merozoite' => 'spread around parasite',
      'rbc vesicles connected to the gametocyte' => 'gametocyte attached erythrocytic vesicle',
      'cleft like pvm protrusions' => 'cleft like parasitophorous vacuole membrane protrusion',
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
      'vesicles in rbc cytoplasm' => 'erythrocyte cytoplasmic structure',
      'mc' => 'maurer\'s cleft',
      'ppm' => 'parasite plasma membrane',
      'rbc cytoplasmic aggregates' => 'erythrocyte cytoplasmic structure',
      'foci in erythrocyte cytosol' => 'erythrocyte cytoplasmic structure',
      'tight junction' => 'moving junction',
      'beyond rbc membrane' => 'beyond erythrocyte membrane',
      'under pm' => 'under parasite plasma membrane',
      'rhoptry pundicle' => 'rhoptry neck',
      'ER' => 'endoplasmic reticulum',
      'tER' => 'endoplasmic reticulum',
      'imc' => 'inner membrane complex',
      'early golgi' => 'cis-golgi',
      'late golgi' => 'trans golgi',
      'pv' => 'parasitophorous vacuole',
      'knobs' => 'knob',
      'RBC Surface' => 'erythrocyte cytoplasm',
      'FV' => 'food vacuole',
      'erythrocyte membrane' => 'erythrocyte plasma membrane',
      'rbc membrane' => 'erythrocyte plasma membrane',
      'erythrocyte surface' => 'erythrocyte plasma membrane',
      'rbc cytoplasm vesicles' => 'erythrocyte cytoplasmic vesicle',
      'rhoptries' => 'rhoptry',
      'micronemes' => 'microneme',
      'cytosol membranous structures' => 'cytosol',
      'cytoplasmic foci' => 'cytoplasm',
      'nucleolus' => 'nucleus',
      'telomeric foci' => 'nucleus',
      'pv membrane' => 'parasitophorous vacuole membrane',
      'erythrocyte cytoplasm punctate' => 'erythrocyte cytoplasm',
      'vesicle' => 'cytoplasmic vesicle',
      'plasma membrane' => 'parasite plasma membrane',
      'surface' => 'parasite plasma membrane',
      'pm' => 'parasite plasma membrane',
      'fv membrane' => 'food vacuole membrane',
      'limiting membranes' => 'parasite plasma membrane',
      'dense granules' => 'dense granule',
      'cytosol diffuse' => 'cytosol',
      'vesicles under rbc surface' => 'vesicle under erythrocyte surface',
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
      'merozoite membrane' => "parasite plasma membrane",
      'fv lumen' => 'food vacuole lumen',
      'rbc periphery' => 'erythrocyte periphery',
      'cytostomal vacuole' => 'cytostome',
      'pv subdomains' => 'parasitophorous vacuole subdomains',
      'red cell membrane' => 'erythrocyte plasma membrane',
      'membranous structures in red blood cell' => 'maurer\'s cleft',
      'plasmalemma' => 'parasite plasma membrane',
      'only external sporozoite membrane' => 'nowhere except sporozoite plasma membrane',
      'poles' => 'cell poles',
      'near nucleus' => 'area around nucleus',
      'only sporozoite cell membrane' => 'nowhere except sporozoite surface',
      'cytoplasmic vesicles' => 'cytoplasmic vesicle',
      'cytoplasmic structures' => 'cytoplasmic structure',
      'maurer\'s clefts' => 'maurer\'s cleft',
      'intracellular inclusions' => 'intracellular inclusion',
      'internal organelles' => 'internal organelle',
      'osmiophilic bodies' => 'osmiophilic body',
      'vesicles' => 'vesicle',
      'erythrocyte cytoplasmic vesicles' => 'erythrocyte cytoplasmic vesicle',
      'erythrocyte cytoplasmic structures' => 'erythrocyte cytoplasmic structure',
      'alveoli' => 'inner membrane complex',
      'host erythrocyte' => 'erythrocyte',
      'near parasite membrane' => 'periphery'
    }
  }

  # I hate parsers. Don't you?
  LOCALISATIONS_WITH_AND_IN_THEIR_NAME = [
    'between er and golgi',
    'between parasite pellicle and PVM',
    'between pellicle and parasitophorous vacuole membrane'
  ]
end
