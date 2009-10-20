# To change this template, choose Tools | Templates
# and open the template in the editor.

module LocalisationConstants
  KNOWN_LOCALISATIONS = {
    Species::FALCIPARUM_NAME => [
      'cell poles', #antierior + posterior
      'posterior',
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
      'trans golgi',
      'golgi',
      'golgi matrix',
      'cis-golgi',
      'endoplasmic reticulum',
      'endoplasmic reticulum associated vesicles',
      'vesicles',
      'intracellular vacuole',
      'intracellular vacuole membrane',
      'intracellular inclusions',
      'vesicles near parasite surface',
      'peripheral',
      'merozoite associated material',
      'apical end of surface',
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
      'gametocyte attached erythrocytic vesicles',
      'sporozoite surface', #sporozoite locs
      'oocyst wall',
      'zygote remnant', # the zygote part when the ookinete is budding off from the zygote
      'ookinete protrusion', # the opposite of zygote remnant
      'oocyst protrusion', # during ookinete to oocyst transition, oocyst starts out as a round protrusion
      'peripheral of oocyst protrusion', # possibly an analogue of IMC?
      'trail', # the trail that sporozoites/merozoites/etc. leave behind when they move
      'nowhere except sporozoite plasma membrane',
      'cytoplasmic vesicles',
      'erythrocyte cytoplasmic vesicles',
      'intraerythrocytic cysternae',
      'vesicles under erythrocyte surface',
      'area around nucleus', # not a very specific localisation compared to 'nuclear envelope' or 'ER'
      'nuclear envelope',
      'perinuclear',
      'far nuclear periphery',
      'interior of nucleus',
      'internal organelles',
      'intracellular',
      'cytoplasmic structures',
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
    ],
    Species::TOXOPLASMA_GONDII_NAME => [
      'nascent rhoptries',
      'rhoptries',
      'limiting membrane of rhoptry',
      'luminal membrane of rhoptry',
      'rhoptry neck',
      'rhoptry body',
      'micronemes',
      'secretory organelles',
      'nowhere except microneme',
      'dense granules',
      'microdomains of dense granule membrane',
      'apicoplast',
      'reticular staining outside apicoplast',
      'apicoplast periphery',
      'innermost apicoplast membrane',
      'apicoplast membrane',
      'apicoplast intermembrane space',
      'apicoplast lumen',
      'mitochondria',
      'anterior adjacent to mitochondria',
      'adjacent to mitochondria',
      'cytosol',
      'two unknown vesicular bodies',
      'nucleus',
      'nucleolus',
      'nuclear envelope',
      'posterior to nucleus',
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
      'between er and golgi',
      'golgi',
      'cytoplasmic region close to the golgi',
      'cisternal rims of the late golgi',
      'post golgi compartment',
      'golgi associated transport vesicles',
      'invasion furrow',
      'moving junction',
      'cytoplasmic face of the host plasma membrane at moving junction',
      'inner membrane complex',
      'adjacent to the inner membrane complex',
      'cytoplasmic face of inner membrane complex',
      'nowhere except cytoplasmic face of inner membrane complex',
      'centrocone',
      'apical end of the nuclear envelope',
      'parasitophorous vacuole membrane',
      'parasitophorous vacuole',
      'periphery of parasitophorous vacuole',
      'sporozoite parasitophorous vacuole 1',
      'membranous parasitophorous vacuole tubules',
      'peroxisome',
      'trans-golgi network', #according to Cheryl, the trans should be in italics. meh.
      'wall forming bodies',
      'evacuole',
      'intravacuolar network',
      'cytoskeleton',
      'vesicles',
      'endosome-related compartments',
      'early endosome',
      'endosomal membranes',
      'endosomal vacuole',
      'transport vesicles',
      'cytoplasmic vesicles',
      'cytoplasmic structures',
      'cytoplasmic foci',
      'anterior vesicles',
      'posterior vesicles',
      'vesicles budding off zoite posterior',
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
      'multi-lamellar vesicles',
      'periphery of parasite',
      'beneath alveoli',
      'centriole',
      'centrosome',
      'microtubule',
      'subpellicular microtubules',
      'attachment site of subpellicular microtubules',
      'mother inner membrane complex',
      'daughter inner membrane complex',
      'spindle pole',
      'cap at basal end of mother',
      'cap at basal end of daughter',
      'basal',
      'acidocalcisomes',
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
      'tubular structures in parasitophorous vacuole',
      'posterior extremity of cup-shaped inner membrane cytoskeleton scaffolds',
    ],
    Species::BABESIA_BOVIS_NAME => [
      'apical',
      'released into extracellular mileiu',
      'cytoplasm',
      'spherical body organelles',
      'host erythrocyte membrane',
      'plasma membrane', #ie. surface of parasite
      'cytoplasmic accumulations',
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
      'wall forming bodies',
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
  }

  KNOWN_LOCALISATION_SYNONYMS = {
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
    },
    Species::NEOSPORA_CANINUM_NAME => {
      'cytoplasm mostly near nuclear membrane' => 'area around nucleus',
      'mj' => 'moving junction',
      'surface' => 'cell surface',
      'parasite surface' => 'cell surface',
    },
    Species::BABESIA_BOVIS_NAME => {
      'surface' => 'plasma membrane',
      'host cell surface' => 'host erythrocyte membrane',
      'inner surface of host cell cytoplasm' => 'parasitophorous vacuole membrane'
    },
    Species::TOXOPLASMA_GONDII_NAME => {
      'rear end of parasite' => 'posterior',
      'limiting membrane of pv' => 'parasitophorous vacuole membrane',
      'nuclear' => 'nucleus',
      'adjacent to mitochondrion' => 'adjacent to mitochondria',
      'flagellar basal bodies' => 'flagellate basal body',
      'residual bodies' => 'residual body',
      'tubular structures in pv' => 'tubular structures in parasitophorous vacuole',
      'pm' => 'parasite plasma membrane',
      'limiting membrane' => 'parasite plasma membrane',
      'cortical er' => 'cortical endoplasmic reticulum',
      'perinuclear er' => 'perinuclear endoplasmic reticulum',
      'distal end of vacuole' => 'distal end of parasitophorous vacuole',
      'vesicles in apical end' => 'anterior vesicles',
      'vesicles in basal end' => 'posterior vesicles',
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
      'cytosolic vesicles' => 'cytoplasmic vesicles',
      'plasma membrane' => 'parasite plasma membrane',
      'mother imc' => 'mother inner membrane complex',
      'daughter imc' => 'daughter inner membrane complex',
      'host cell membrane' => 'host cell plasma membrane',
      'imc' => 'inner membrane complex',
      'growing bud of daughter cell' => 'intracellular',
      'tgn' => 'trans-golgi network',
      'cytosolic' => 'cytosol',
      'microneme' => 'micronemes',
      'pellicle' => 'inner membrane complex',
      'mj' => 'moving junction',
      'apical end' => 'apical',
      'moving junction ring' => 'moving junction',
      'surface' => 'parasite plasma membrane',
      'rhoptry' => 'rhoptries',
      'dense granule' => 'dense granules',
      'er' => 'endoplasmic reticulum',
      'membrane' => 'parasite plasma membrane',
      'mitochondrion' => 'mitochondria',
      'mitochondrial' => 'mitochondria',
      'ring structure at apical imc' => 'ring structure at apical inner membrane complex',
      'pvm' => 'parasitophorous vacuole membrane',
      'pv' => 'parasitophorous vacuole',
      'pv membrane' => 'parasitophorous vacuole membrane',
      'periphery of pv' => 'periphery of parasitophorous vacuole',
      'membranous pv tubules' => 'membranous parasitophorous vacuole tubules',
      'ring structure at posterior imc' => 'ring structure at posterior inner membrane complex',
    },
    Species::FALCIPARUM_NAME => {
      'cis golgi' => 'cis-golgi',
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
      'under pm' => 'under parasite plasma membrane',
      'rhoptry pundicle' => 'rhoptry neck',
      'ER' => 'endoplasmic reticulum',
      'tER' => 'endoplasmic reticulum',
      'imc' => 'inner membrane complex',
      'early golgi' => 'cis-golgi',
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
      'merozoite membrane' => "parasite plasma membrane",
      'fv lumen' => 'food vacuole lumen',
      'rbc periphery' => 'erythrocyte periphery',
      'cytostomal vacuole' => 'cytostome',
      'pv subdomains' => 'parasitophorous vacuole subdomains',
      'red cell membrane' => 'erythrocyte plasma membrane',
      'membranous structures in red blood cell' => 'maurer\'s clefts',
      'plasmalemma' => 'parasite plasma membrane',
      'only external sporozoite membrane' => 'nowhere except sporozoite plasma membrane',
      'poles' => 'cell poles',
      'spot in parasitophorous vacuole close to food vacuole' => 'parasitophorous vacuole close to food vacuole'
    }
  }

  # I hate parsers. Don't you?
  LOCALISATIONS_WITH_AND_IN_THEIR_NAME = [
    'between er and golgi',
    'between parasite pellicle and PVM',
    'between pellicle and parasitophorous vacuole membrane'
  ]
end
