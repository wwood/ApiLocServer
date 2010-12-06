
class BScript
  # Ignore these proteins from the lists
  def hagai_known_to_ignore
    %w(PFC0710w PF11_0410 PF10_0168 PFC0710w PFC0710w PF11_0410 coI coxIII PF11_0377)
  end
  
  def localisation_from_hagai_pathways(programmatic=false)
    pathways = {} #hash of names to array of coding regions
    
    # parse the html files in /home/ben/phd/screenscraping_hagai/sites.huji.ac.il/malaria/maps
    # and classify each pathway with a localisation, being careful of course.
    base_dir = "#{PHD_DIR}/screenscraping_hagai/sites.huji.ac.il/malaria/maps"
    Dir.foreach(base_dir) do |filename|
      next unless filename.match(/.html$/) #ignore non-HTML files
      
      codes = []
      File.open(File.join(base_dir,filename)).each_line do |line|
        # e.g.     <area shape=CIRCLE coords="777,237,17" href="http://malaria.ucsf.edu/comparison/comp_orflink.php?ORF=PFI1565w">
        if matches = line.match(/area .*comp_orflink.php\?ORF=(.*?)\"/)
          plasmodb = matches[1].strip
          plasmodb = hagai_manual_fixes[plasmodb] if hagai_manual_fixes[plasmodb] #fix if this is a special case
          unless hagai_known_to_ignore.include?(plasmodb)
            code = CodingRegion.ff(plasmodb)
            codes.push code unless code.nil?
            if code.nil?
              $stderr.puts "Failed to find gene #{plasmodb}, ignoring"
            end
          end
        end
      end
      
      if codes.empty?
        puts filename unless programmatic
      else
        if pathways[filename]
          raise Exception, "Duplicate pathway #{filename}"
        end
        pathways[filename] = codes
      end
    end
    pathways
  end
  
  # A hash of pathways names to coding regions within.
  def hagai_pathways
    # first, iterate through the regular pathways
    pathways = localisation_from_hagai_pathways(true) # has of pathway names to array of coding regions within
    
    # second, iterate through the manually parsed pathways
    base_dir = "#{PHD_DIR}/screenscraping_hagai/manually_parsed"
    Dir.foreach(base_dir) do |file|
      filename = "#{base_dir}/#{file}"
      next if File.directory?(filename) #Dir gives back "." as well as the plain 'ol files
      File.open(filename) do |f|
        codes = []
        f.each_line do |plasmodb_id|
          plasmodb_id.strip!
          plasmodb_id = hagai_manual_fixes[plasmodb_id] if hagai_manual_fixes[plasmodb_id]
          unless hagai_known_to_ignore.include?(plasmodb_id)
            code = CodingRegion.ff(plasmodb_id)
            if code.nil?
              $stderr.puts "Couldn't parse `#{plasmodb_id}' from #{file}"
            else
              codes.push code
            end
          end
        end
        $stderr.puts "Couldn't find any genes in manually parsed pathway #{f}" if codes.empty?
        raise if pathways[file]
        pathways[file] = codes
      end
    end
    
    return pathways
  end
  
  # Output a table for each gene with:
  # * gene id
  # * falciparum locs
  # * apicomplexan locs
  # * yeast/other locs
  def manual_inspection_of_hagai_pathways
    hagai_pathways.each do |name, codes|
      puts
      puts name
      codes.each do |code|
        ogene = code.single_orthomcl!
        group = nil
        unless ogene.nil? #unless there is not orthomcl linked
          group = ogene.official_group
        end
        other_species = []
        unless group.nil?
          other_species = CodingRegion.go_cc_usefully_termed.not_apicomplexan.all(
            :joins => {:orthomcl_genes => :orthomcl_groups},
            :conditions => ["orthomcl_groups.id = ?", group.id],
            :select => 'distinct(coding_regions.*)',
            :order => 'coding_regions.id'
          )
        end
        
        
        puts [
        code.string_id,
        code.annotation.annotation,
        code.apilocalisations.reach.name.join(", "),
        other_species.collect{|c| 
          [c.species.name, c.string_id,
          c.coding_region_go_terms.cc.useful.all.uniq.reach.go_term.term.join(", "),
          ].join('-')
        }.join('   ')
        ].join("\t")
      end
    end
  end
  
  # Return a list of gene ids linked to expression contexts, as found
  # by grouping things in pathways to the same level of localisation.
  def hagai_pathways_with_localisations
    gene_locs = {}
    classifications = {
      # easier to parse pathways
      'rRNAstruct.html' => 'nucleus',
      'SUMOylation.html' => 'nucleus',
      'glycineSerinemetpath.html' => 'mitochondrion',
      'Histone.html' => ' nucleus',
      'elongat_f2.html' => 'nucleus',
      'RNApolyIII.html' => 'nucleus',
      'nicotinatemetpath.html' => 'nucleus',
      'proteaUbiqpath.html' => 'nucleus',
      'excisionrepair.html' => 'nucleus',
      'DNArepair.html' => 'nucleus',
      'organizKinetochore.html' => 'nucleus',
      'mitochondrionef.html' => 'mitochondrion',
      #'hemoglobinpolpath.html' => 'food vacuole', #some component specifically not food vacuole in P. falciparum ApiLoc
      'dnareplication.html' => 'nucleus',
      'gpiAnchor1path.html' => 'endoplasmic reticulum',
      'chromatin.html' => 'nucleus',
      'RNApolyII.html' => 'nucleus',
      'Kinetochore.html' => 'nucleus',
      'arginine.html' => 'nucleus',
      'replicationForm.html' => 'nucleus',
      'bulk_mRna.html' => 'nucleus',
      'qualityControl.html' => 'nucleus',
      'his_acet_methyl.html' => 'nucleus',
      'protProphase.html' => 'nucleus',
      'ubiquinonemetpath.html' => 'nucleus',
      'COPII.html' => 'endoplasmic reticulum',
      'complex_ubiquitin_ligase.html' => 'nucleus',
      # and harder to parse pathways
      'ribosomeStructMitochondrion.txt' => 'not nucleus',
      'ExcisionRepairOther protection modes.txt' => 'nucleus and cytosol',
      'apicoplastgenesIsoprenoid biosynthesis.txt' => 'apicoplast',
      'MerozoiteproteinsMicroneme.txt' => 'apical',
      'RibosomegenesPseudouridylate synthase.txt' => 'nucleus and cytosol',
      'protER.txt' => 'endoplasmic reticulum',
      'RibosomegenesExosome.txt' => 'nucleus',
      'nuclearGenesOne-carbon enzyme systems serine hydroxymethyltransferase and glycine-cleavage complex.txt' => 'mitochondrion',
      'ribosomeStructCytoplasm.txt' => 'not nucleus',
      'nuclearGenesPorphyrinAndCytochromeSynthesis.txt' => 'mitochondrion',
      'ribosomeStructCytoplasm.txt' => 'not nucleus',
      'nuclearGenesPorphyrinAndCytochromeSynthesis.txt' => 'mitochondrion',
      'ribosomeStructApicoplast.txt' => 'not nucleus',
      'RibosomegenesExoribonuclease.txt' => 'nucleus',
      'Ribosomegenes90S particles.txt' => 'nucleus',
      'MerozoiteproteinsRhoptryNeck.txt' => 'apical',
      'MerozoiteproteinsRhoptry.txt' => 'apical',
      'RibosomegenesRNAse MRP.txt' => 'nucleus',
      'RibosomegenesSnoRNPs.txt' => 'nucleus',
      'MerozoiteproteinsPeripheral surface or parasitophorous vacuole.txt' => 'not nucleus',
    }
    falciparum = Species.find_by_name(Species::FALCIPARUM_NAME)
    
    hagai_pathways.each do |name, codes| 
      if classifications[name]
        expression_contexts = Localisation.new.parse_name(classifications[name], falciparum)
        locs = expression_contexts.reach.localisation.retract
        codes.each do |code|
          if gene_locs[code]
            gene_locs[code] = [gene_locs[code],locs].flatten.uniq
          else
            gene_locs[code] = locs
          end
        end
      end
    end
    return gene_locs
  end
  
  # Upload the pathways that have localisation data in them to the database
  def hagai_pathway_localisations_to_database
    hagai_pathways_with_localisations.each do |code, locs|
      loc_annotation = LocalisationAnnotation.find_or_create_by_localisation_and_coding_region_id(
        "http://sites.huji.ac.il/malaria",
        code.id
      )
      locs.each do |loc|
        MetabolicMapsExpressionContext.find_or_create_by_coding_region_id_and_localisation_id_and_localisation_annotation_id(
          code.id,
          loc.id,
          loc_annotation.id
        ).save!
      end
    end
  end
end