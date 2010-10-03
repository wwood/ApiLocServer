class ApilocLocalisationTopLevelLocalisation < LocalisationTopLevelLocalisation
  APILOC_TOP_LEVEL_LOCALISATION_HASH = {
    'apicoplast' => [
      'apicoplast',
      'apicoplast intermembrane space',
      'apicoplast lumen',
      'apicoplast membrane',
      'apicoplast periphery',
      'innermost apicoplast membrane',
      #      'near apicoplast membranes', # the only example of this ferrochelatase, which isn't apicoplast.
      'outermost apicoplast membrane',
      'nowhere except apicoplast'
    ],

    'apical' => [
      'anterior cytoplasm',
      'anterior structure','anterior vacuole',
      'anterior vesicle','apical',
      'apical annuli',
      'apical conoid',
      'apical end of endoplasmic reticulum',
      'apical end of surface',
      'apical end of the nuclear envelope',
      'apical parasite plasma membrane',
      'cap at basal end of daughter',
      'cap at basal end of mother',
      'conoid',
      'conoid collar',
      'conoid fiber ends',
      'cytoplasmic face of the host plasma membrane at moving junction',
      'dense granule',
      'electron dense collar',
      'extracellular apical pole of ookinete protrusion',
      'high electron dense microneme',
      'limiting membrane of rhoptry',
      'luminal membrane of rhoptry',
      'microdomains of dense granule membrane',
      'microneme',
      'microneme lumen',
      'microneme membrane',
      'mononeme',
      'nascent conoid',
      'nascent rhoptry',
      'nowhere except rhoptry',
      'pellicle',
      'pellicle membrane',
      'peripheral of microneme',
      'rhoptry',
      'rhoptry body',
      'rhoptry bulb',
      'rhoptry neck',
      'sub-apical',
      'sub-pellicular region at the anterior',

      # merged merozoite surface locs below
      #      'merozoite surface' => [
      'merozoite surface',
      'apical plasma membrane',
      'apical surface',
      'around merozoite',
      'merozoite surface',
      #      ],

    ],

    'inner membrane complex' => [
      'attachment site of subpellicular microtubule',
      'beneath alveoli',
      'cytoplasmic face of inner membrane complex',
      'daughter inner membrane complex',
      'free end of inner membrane complex',
      'inner membrane complex',
      'inner membrane complex microtubules',
      'mother inner membrane complex',
      'moving junction',
      'ring at basal end',
      'ring structure at apical inner membrane complex',
      'ring structure at posterior inner membrane complex',


    ],


    'endoplasmic reticulum' => [
      'cortical endoplasmic reticulum',
      'endoplasmic reticulum',
      'endoplasmic reticulum associated vesicle',
      'perinuclear endoplasmic reticulum',


    ],


    'golgi apparatus' => [
      'cis-golgi',
      'cisternal rims of the late golgi',
      'cytoplasmic region close to the golgi',
      'golgi',
      'golgi associated transport vesicle',
      'golgi matrix',
      'post golgi compartment',
      'trans golgi',
      'trans-golgi network',




    ],


    'exported' => [
      'cleft like parasitophorous vacuole membrane protrusion',
      'close to parasitophorous vacuole membrane',
      'cytoplasmic face of host erythrocyte membrane',
      'cytoplasmic inclusion',
      'cytoplasmic matrix',
      'cytoplasmic side of erythrocyte membrane',
      'cytoplasmic side of host cell membrane',
      'cytosolic face of plasma membrane',
      'cytosolic side of host cell membrane',
      'erythrocyte',
      'erythrocyte cytoplasm',
      'erythrocyte cytoplasm adjacent to the parasitophorous vacuole',
      'erythrocyte cytoplasmic structure',
      'erythrocyte cytoplasmic structure near parasitophorous vacuole',
      'erythrocyte cytoplasmic vesicle',
      'erythrocyte cytosol',
      'erythrocyte periphery',
      'erythrocyte plasma membrane',
      'exoneme',
      'exported',
      'exposed erythrocyte plasma membrane',
      'gametocyte attached erythrocytic vesicle',
      'host cell',
      'host cell cytoplasm',
      'host cell cytosol',
      'host cell membrane',
      'host cell nucleus',
      'host cell plasma membrane',
      'host cell surface',
      'host erythrocyte membrane',
      'intraerythrocytic cysternae',
      'knob',
      'maurer\'s cleft',
      'membrane of lysed erythrocyte',
      'single small vesicle in erythrocyte',
      'vesicle under erythrocyte surface',


    ],

    'parasite plasma membrane' => [
      'cyst wall',
      'ookinete surface',
      'outer membrane of cyst wall',
      'parasite plasma membrane',
      'plasma membrane',
      'proximal to plasma membrane',
      'sporozoite surface',
      'straight side of d shaped parasite',
      'surface',
      'surrounding parasite',
      'under parasite plasma membrane',
      'underneath plasma membrane',
      'vesicle near parasite surface',
      'vesicle-like structure just under the parasite membrane',
      'vesicles near parasite surface',
    ],


    'cytoplasm' => [
      'cytoplasm',
      'cytoplasm proximal to amylopectin-like granules',
      'cytoplasmic accumulation',
      'cytoplasmic foci',
      'cytosol',
      'intracellular',
      'intracellular inclusion',
      'merozoite cytosol',
      'peripheral',
      'periphery of parasite',
      'throughout parasite',
    ],


    'nucleus' => [
      'far nuclear periphery',
      'interior of nucleus',
      'mitotic spindle in nucleus',
      'nuclear',
      'nuclear envelope',
      'nuclear interior',
      'nuclear membrane',
      'nuclear pole',
      'nucleolus',
      'nucleus',
      'outer nuclear envelope',
      'replication foci',
      'replication foci in nucleus',
      'telomeric cluster',
      'perinuclear',
      'histones'
    ],


    'food vacuole' => [
      'food vacuole',
      'food vacuole lumen',
      'food vacuole membrane',

    ],


    'mitochondrion' => [
      'mitochondria',
      'mitochondrial inner membrane',
      'mitochondrial membrane',
      'mitochondrion',


    ],

    'parasitophorous vacuole' => [
      'parasitophorous vacuole',
      'parasitophorous vacuole close to food vacuole',
      'parasitophorous vacuole membrane',
      'parasitophorous vacuole subdomains',
      'periphery of parasitophorous vacuole',
      'punctate parasitophorous vacuole',
      'sporozoite parasitophorous vacuole 1',
      'tubular structure in parasitophorous vacuole',


    ],

  }
  @@loc_hash = APILOC_TOP_LEVEL_LOCALISATION_HASH

  def upload_apiloc_top_level_localisations
    @@loc_hash.each do |top, underlings|
      t = TopLevelLocalisation.find_or_create_by_name(top)
      t_negative = TopLevelLocalisation.find_or_create_by_name("not #{top}")
      underlings.each do |underling|
        # positive
        els = Localisation.find_all_by_name(underling)
        els.each do |l|
          ApilocLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
            l.id, t.id
          )
        end

        # negative
        els = Localisation.find_all_by_name("not #{underling}")
        els.each do |l|
          ApilocLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
            l.id, t_negative.id
          )
        end
      end
    end

    # Add 'others'
    other = TopLevelLocalisation.find_or_create_by_name('other')
    other_negative = TopLevelLocalisation.find_or_create_by_name('not other')
    Localisation.all.each do |loc|
      if loc.apiloc_top_level_localisation.nil?
        ApilocLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
          loc.id, other.id
        )
        l_negative = loc.negation
        ApilocLocalisationTopLevelLocalisation.find_or_create_by_localisation_id_and_top_level_localisation_id(
          l_negative.id, other_negative.id
        )
      end
    end
  end

  # Check to make sure each loc is assigned a top level localisation
  def check_for_unclassified
    Localisation.positive.all.each do |loc|
      if loc.apiloc_top_level_localisation.nil?
        $stderr.puts "Couldn't find '#{loc.name}' from #{loc.species.name}, #{loc.id} classified in the top level: #{loc.apiloc_top_level_localisation.inspect}"
      end
    end
  end
end
