require 'jgi_genes'
require 'simple_go'
require 'rio'
require 'api_db_genes'
require 'yeast_genome_genes'
require 'signalp'
require 'api_db_fasta'
require 'gff3_genes'
require 'tm_hmm_wrapper'
require 'rubygems'
require 'csv'
require 'bio'
require 'peach'

#require 'mscript'
require 'reach'
require 'plasmo_a_p'
require 'top_db_xml'
require 'pdb_tm'
#require 'go'
require 'wormbase_go_file'
require 'libsvm_array'
require 'bl2seq_report_shuffling'
require 'rarff'
require 'stdlib'
require 'babesia'


MOLECULAR_FUNCTION = 'molecular_function'
YEAST = 'yeast'


WORK_DIR = "#{ENV['HOME']}/Workspace"



class BScript
  PHD_DIR = "#{ENV['HOME']}/phd"
  DATA_DIR = "#{ENV['HOME']}/phd/data"
  
  require 'microarray_timepoint' #include the constants for less typing
  include MicroarrayTimepointNames

  def brafl_to_database
    puts "Deleting all records..."
    
    Gene.delete_all
    CodingRegion.delete_all 
    
    jgi = JgiGenesGff.new("#{DATA_DIR}/jgi/Brafl1/Brafl1.FilteredModels1.gff")
    iter = jgi.distance_iterator

    puts "Inserting..."
    
    while iter.has_next_distance
      d = iter.next_distancest
      jgi_gene = iter.next_gene
      g = Gene.new(
        :name => jgi_gene.name,
        :species_id => 1
      )
      g.save!
      CodingRegion.new(
        :jgi_protein_id => jgi_gene.protein_id,
        :gene_id => g.id,
        :upstream_distance => d
      ).save!
    end

    puts "finished."
  end
  
  def go_to_database
    require 'simple_go'
    
    GoAlternate.destroy_all
    GoTerm.destroy_all
    

    sg = SimpleGo.new("#{DATA_DIR}/GO/cvs/go/ontology/gene_ontology_edit.obo")
    while (e = sg.next_go)
      go = GoTerm.find_or_create_by_go_identifier_and_term_and_aspect(
        e.go_id,
        e.name,
        e.namespace
      )
      
      if e.alternates
        e.alternates.each {|a|
          GoAlternate.find_or_create_by_go_identifier_and_go_term_id(
            a,
            go.id
          )
        }
      end
    end
  end
  
  # Upload the map file of generic to the database
  def go_map_to_database
    
    GenericGoMap.delete_all
    
    sm = GoMapParser.new("#{DATA_DIR}/GO/20080304/generic.map")
    
    while (e = sm.next_relation)
      # Get the ids
      term = GoTerm.find_by_go_identifier(e.child_id)
      if !term
        raise Exception, "Could not find term '#{e.child_id}' in the GoTerm database"
      end
      
      parents = []
      if e.all_parent_ids
        e.all_parent_ids.each {|go_id|
          p = GoTerm.find_by_go_identifier(go_id)
          if !term
            raise Exception, "Could not find term '#{go_id}' in the GoTerm database"
          end
          parents.push p
        }
        
        #construct and save new relation
        parents.each {|p|
          GenericGoMap.new(
            :child_id => term.id,
            :parent_id => p.id
          ).save!
        }
      end
    end
  end
  
  # Update the database so that brafl genes have the correct GO term associated.
  def brafl_go_to_database
    
    CodingRegionGoTerm.delete_all
    
    # Read the jgi file with the info in it
    jgi = File.open("#{DATA_DIR}/jgi/Brafl1/Brafl1.goinfo.tab")
    jgi.gets #skip the intro
    
    #for each protein id
    while (line = jgi.gets)
      line = line.rstrip
      #find the go identifier
      s = line.split("\t")
      
      if !s[4]
        raise Exception, "Badly parsed gene file: no go."
      end
      go = GoTerm.find_by_go_identifier_or_alternate(s[4])
      if !go
        raise Exception, "Could not find go identifier: #{s[4]}"
      end
      
      #find the coding region
      if !s[0]
        raise Exception, "Badly parsed gene file: no protein id."
      end
      
      coding  = CodingRegion.find_by_jgi_protein_id(s[0])
      if !coding
        raise Exception, "Could not find protein id: #{s[0]}"
      end
      
      CodingRegionGoTerm.create(
        :coding_region_id => coding.id,
        :go_term_id => go.id
      )
    end

  end
  
  def brafl_upstream_v_map
    # For each of the genes in brafl, create a list of upstream region
    # lengths associated with each so that they can be imported into R and
    # analysed for their distributions
    
    BraflUpstreamDistance.delete_all

    Gene.find_all_by_species_id(1).each {|gene|
      gene.coding_regions.each {|coding|
        
        # If null upstream region leave it alone
        if coding.upstream_distance
          
          coding.go_terms.each{|term|
            maps = GenericGoMap.find_all_by_child_id(term.id)
            
            maps.each {|map|
              
              if !maps or maps.length == 0
                raise Exception, "No parent found for term id #{term.id}"
              end
            
              BraflUpstreamDistance.create(
                :go_term_id => map.parent_id,
                :upstream_distance => coding.upstream_distance
              )
            }

          }
        
        end
      }
    }
  end
  
  
  def parent_map_terms
    parent_ids = GenericGoMap.find(:all, :select => 'distinct parent_id')
    
    parent_ids.each {|parent|
      term = GoTerm.find(parent.parent_id)
      puts [term.aspect, term.go_identifier, term.term].join("\t")
    }
  end
  
  
  
  def falciparum_to_database
    # abstraction!
    #    apidb_species_to_database Species.falciparum_name, "#{DATA_DIR}/falciparum/genome/plasmodb/5.4/Pfalciparum_3D7_plasmoDB-5.4.gff"
    apidb_species_to_database Species.falciparum_name, "#{DATA_DIR}/falciparum/genome/plasmodb/5.5/Pfalciparum_PlasmoDB-5.5.gff"
  end
  
  def gondii_to_database
    #    apidb_species_to_database Species::TOXOPLASMA_GONDII, "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/4.3/TgondiiME49/ToxoplasmaGondii_ME49_ToxoDB-4.3.gff"
    apidb_species_to_database Species::TOXOPLASMA_GONDII, "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.0/TgondiiME49_ToxoDB-5.0.gff"
  end
  
  def gondii_fasta_to_database
    #    fa = ToxoDbFasta4p3.new.load("#{DATA_DIR}/Toxoplasma gondii/ToxoDB/4.3/TgondiiME49/TgondiiAnnotatedProteins_toxoDB-4.3.fasta")
    fa = EuPathDb2009.new('Toxoplasma_gondii_ME49').load("#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.0/TgondiiME49AnnotatedProteins_ToxoDB-5.0.fasta")
    sp = Species.find_by_name(Species::TOXOPLASMA_GONDII_NAME)
    upload_fasta_general!(fa, sp)
  end
  
  def calculate_falciparum_distances
    puts "Removing all upstream distances"
    CodingRegion.update_all "upstream_distance = NULL"
    
    puts "calculating upstream distances"
    
    CodingRegion.find(:all).each do |c|
      c.upstream_distance = c.calculate_upstream_region
      c.save!
      print '.'
    end
  end
  
  
  def upload_GO_lists
    
    GoList.delete_all
    GoListEntry.delete_all
    
    # Found in R using as.vector(get("GO:0003674", GOMFCHILDREN)), using GO 
    # package
    mfs = ["GO:0003774","GO:0003824","GO:0005198","GO:0005215",
      "GO:0005488","GO:0015457","GO:0016209","GO:0016530","GO:0030188",
      "GO:0030234","GO:0030528","GO:0031386","GO:0042056","GO:0045182",
      "GO:0045499","GO:0045735","GO:0060089"]
    list = GoList.create!(
      :name => 'molecular function children'
    )
    
    mfs.each do |t|
      go_term = GoTerm.find_by_go_identifier_or_alternate(t)
      
      if !go_term
        raise Exception, "Go Term not found: #{t}"
      end
      
      GoListEntry.create!(
        :go_list_id => list.id,
        :go_term_id => go_term.id
      )
    end

  end
  
  
  def upload_mfs_go_map
    sm = GoMapParser.new("#{DATA_DIR}/GO/20080304/mf.map")
    
    go_map = GoMap.find_or_create_by_name MOLECULAR_FUNCTION
    GoMapEntry.delete_all("go_map_id=#{go_map.id}")
    
    while (e = sm.next_relation)
      # Get the ids
      term = GoTerm.find_by_go_identifier(e.child_id)
      if !term
        raise Exception, "Could not find term '#{e.child_id}' in the GoTerm database"
      end
      
      parents = []
      if e.all_parent_ids
        e.all_parent_ids.each {|go_id|
          p = GoTerm.find_by_go_identifier(go_id)
          if !term
            raise Exception, "Could not find term '#{go_id}' in the GoTerm database"
          end
          parents.push p
        }
        
        #construct and save new relation
        parents.each {|p|
          # Don't allow duplicates (which I've seen occur with GO:0004672
          if !GoMapEntry.find_by_go_map_id_and_parent_id_and_child_id(
              go_map.id, term.id, p.id
            )
            
            GoMapEntry.create!(
              :go_map_id => go_map.id,
              :child_id => p.id,
              :parent_id => term.id
            )
          end
        }
      end
    end
  end
  
  def analyse_mf_upstream_lengths
    
    sp = Species.find_by_name 'falciparum'
    BraflUpstreamDistance.delete_all
    map = GoMap.find_by_name MOLECULAR_FUNCTION
    
    Gene.find(:all, :include => [:scaffold], 
      :conditions => "scaffolds.species_id=#{sp.id}").each {|gene|
      
      
      gene.coding_regions.each {|coding|
        
        # If null upstream region leave it alone
        if coding.upstream_distance
          
          coding.go_terms.each{|term|
            
            # Only worry about molecular function for the moment
            if term.aspect == MOLECULAR_FUNCTION and 
                term.term != MOLECULAR_FUNCTION
              
              parents = GoMapEntry.find_all_by_go_map_id_and_child_id(map.id, term.id)

            
              if !parents or parents.length == 0
                # if it is already a parent I'm ok with that
                parents = GoMapEntry.find_all_by_go_map_id_and_parent_id(map.id, term.id)
                if !parents or parents.length == 0
                  $stderr.puts "No parent found for term id #{term.id}. Could just be a top level term without descendents."
                end
              end 
              
              
              parents.each {|p|
                BraflUpstreamDistance.create!(
                  :coding_region_id => coding.id,
                  :go_term_id => p.parent_id,
                  :upstream_distance => coding.upstream_distance
                )
              }
            end
          }
        else
          $stderr.puts "No upstream distance for #{coding.id}"
        end
      }
    }
  end
  
  # Compare upstream lengths to orientation of upstream gene.
  def find_coding_region_lengths
    # For each intergenic region
    Cd.find(:all, :order => '')
    
  end
  
  def upload_gene_lists
    filenames = 
      [
      "#{DATA_DIR}/falciparum/localisation/apicoplast.Stuart.20080215.txt",
      "#{DATA_DIR}/falciparum/localisation/tRNASynthetases/apicoplast.Stuart.20080220.txt",
      "#{DATA_DIR}/falciparum/localisation/tRNASynthetases/cytosolic.Stuart.20080220.txt",
      "#{DATA_DIR}/falciparum/localisation/exportpred/exportPred10.txt",
      "#{DATA_DIR}/falciparum/exportpred/exportome.csv",
      #      "#{PHD_DIR}/babesiaApicoplastReAnnotation/annotation1/Pvi_Pfa_Tpa_HIGH_confid_set3",
      #      "#{PHD_DIR}/babesiaApicoplastReAnnotation/annotation1/Pvi_Pfa_Tpa_LOWER_confid_set",
      "#{DATA_DIR}/falciparum/localisation/pexelPlasmoDB5.5.txt",
      "#{DATA_DIR}/falciparum/localisation/htPlasmoDB5.5.txt"
    ]
    
    filenames.each do |f|
      r = rio(f)
      
      name = r.basename.to_s
      puts "uploading #{name}"
      
      list = PlasmodbGeneList.find_or_create_by_description name
      
      list.plasmodb_gene_list_entries.each do |e|
        e.destroy
      end
      
      # Read all the lines
      r.each_line do |l|
        l = l.chomp.rstrip.lstrip
        
        coding = CodingRegion.find_by_name_or_alternate l
        
        if !coding
          $stderr.puts "No coding region found for #{l}"
          next
        end
        
        PlasmodbGeneListEntry.find_or_create_by_coding_region_id_and_plasmodb_gene_list_id(
          coding.id,
          list.id
        )
      end
    end
  end
  
  def winzeler_2003_clusters_to_database
    
    
    set = Clusterset.find_or_create_by_name 'Winzeler2003k15'
    set.clusters.each do |c|
      c.destroy
    end
    
    first = true
    
    CSV.open("#{DATA_DIR}/falciparum/microarray/Winzeler2003/both.log.k15.csv", 'r') do |row|
      if first
        first = false
        next
      end
      
      if row.length < 15 #more needed, too lazy to count
        raise Exception, "Strange line: #{row}"
      end
      
      plasmodbId = row[0]
      clusterId = row[2]
      
      coding = CodingRegion.find_by_name_or_alternate plasmodbId
      if !coding
        $stderr.puts "No coding region found for #{plasmodbId}"
        next
      end
      
      cl = Cluster.find_or_create_by_published_number_and_clusterset_id(
        clusterId, set.id
      )
      
      if ClusterEntry.find_by_cluster_id_and_coding_region_id(
          cl.id, coding.id)
        $stderr.puts "Duplicate plasmodb ignored: #{plasmodbId}"
        next
      end
      ClusterEntry.create!(
        :cluster_id => cl.id,
        :coding_region_id => coding.id
      )
    end
  end
  
  # For each of the gene lists, work out the distribution in given clusters
  def list_clusters
    Clusterset.find(:all).each do |cset|
      PlasmodbGeneList.find(:all).each do |list|
        
        bads = []
        
        h = Hash.new

        list.plasmodb_gene_list_entries.each do |entry|
          centry = ClusterEntry.find_by_coding_region_id(entry.coding_region_id)
          if !centry
            bads.push entry.coding_region.string_id
            next
          end
          cluster = centry.cluster
          
          k = cluster.published_number
          
          if h[k]
            h[k] = h[k]+1
          else
            h[k] = 1
          end
          
          
        end
        
        puts list.description
        h.keys.sort.each do |k|
          count = ClusterEntry.count(:conditions => "published_number=#{k}", :include => :cluster)
          puts "#{k} #{h[k]} #{count}"
        end
        puts "#{bads.length} #{bads.join(',')}"
      end
    end
    
  end
  
  
  def upload_alternates
    iter = ApiDbGenes.new("#{DATA_DIR}/falciparum/genome/plasmodb/5.4/Pfalciparum_3D7_plasmoDB-5.4.gff")
    
    # Delete all the stuff before it
    CodingRegionAlternateStringId.delete_all

    while (g = iter.next_gene)
      if g.alternate_ids
        g.alternate_ids.each do |alt|
          
          code = CodingRegion.find_by_string_id g.name
          if !code
            raise Exception, "No coding region found for plasmodbId #{g.name}"
          end
          
          CodingRegionAlternateStringId.create!(
            :coding_region_id => code.id,
            :name => alt
          )
        end
      end
      
      
    end
  end
  
  def update_derisi_plasmodbids
    count = 0
    Derisi20063d7Logmean.find(:all).each do |d|
      newPlasmodbId = CodingRegionAlternateStringId.find_by_name d.plasmodbid
      if newPlasmodbId
        d.plasmodbid = newPlasmodbId.coding_region.string_id
        d.save!
        count = count+1
      end
    end
    
    puts "Updated #{count} entries"
  end
  
  def add_coding_region_ids_to_derisi
    Derisi20063d7Logmean.find(:all).each do |d|
      code = CodingRegion.find_by_name_or_alternate(d.plasmodbid)
      if code
        d.coding_region_id = code.id
        d.save!
      else
        $stderr.puts "No coding region found for #{d.plasmodbid}"
      end
      
    end
  end


  # Print out derisi microarray data for all the lists I've created
  def microarrayLists
    require 'csv'
    
    PlasmodbGeneList.find(:all).each do |list|
      puts
      puts list.description
      firsts = {}
      
      puts "list length: #{list.plasmodb_gene_list_entries.length}"
      
      dees = Derisi20063d7Logmean.find(:all, 
        :include => {
          :coding_region => :plasmodb_gene_list_entries
        },
        :conditions => "plasmodb_gene_list_id=#{list.id}"
      )
      
      puts "derisi matches total #{dees.length}"
      
      accepts = dees.reject {|g|
        if firsts[g.coding_region_id]
          true
        else
          firsts[g.coding_region_id] = 1
          false
        end
      }
      
      puts "derisi distict matches: #{accepts.length}"
      
      genes = accepts.collect {|g|
        a = [g.plasmodbid]
        g.timepoints.each do |t|
          a.push t
        end
        a
      }
      
      CSV.open("/tmp/#{list.description}.csv", 'w') do |writer|
        genes.each do |row|
          writer << row
        end
      end
      
    end
  end
  
  
  def upload_yeastgfp_gff
    
    sp = Species.find_or_create_by_name YEAST
    
    iter = YeastGenomeGenes.new(
      "#{DATA_DIR}/yeast/yeastgenome/20080321/saccharomyces_cerevisiae.gff")
    
   
    puts "Deleting..."
    
    # I hope the dependents work...
    sp.scaffolds.each do |scaff|
      puts scaff.destroy.name
    end
    
    puts "Inserting..."
    
    gene = iter.next_gene
    
    
    
    while gene
      
      # Create scaffold if not done already
      if !gene.seqname
        raise Exception, "No seqname in gene: #{gene}"
      end
      scaff = Scaffold.find_or_create_by_name_and_species_id(
        gene.seqname, sp.id
      )
      
      g = Gene.new(
        :scaffold_id => scaff.id,
        :name => gene.name
      )
      g.save!
      code = CodingRegion.new(
        :string_id => gene.name,
        :gene_id => g.id,
        :orientation => gene.strand
      )
      code.save!
      
      if gene.alternate_ids
        gene.alternate_ids.each do |alt|
          CodingRegionAlternateStringId.create!(
            :name => alt,
            :coding_region_id => code.id
          )
        end
      end
      
      gene.cds.each {|cd|
        Cd.create(
          :coding_region_id => code.id,
          :start => cd.from,
          :stop => cd.to
        )
      }
      
      if gene.go_identifiers
        gene.go_identifiers.each do |goid|
          go = GoTerm.find_by_go_identifier_or_alternate goid
          if !go
            $stderr.puts "No go term found for #{goid}"
            next
          end
          
          # This should get rid of alternate+real GO term being attributed
          # to the same gene, and therefore causing a duplicate.
          if !CodingRegionGoTerm.find_by_go_term_id_and_coding_region_id(
              go.id, code.id)
            
            CodingRegionGoTerm.create!(
              :go_term_id => go.id,
              :coding_region_id => code.id
            )
          end
        end
      end
      
      gene = iter.next_gene
    end
  end
  
  
  def yeast_gfp_to_database
    require 'yeast_gfp_localisation'
    locs = YeastGfpLocalisation.new "#{ENV['HOME']}/phd/data/yeast/yeastgfp/allOrfData.txt"
    
    #    CodingRegionLocalisation.delete_all
    method = LocalisationMethod.find_or_create_by_description LocalisationMethod.yeast_gfp_description
    
    # Add the types of localisations measured
    locs.localisations.each do |lname|
      Localisation.find_or_create_by_name lname
    end
    count = 0
    
    # Add each visualised row at a time
    while (l = locs.next_loc)
      code = CodingRegion.find_by_name_or_alternate(l.orf_name)
      if !code
        raise Exception, "No coding region called #{l.orf_name} found"
      end

      if l.localisations      
        l.localisations.each do |part|
          dloc = Localisation.find_by_name part
          if !dloc
            raise Exception, "Localisation #{part} not found"
          end
          
          if !CodingRegionLocalisation.find_or_create_by_coding_region_id_and_localisation_id_and_localisation_method_id(
              code.id,
              dloc.id,
              method.id
            )
            raise Exception, "Could not create.."
          else 
            count += 1
          end
        end
      end
    end
    puts "Enumerated #{count} links"
  end
  
  # Count each group 
  def localisation_counts_inspect
    # Total counts
    Localisation.count(:group => :name, 
      :joins => :coding_regions,
      :order => 'count_all desc'
    ).each do |l|
      puts "#{l[1]}\t#{l[0]}"
    end
    
    # Counts for only a single localisation
    locs = Localisation.find(:all)
    locs.each do |loc|
      orfs = loc.get_individual_localisations
      puts "#{orfs.length}\t#{loc.name}"
    end
    
    puts
    puts "Unique tops"
    topings = {}
    CodingRegion.falciparum.all(
      :select => 'distinct(coding_regions.*)',
      :joins => {:expressed_localisations => :malaria_top_level_localisation}
    ).each do |code|
      next unless code.uniq_top?
      topings[code.tops[0].name] ||= 0
      topings[code.tops[0].name] += 1
    end
    topings.each do |loc, count|
      puts "#{loc}\t#{count}"
    end
    
    puts
    puts "Possibly not unique tops"
    topings = {}
    CodingRegion.falciparum.all(
      :select => 'distinct(coding_regions.*)',
      :joins => {:expressed_localisations => :malaria_top_level_localisation}
    ).each do |code|
      topings[code.tops[0].name] ||= 0
      topings[code.tops[0].name] += 1
    end
    topings.each do |loc, count|
      puts "#{loc}\t#{count}"
    end
  end  
  
  # Assumes that the vulgar file has already been created as per 
  # tiddlywiki:[[Re-annotating Winzeler]]
  def generate_winzeler_probe_map
    #Read in a single line of the file
    #    f = File.open("#{ENV['HOME']}/phd/winzeler/probesVtranscripts.vulgar")
    f = File.open("#{ENV['HOME']}/phd/winzeler/5.5/probesVtranscripts.vulgar")
    
    #    map_name = 'Winzeler 2003 PlasmoDB 5.4'
    map_name = 'Winzeler 2003 PlasmoDB 5.5'
    map = ProbeMap.find_or_create_by_name map_name
    map.destroy
    map = ProbeMap.find_or_create_by_name map_name
    
    while (line = f.gets)
      # skip blank lines
      if line === '' or 
          line.match 'Command line:' or
          line.match 'Hostname:' or 
          line.match 'completed exonerate analysis'
        next
      end
      
      # make sure it is really a vulgar file
      # vulgar: seq24259 0 25 + psu|PFC1125w 1425 1450 + 125 M 25 25
      splits = line.split ' '
      if splits[0] != 'vulgar:'
        raise Exception, "Unexpected line: #{line}"
      end
      
      seqname = splits[1]
      transcript_name = splits[5]
      
      seqname = seqname.sub 'seq',''
      tsplits = transcript_name.split '|'
      plasmodbid = tsplits[1]
      
      code = CodingRegion.ff(plasmodbid)
      if !code
        $stderr.puts "No coding region #{plasmodbid} found"
        next
      end
      
      ProbeMapEntry.create!(
        :coding_region_id => code.id,
        :probe_map_id => map.id,
        :probe_id => seqname
      )
    end
  end
  
  
  def old_winzeler_probe_map
    f = File.open("#{ENV['HOME']}/phd/data/falciparum/microarray/Winzeler2003/MalariaChipProbes.csv")
    
    count = 1
    
    map_name = 'Winzeler 2003 Original'
    map = ProbeMap.find_or_create_by_name map_name
    map.destroy
    map = ProbeMap.find_or_create_by_name map_name  
    
    while (line = f.gets)
      # skip blank lines
      if line === '' or 
          line.match 'Gene,X,Y,ProbeSequence'
        next
      end
      
      splits = line.split ','
      if splits.length != 4
        raise Exception, "Unexpected line: #{line}"
      end
      
      # Skip the non-specific probes
      if splits[3] == "\n"
        next
      end
      
      plasmodbid = splits[0]
      
      code = CodingRegion.find_by_name_or_alternate(plasmodbid)
      if !code
        $stderr.puts "No coding region #{plasmodbid} found"
        next
      end
      
      ProbeMapEntry.create!(
        :coding_region_id => code.id,
        :probe_map_id => map.id,
        :probe_id => count
      )
      
      count = count+1
    end
  end
  
  def print_gene_lists
    PlasmodbGeneList.find(:all).each do |list|
      puts "#{list.plasmodb_gene_list_entries.length} #{list.description}"
    end    
  end
  
  
  def create_random_proto_gene_lists
    #        filenames = 
    #      ['/home/uyen/phd/data/falciparum/localisation/apicoplast.Stuart.20080215.txt',
    #      '/home/uyen/phd/data/falciparum/localisation/tRNASynthetases/apicoplast.Stuart.20080220.txt',
    #      '/home/uyen/phd/data/falciparum/localisation/tRNASynthetases/cytosolic.Stuart.20080220.txt',
    #      '/home/uyen/phd/data/falciparum/localisation/exportpred/exportPred10.txt',
    #      '/home/uyen/phd/data/falciparum/exportpred/exportome.csv'
    #    ]
    
    oldlist_names = ['exportome', 'apicoplast.Stuart.20080215']
    
    oldlist_names.each do |oldlist_name|
      oldlist = PlasmodbGeneList.find_by_description oldlist_name
      list = oldlist.plasmodb_gene_list_entries
      ids = []
    
      while ids.length < 100
        ids.push list[rand(list.length)].id
        ids.uniq!
      end
    
    
      newlist = PlasmodbGeneList.find_or_create_by_description(
        "#{oldlist_name} random 100"
      )
      PlasmodbGeneListEntry.destroy_all "plasmodb_gene_list_id=#{newlist.id}"
      ids.each do |id|
        code = PlasmodbGeneListEntry.find(id).coding_region
        PlasmodbGeneListEntry.create!(
          :plasmodb_gene_list_id => newlist.id,
          :coding_region_id => code.id
        )
      end
    end
  end
  
  # Take just the 3d7 derisi strain and determine using a nearest neighbour
  # approach what th
  def proto_pearson_correlation_loc_list
    
    exportome_data = Derisi20063d7Logmean.find(:all,
      :include => {
        :coding_region => {:plasmodb_gene_list_entries => :plasmodb_gene_list}
      },
      :conditions => "plasmodb_gene_lists.description = 'exportome random 100'"
    )
    
    puts PlasmodbGeneList.find_all_by_description_and_id(['exportome', 'apicoplast.Stuart.20080215'], 5).length
    
    #    apicoplast_data = Derisi20063d7Logmean.find(:all,  
    #      :include => {
    #        :coding_region => {:plasmodb_gene_list_entries => :plasmodb_gene_list}
    #      },
    #      :conditions => 
    #        "plasmodb_gene_list.description = 'apicoplast.Stuart.20080215 random 100'"
    #    )
    
    
    # For each of the exportome left out data, find the nearest neighbour
    # in each of the exportome_data and apicoplast_data
    puts exportome_data.length
  end
  
  def go_apicoplast_genes
    gem 'rsruby'
    require 'rsruby'
    
    r = RSRuby.instance
    r.eval_R('require(GO)')
    #    name = r.environmentName('GOCCOFFSPRING')
    children = r.call("get('GO:0020011', GOCCOFFSPRING)")
    p children
  end
  
  def print_nilushi_profiles
    lists = ['apicoplast.Stuart.20080220', 'cytosolic.Stuart.20080220']
    
    lists.each do |list|
      rioo = rio("../nilushi/#{list}.csv")
      l = PlasmodbGeneList.find_by_description(list,
        :include => {:plasmodb_gene_list_entries => {:coding_region => :derisi20063d7_logmeans}}
      )
      lines = []
      l.plasmodb_gene_list_entries.each do |entries|
        means = entries.coding_region.derisi20063d7_logmeans
        if means and means.length != 0
          lines.push means[0].timepoints.join(',')
          lines.push "\n"
        end
      end
      rioo < lines
    end
  end
  
  def print_northern_profile
    hits = CodingRegion.find_by_string_id('PF10_0149', :include => :derisi20063d7_logmeans)
    p hits
    lines = []
    hits.derisi20063d7_logmeans.each do |d|
      lines.push d.timepoints.join(',')
      lines.push "\n"
    end
    rio('../nilushi/PF10_0149.csv') < lines
  end
  
  def orthomcl_to_database
    orthomcl_groups_to_database
    upload_orthomcl_official_sequences
  end
  
  
  # Load the data from the groups file alone - upload all genes and groups
  # in the process
  def orthomcl_groups_to_database(filename="#{DATA_DIR}/orthomcl/v2/groups_orthomcl-2.txt")
    #    OrthomclGene.delete_all 
    #    OrthomclGroup.delete_all 
    #    OrthomclGeneCodingRegion.delete_all
    
    r = File.open(filename)
    
    run = OrthomclRun.official_run_v2
    
    r.each do |line|
      if !line or line === ''
        next
      end
      
      splits1 = line.split(': ')
      if splits1.length != 2
        raise Exception, "Bad line: #{line}"
      end
      
      g = OrthomclGroup.find_or_create_by_orthomcl_name(splits1[0])
      
      splits2 = splits1[1].split(' ')
      if splits2.length < 1
        raise Exception, "Bad line (2): #{line}"
      end
      splits2.each do |name|
        og = OrthomclGene.find_or_create_by_orthomcl_name(name)
        OrthomclGeneOrthomclGroupOrthomclRun.find_or_create_by_orthomcl_gene_id_and_orthomcl_group_id_and_orthomcl_run_id(
          og.id, g.id, run.id
        )
      end
    end
  end
  
  # Load the data from the groups file alone - upload all genes and groups
  # in the process
  def orthomcl_groups_to_database_test
    OrthomclGene.delete_all 
    OrthomclGroup.delete_all 
    
    r = File.open("/tmp/2")
    
    r.each do |line|
      if !line or line === ''
        next
      end
      
      splits1 = line.split(': ')
      if splits1.length != 2
        raise Exception, "Bad line: #{line}"
      end
      
      puts splits1[0]
      g = OrthomclGroup.find_or_create_by_version_and_orthomcl_name(2, splits1[0])
      
      splits2 = splits1[1].split(' ')
      if splits2.length < 1
        raise Exception, "Bad line (2): #{line}"
      end
      splits2.each do |name|
        OrthomclGene.find_or_create_by_orthomcl_group_id_and_orthomcl_name(g.id, name)
        puts name
      end
      
      puts
    end
  end
  
  def map_plasmodb_ids
    $stdin.each do |line|
      p = CodingRegion.find_by_name_or_alternate(line.strip)
      if !p
        puts 'nil'
      else
        puts p.string_id
      end
    end
  end
  
  
  def upload_suba
    method = LocalisationMethod.find_or_create_by_description('SUBA All Predictors')
    method_annotation =LocalisationMethod.find_or_create_by_description( 'SUBA Annotation')
    species = Species.find_or_create_by_name('Arabidopsis')
    scaffold = Scaffold.find_or_create_by_name_and_species_id(
      'Arabidopsis All',
      species.id
    )
    
    # need to skip the first header line
    first = true
    
    CSV.open("#{DATA_DIR}/arabidopsis/localisation/suba_suba2.noquotes.csv", 'r', "\t") do |row|
      
      if first or row === ''
        first = false
        next
      end
      
      # Don't downcase - I'll follow the TAIR conventions
      arab_id = row[0].upcase
      
      gene = Gene.find_or_create_by_name_and_scaffold_id(
        arab_id,
        scaffold.id
      )
        
      code = CodingRegion.find_or_create_by_gene_id_and_string_id_and_orientation(
        gene.id,
        arab_id,
        '0'
      )
      

      
      #all predictors is the 21st column
      locs = row[21]
      if locs and locs != ''
        locs = locs.split(',')
        
        locs.each do |l|
          loc_entry = Localisation.find_or_create_by_name(l)
          CodingRegionLocalisation.find_or_create_by_coding_region_id_and_localisation_id_and_localisation_method_id(
            code.id,
            loc_entry.id,
            method.id
          )
        end
      end
      

      
            
      #23 to 27 is all the experimental ones - I'll trust only these
      (24..28).each do |col|
        locs = row[col]
        if locs and locs != ''
          locs = locs.split(';')
        
          locs.each do |l|
            reals = l.split(':')
            if reals.length != 2 and reals.length !=3
              raise Exception, "Badly handled line: #{l}, #{locs}"
            end
            loc_entry = Localisation.find_or_create_by_name(reals[0])
            CodingRegionLocalisation.find_or_create_by_coding_region_id_and_localisation_id_and_localisation_method_id(
              code.id,
              loc_entry.id,
              method_annotation.id
            )
          end
        end
      end
      
    end
  end
  
  
  # See if the arabidopsis gene locations help if I put them through orthomcl
  def florian_arabidopsis
    PlasmodbGeneListEntry.find(:all, 
      :include => [
        :plasmodb_gene_list,
        {
          :coding_region => 
            [
            {:orthomcl_genes => {:orthomcl_group => :orthomcl_run}},
            :localisations
          ]
        }
      ],
      #      :conditions => "plasmodb_gene_lists.description='HaemSynth20080423'"+
      :conditions => "plasmodb_gene_lists.description='apicoplast.Stuart.20080215'"+
        #      :conditions => "plasmodb_gene_lists.description='cytosolic.Stuart.20080220'"+
      " and orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}'"
    ).each do |entry|
      
      code = entry.coding_region
      print "#{code.string_id}\t"
      
      if code.annotation
        print "#{code.annotation.annotation}\t"
      end
      
      ogenes = code.orthomcl_genes
      if !ogenes or ogenes.length == 0
        puts
        next
      elsif ogenes.length != 1
        puts "Multiple orthomcl groups!"                    
        next
        #        raise Exception, "wierd"
      end
      group = ogenes[0].orthomcl_group
      print "#{group.orthomcl_name}\t"
      
      genes = OrthomclGene.find(:all,
        :conditions => "orthomcl_group_id=#{group.id} and orthomcl_name like 'ath|%'"
      )
      
      genes.each do |ath|
        ath.coding_regions.each do |code|
          locs = code.localisations
          if locs
            print "#{locs.collect{|loc| loc.name}.join(',')}\t"
          end
        end
      end
      # For each of the arabidopsis genes in the group
      
      locs = Localisation.find(:all,
        :include => {:coding_region_localisations => :localisation_method},
        :conditions => "coding_region_id=#{entry.coding_region.id} and localisation_methods.description='SUBA Annotation'"
      )
      
      if locs
        print locs.collect do |l| l.name end
      end
      
      puts
    end
  end
  
  
  def vivax_to_database
    #apidb_species_to_database(Species.vivax_name, "#{DATA_DIR}/vivax/genome/plasmodb/5.4/Pvivax_Salvador1_plasmoDB-5.4.gff")
    apidb_species_to_database(Species.vivax_name, "#{DATA_DIR}/vivax/genome/plasmodb/5.5/Pvivax_PlasmoDB-5.5.gff")
  end
  
  
  def theileria_parva_gene_aliases
    sp = Species.find_or_create_by_name(Species.theileria_parva_name)
    scaff = Scaffold.find_or_create_by_species_id_and_name(sp.id, "Theiliera dummy")
    
    CodingRegionAlternateStringId.find(:all,
      :include => {:coding_region => {:gene => {:scaffold => :species}}},
      :conditions => "species.name='#{Species.theileria_parva_name}'"
    ).each do |s| 
      s.destroy
    end
    
    # Upload all the gene aliases to the database
    CSV.open("#{DATA_DIR}/Theileria parva/Theileria parva genes.csv", 'r', "\t") do |row|
      # First col is the TIGR type ID, second and third are the normal Ids. I'll use 2nd
      g = Gene.find_or_create_by_name_and_scaffold_id(row[1], scaff.id)
      code = CodingRegion.find_or_create_by_string_id_and_orientation_and_gene_id(
        row[1], 
        CodingRegion.unknown_orientation_char, 
        g.id
      )
      name = row[0].gsub('>','').strip
      CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(
        code.id,
        name
      )
    end
  end
  
  def seven_species_orthomcl_upload
    Babesia.new.seven_species_orthomcl_upload
  end
  
  
    
  def genes_to_orthomcl_groups
    $stdin.each do |line|
      l = line.strip
      print "#{l}\t"
      
      code = CodingRegion.find_by_name_or_alternate(l)
      if !code
        print nil
        next
      end
      
      groups = OrthomclGroup.find(:all,
        :include => [{:orthomcl_genes => :coding_regions}, :orthomcl_run],
        :conditions => "orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}' and coding_regions.id=#{code.id}"
      )
      
      if groups.length == 1
        print groups[0].orthomcl_name
      elsif groups.length > 1
        $stderr.puts "Database error: #{groups.length} OrthoMCL groups found for official - there should be one max"  
        print nil
      end
      print "\t"
      
      #And again for the seven species one
      groups = OrthomclGroup.find(:all,
        :include => [{:orthomcl_genes => :coding_regions}, :orthomcl_run],
        :conditions => "orthomcl_runs.name='Seven species for Babesia' and coding_regions.id=#{code.id}"
      )
      
      if groups.length == 1
        print groups[0].orthomcl_name
      elsif groups.length > 1
        $stderr.puts "Database error: #{groups.length} OrthoMCL groups found for 7species - there should be one max"  
        print nil
      end
      puts
    end
  end
  
  # Taking all the babesia genes, classify them in their confidences of being
  # in the apicoplast, given the other genes we know of
  def babesia_confidence_assignation
    puts "Gene ID\tHigh Confidence Orthologues\tLow Confidence Orthologues\tNumber High Conf Orthologues\tNumber Low Conf Orthologues\tApicoplast Targetting Confidence"
    
    CodingRegion.find(:all,
      :conditions => "string_id like 'BB%'",
      :include => {:orthomcl_genes => :orthomcl_group}
    ).each do |bab|
      
      
      # Find the orthomcl group, and explore each of the members
      ohs = bab.orthomcl_genes
      if ohs.length != 1
        $stderr.puts "Wrong number of ortho groups for babesia: #{ohs.length}"
      else
        ogene = ohs[0]
        
        # Print out high confidence orthologues
        hitsHigh = CodingRegion.find(:all,
          :include => [
            {:plasmodb_gene_list_entries => :plasmodb_gene_list},
            {:orthomcl_genes => :orthomcl_group}
          ],
          :conditions => 
            "plasmodb_gene_lists.description='ApicoplastMultiSpeciesHighConfidence20080422'"+
            " and orthomcl_groups.id=#{ogene.orthomcl_group.id}"
        )
        
          
        hitsLow = CodingRegion.find(:all,
          :include => [
            {:plasmodb_gene_list_entries => :plasmodb_gene_list},
            {:orthomcl_genes => :orthomcl_group}
          ],
          :conditions => 
            "plasmodb_gene_lists.description='ApicoplastMultiSpeciesLowConfidence20080422'"+
            " and orthomcl_groups.id=#{ogene.orthomcl_group.id}"
        )
        
        if hitsHigh.length >0 or hitsLow.length > 0
          print "#{bab.string_id}\t"
          print "#{hitsHigh.collect{|h| h.string_id}.join(',')}\t"
          print "#{hitsLow.collect{|h| h.string_id}.join(',')}\t"
          print "#{hitsHigh.length}\t"
          print "#{hitsLow.length}\t"
          if hitsHigh.length > 0
            print 'High'
          elsif hitsLow.length > 1
            print 'Medium'
          elsif hitsLow.length > 0
            print 'Low'
          end
          puts
        end
        
       
      end
    end
  end
  
  
  def seven_species_summarise_orthologue_groups
    # For each group, summarise the species involved.
    OrthomclGroup.find(:all,
      :include => [
        :orthomcl_run, 
        {:orthomcl_genes => {:coding_regions => {:gene => {:scaffold => :species}}}}],
      :conditions => "orthomcl_runs.name='Seven species for Babesia'"
    ).each do |orthomcl_group|
      print "#{orthomcl_group.orthomcl_name}\t"
      
      # For each gene, print for each of the species
      spec_genes = []
      orthomcl_group.orthomcl_genes.each do |orthomcl_gene|
        codes = orthomcl_gene.coding_regions
        if codes.length != 1
          $stderr.puts "Bad number of coding regions for #{orthomcl_gene.orthomcl_name}: #{codes.length}. Data problems.."
          next
        end
        
        code = codes[0]
        spid = code.gene.scaffold.species.id
        if !spec_genes[spid]
          spec_genes[spid] = [code.string_id]
        else
          spec_genes[spid].push code.string_id
        end
      end
      
      spec_genes.each do |ar|
        if ar
          print "#{ar.join(',')}\t#{ar.length}\t"
        else
          print "\t0\t"
        end
      end
      
      puts
    end
  end
  
  
  def seven_species_non_babesia
    # for each coding region in the high conf or low conf list, 
    # if it has no babesia gene in it, add it to the list of groups to print out
    groups = {}
    CodingRegion.find(:all,
      :include => [
        {:plasmodb_gene_list_entries => :plasmodb_gene_list}
      ],
      :conditions => "plasmodb_gene_lists.description='ApicoplastMultiSpeciesLowConfidence20080422'"
    ).each do |code|
      
      ogroups = OrthomclGroup.find(:all,
        :include => [
          :orthomcl_run,
          {:orthomcl_genes => :coding_regions}
        ],
        :conditions => "coding_regions.id=#{code.id} and orthomcl_runs.name='Seven species for Babesia'"
      )
      if ogroups.length == 0
        #        $stderr.puts "Gene without orthologue group: #{code.string_id}"
        next
      elsif ogroups.length != 1
        raise Exception, "Data error"
      end
      
      add = true
      orthgroup = ogroups[0]
      OrthomclGene.find(:all,
        :include => {:coding_regions => {:gene => {:scaffold => :species}}},
        :conditions => "orthomcl_group_id=#{orthgroup.id}"
      ).each do |ogene|
        #        p Species.babesia_bovis_name
        if ogene.coding_regions.length != 1
          $stderr.puts "Usual data error: #{ogene.orthomcl_name}"
          next
        end
        #        p ogene.coding_regions[0].gene.scaffold.species.name
        if ogene.coding_regions[0].gene.scaffold.species.name===Species.babesia_bovis_name
          #          puts "#{orthgroup.orthomcl_name} failed on #{ogene.coding_regions[0].string_id}"
          add = false
        end
      end
      
      if add
        groups[orthgroup] = true
      end
    end
    
    
    groups.keys.each do |group|
      print "#{group.orthomcl_name}"
      
      OrthomclGene.find(:all,
        :include => :coding_regions,
        :conditions => "orthomcl_group_id=#{group.id}"
      ).each do |ogene|
        if ogene.coding_regions.length != 1
          $stderr.puts "usual data error: #{ogene.orthomcl_name}"
          next
        end
        print ",#{ogene.coding_regions[0].string_id}"
      end
      puts
    end
  end
  
  
  def crypto_name_fix
    count = 0
    
    CodingRegion.find(:all,
      :conditions => "string_id like 'Cryptosporidium_%'"
    ).each do |code|
      # eg. Cryptosporidium_hominis|AAEL01000065|Chro.20163|Annotation|GenBank|(protein
      ems = code.string_id.match('Cryptosporidium_.*?\|.*?\|(.*)\|Annotation\|GenBank|\(protein')
      if !ems
        raise Exception, code.string_id
      else
        code.string_id = ems[1]
        code.save!
        count += 1
      end
    end
    
    puts "Fixed #{count} annotations."
  end
  
  
  def apicoplast_no_orthologues
    lists = [
      'ApicoplastMultiSpeciesHighConfidence20080422',
      'ApicoplastMultiSpeciesLowConfidence20080422'
    ]
    
    puts "Apicoplast Targetted Protein ID\tdebug\tAnnotation\tofficial orthomcl v2 group brethren\t!!! official v2 brethren we predict as apicoplast targetted."
    
    lists.each do |list|
      puts list
      
      # Find all the genes in the apicoplast targetted list that have no orthologues
      CodingRegion.find(:all,
        :include => {:plasmodb_gene_list_entries => :plasmodb_gene_list},
        :conditions => "plasmodb_gene_lists.description='#{list}'"
      ).each do |code|
        ogenes = OrthomclGene.find(:all,
          :include => [
            :coding_regions,
            {:orthomcl_group => :orthomcl_run}
          ],
          :conditions => "orthomcl_runs.name='Seven species for Babesia' and coding_regions.id=#{code.id}"
        )
      
        if ogenes.length != 1
          print "#{code.string_id}\t#{ogenes.length}\t#{code.annotation.annotation}\t"
          
          # print the members of the official orthologue group for comparison
          ogroups = OrthomclGroup.find(:all,
            :include => [
              {:orthomcl_genes => :coding_regions},
              :orthomcl_run
            ],
            :conditions => "orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}' and coding_regions.id=#{code.id}"
          )
          
          if ogroups.length == 1
            genes = OrthomclGene.find_all_by_orthomcl_group_id(ogroups[0].id)
            
            print genes.collect{|g| g.orthomcl_name}.join(',')
            
            # If any of these unassociated genes are apicoplast ones, hmmm
            hits = CodingRegion.find(:all,
              :include => [
                :orthomcl_genes,
                :plasmodb_gene_lists
              ],
              :conditions => "coding_regions.id != #{code.id} and orthomcl_group_id=#{ogroups[0].id} and (plasmodb_gene_lists.description='#{lists[0]}' or plasmodb_gene_lists.description='#{lists[1]}')"
            )
              
            if hits.length > 0
              print "\t!!! #{hits.collect{|h| h.string_id}.join(",")}"
            end

          else
            print ogroups.length
          end
          
          puts
        end
      end
      
      puts #after each list
    end
  end
  
  
  
  def upload_apicoplast_annotations
    # Fill the annotation table with the apicoplast targetting annotations
    first = true
    CSV.open("#{PHD_DIR}/babesiaApicoplastReAnnotation/annotation1/vivaxapicoplast_ISS_and_IEA.csv", 'r', "\t") do |row|
      if first
        first = false
        next
      end
      
      Annotation.create_with_gene_id(row[0], row[2])
    end
    
    first = true
    CSV.open("#{PHD_DIR}/babesiaApicoplastReAnnotation/annotation1/Theileria parva apicoplast.csv", 'r', "\t") do |row|
      if first
        first = false
        next
      end
      
      Annotation.create_with_gene_id(row[0], row[1])
    end
    
    first = true
    CSV.open("#{PHD_DIR}/babesiaApicoplastReAnnotation/annotation1/394 falcip apicoplast.csv", 'r', "\t") do |row|
      if first
        first = false
        next
      end
      
      Annotation.create_with_gene_id(row[0], row[2])
    end
  end
  
  # Print out all the gene aliases and string_ids for a given gene or alias,
  # Mainly for quick use on the command line
  def gene_aliases
    $stdin.each do |line|
      p = CodingRegion.find_by_name_or_alternate(line.strip)
      if !p
        puts 'nil'
      else
        print "#{p.string_id}";
        aliases = p.coding_region_alternate_string_ids
        if aliases
          aliases.each do |a|
            print " #{a.name}"
          end
        end
      end
    end
  end
  
  
  def upload_hardy
    puts "GO"
    go_to_database
    puts "Falciparum"
    falciparum_to_database
    puts "Vivax"
    vivax_to_database # this fails with exception because of a known bug in my genes gff parser. It is OK, though - it should validate at least
    #    puts "Theileria"
    #    theileria_parva_gene_aliases
    #    puts "Seven species orthomcl"
    #    seven_species_orthomcl_upload
    #    
    #    puts "Big orthomcl"
    #    orthomcl_groups_to_database

    #    puts "gene lists"
    #    upload_gene_lists #several problematic hits, especially in exportpred data

    #    puts "Fixing crypto names"
    #    crypto_name_fix
    
    #    puts "Theileria fasta"
    #    upload_theileria_fasta
    
    #    puts 'Babesia fasta'
    #    babesia_to_database
    #    puts 'Falciparum fasta'
    #    falciparum_fasta_to_database
    #    puts 'Vivax fasta'
    #    vivax_fasta_to_database
    
    #    
    #    puts 'crypto fasta'
    #    crypto_fasta_to_database

    #    puts "Big orthomcl linking"
    #    link_orthomcl_and_coding_regions
  end
  
  
  # upload the fasta sequences from falciparum file to the database
  def falciparum_fasta_to_database
    #    fa = ApiDbFasta.new.load("#{DATA_DIR}/falciparum/genome/plasmodb/5.4/PfalciparumAnnotatedProteins_plasmoDB-5.4.fasta")
    fa = ApiDbFasta5p5.new.load("#{DATA_DIR}/falciparum/genome/plasmodb/5.5/PfalciparumAnnotatedProteins_PlasmoDB-5.5.fasta")
    sp = Species.find_by_name(Species.falciparum_name)
    upload_fasta_general!(fa, sp)
  end
  
  # upload the fasta sequences from falciparum file to the database
  def vivax_fasta_to_database
    fa = ApiDbVivaxFasta5p5.new.load("#{DATA_DIR}/vivax/genome/plasmodb/5.5/PvivaxAnnotatedProteins_PlasmoDB-5.5.fasta")
    sp = Species.find_by_name(Species.vivax_name)
    upload_fasta_general!(fa, sp)
  end
  
  
  def crypto_fasta_to_database
    fa = CryptoDbFasta4p0.new.load("#{DATA_DIR}/Cryptosporidium parvum/genome/cryptoDB/4.0/CparvumAnnotatedProteins_CryptoDB-4.0.fasta")
    sp = Species.find_by_name(Species.cryptosporidium_parvum_name)
    upload_fasta_general(fa, sp)
    
    fa = CryptoDbFasta4p0.new.load("#{DATA_DIR}/Cryptosporidium hominis/genome/cryptoDB/4.0/ChominisAnnotatedProteins_CryptoDB-4.0.fasta")
    sp = Species.find_by_name(Species.cryptosporidium_hominis_name)
    upload_fasta_general(fa, sp)
  end
  
  
  def falciparum_transcripts_to_database
    fa = ApiDbFasta5p5.new.load("#{DATA_DIR}/falciparum/genome/plasmodb/5.5/PfalciparumAllTranscripts_PlasmoDB-5.5.fasta")
    sp = Species.find_by_name(Species.falciparum_name)
    upload_transcript_fasta_general!(fa, sp)
  end
    
    
  # Then our babesia high-confidence apicoplast set will be those proteins
  #that have
  #a)1 or more orthologues that are high-confidence pvi/pfa/tpa apicoplast
  #proteins or
  #b)2 or more orthologues that are low-confidence pvi/pfa/tpa apicoplast
  #proteins and have no crypto orthologues.
  def babesia_groups_no_crypto
    orthomcl_spreadsheet('Seven species for Babesia')
  end
  
  def babesia_groups_no_crypto_no_filter
    orthomcl_spreadsheet(OrthomclRun.seven_species_no_filtering_name)
  end
  
  def orthomcl_spreadsheet(orthomcl_run_name)
    
    headers = ['Name',
      'Orthologs with High Confidence',
      'Orthologs with Low Confidence',
      '# Orthologs with High Confidence',
      '# Orthologs with High Confidence',
      '# Crypto Orthologs',
      'Classification re crypto',
      'signal sequence from SignalP',
      SignalPResult.all_result_names,
      'High Conf Bl2seq Best Hit Evalues (!!! means no hits)',
      'Low Conf Bl2seq Best Hit Evalues (!!! means no hits)',
      'sequence',
      'orthologs in group',
      'Crypto orthologs in Official v2 group'
    ].flatten
    puts headers.join(',')
    #    puts "Name\tOrthologs with High Confidence\tOrthologs with Low Confidence\t# Orthologs with High Confidence\t# Orthologs with High Confidence\t# Crypto Orthologs\tClassification re crypto\tsignal sequence from SignalP\tnn Cmax from SignalP\tnn Cmax Position from SignalP\tsequence	orthologs in group"
    
    CodingRegion.find(:all,
      :conditions => "string_id like 'BB%' and orthomcl_runs.name='#{orthomcl_run_name}'",
      :include => {:orthomcl_genes => {:orthomcl_group => :orthomcl_run}}
    ).each do |bab|
      
      
      # Find the orthomcl group, and explore each of the members
      ohs = bab.orthomcl_genes
      if ohs.length != 1
        $stderr.puts "Wrong number of ortho groups for babesia: #{ohs.length}"
      else
        ogene = ohs[0]
        
        # Print out high confidence orthologues
        hitsHigh = CodingRegion.find(:all,
          :include => [
            {:plasmodb_gene_list_entries => :plasmodb_gene_list},
            {:orthomcl_genes => :orthomcl_group}
          ],
          :conditions => 
            "plasmodb_gene_lists.description='Pvi_Pfa_Tpa_HIGH_confid_set3'"+
            " and orthomcl_groups.id=#{ogene.orthomcl_group.id}"
        )
        
          
        hitsLow = CodingRegion.find(:all,
          :include => [
            {:plasmodb_gene_list_entries => :plasmodb_gene_list},
            {:orthomcl_genes => :orthomcl_group}
          ],
          :conditions => 
            "plasmodb_gene_lists.description='Pvi_Pfa_Tpa_LOWER_confid_set'"+
            " and orthomcl_groups.id=#{ogene.orthomcl_group.id}"
        )
        
        
        signal_prediction = SignalP.calculate_signal(bab.amino_acid_sequence.sequence)
        
        if hitsHigh.length >0 or hitsLow.length > 0
          
          orthologs = CodingRegion.find(:all,
            :include => [
              {:plasmodb_gene_list_entries => :plasmodb_gene_list},
              {:orthomcl_genes => :orthomcl_group}
            ],
            :conditions => 
              "orthomcl_groups.id=#{ogene.orthomcl_group.id}"
          )
          
          hasBadSpecies = []
          orthologs.each do |hit|
            if hit.gene.scaffold.species.name === 'Cryptosporidium parvum' or hit.gene.scaffold.species.name === 'Cryptosporidium hominis'
              hasBadSpecies.push hit
            end
          end
          
          results = [
            bab.string_id,
            hitsHigh.collect{|h| h.string_id}.join(' '),
            hitsLow.collect{|h| h.string_id}.join(' '),
            hitsHigh.length,
            hitsLow.length,
            hasBadSpecies.length,
          ]
          
          if hitsHigh.length > 0
            if hasBadSpecies
              results.push "HighCrypto"
            else
              results.push "HighNoCrypto"
            end
          elsif hitsLow.length >= 2
            if hasBadSpecies
              results.push "Low2Crypto"
            else
              results.push "Low2NoCrypto"
            end
          else
            if hasBadSpecies
              results.push "Low1Crypto"
            else
              results.push "Low1NoCrypto"
            end
          end
          
          results.push signal_prediction.signal?
          results.push signal_prediction.all_results
          
          # Push the e-values of the bl2seq against each of the hits in our apicoplast lists
          seq = bab.amino_acid_sequence
          
          evals = [' ']
          hitsHigh.each do |hit|
            evals.push hit.string_id
            ev = hit.amino_acid_sequence.blastp(seq)
            if ev.iterations.length == 0
              raise Exception, "No iterations. Huh?"
            elsif  ev.iterations[0].hits.length == 0
              evals.push '!!!'
            else
              evals.push ev.iterations[0].hits[0].evalue
            end
          end
          results.push evals.flatten.join(' ')
          
          evals = [' ']
          hitsLow.each do |hit|
            evals.push hit.string_id
            ev = hit.amino_acid_sequence.blastp(seq)
            if ev.iterations.length == 0
              raise Exception, "No iterations. Huh?"
            elsif  ev.iterations[0].hits.length == 0
              evals.push '!!!'
            else
              evals.push ev.iterations[0].hits[0].evalue
            end
          end
          results.push evals.flatten.join(' ')
          
          
          results.push bab.amino_acid_sequence.sequence
          results.push orthologs.collect{|h| h.string_id}.join(' ')
          
          # Print names of crypto groups in the orthomcl official version in the same group as our predictions
          our_hits = [hitsHigh,hitsLow].flatten
          
          groups = OrthomclGroup.find(:all,
            :include => [
              :orthomcl_run,
              {:orthomcl_genes =>:coding_regions},
            ],
            :conditions => "orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}'"+
              " and coding_regions.id in (#{our_hits.collect{|code| code.id}.join(',')})"
          )
          if !groups or groups.length == 0
            $stderr.puts "No group official found for: #{our_hits}"
          else
            codes = CodingRegion.find(:all,
              :include => {:orthomcl_genes => {:orthomcl_group => :orthomcl_run}},
              :conditions => 
                "(orthomcl_genes.orthomcl_name like 'cpa%' or orthomcl_genes.orthomcl_name like 'cho%')"+
                " and orthomcl_groups.id in (#{groups.collect{|g| g.id}.join(',')})"
            )
          end
          
          if codes and codes != []
            results.push codes.collect{|code| "#{code.string_id} == \"#{code.annotation.annotation.gsub(',',' comma ')}\"||||"}.join(' ')
          else
            results.push ' '
          end
          


          puts results.flatten.join(',')
          
        end
        
       
      end
    end
  end
  
  # upload babesia fasta files to the database
  def babesia_to_database
    AminoAcidSequence.delete_all
    
    # Assume there is only 1
    babScaff = Scaffold.find(:first,
      :include => :species,
      :conditions => "species.name='Babesia bovis'"
    )
    
    Bio::FlatFile.foreach("#{DATA_DIR}/bovis/genome/NCBI/BabesiaWGS.fasta_with_names") { |e| 
      codeHits = CodingRegion.find_all_by_string_id(e.entry_id)
      code = nil
      
      
      # Find or upload the correct coding region
      if codeHits.length > 1
        raise Exception, "Couldn't find gene: #{e.entry_id}: #{code}"
      elsif codeHits.length == 0
        g = Gene.find_or_create_by_name_and_scaffold_id(
          e.entry_id,
          babScaff.id
        )
        code = CodingRegion.find_or_create_by_string_id_and_gene_id_and_orientation(
          e.entry_id,
          g.id,
          CodingRegion.unknown_orientation_char
        )
      else
        code = codeHits[0]
      end
      
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
        code.id,
        e.seq
      )
      
      # Upload annotation if not done already
      defi = e.definition
      matches = defi.match('^(.+?)\|(.+)$')
      if !matches or !matches[2]
        raise Exception, "Unexpected definition line: #{defi}"
      else
        Annotation.find_or_create_by_coding_region_id_and_annotation(
          code.id,
          matches[2].strip
        )
      end
    }
    
  end
  

  
  # Print out all the babesia genes with signal sequences
  def signalps_from_gene_list(list_name)
    headers = ['Name','Signal Predicted']
    headers.push(SignalPResult.all_result_names)
    headers.flatten!
    puts headers.join(',')
    
    #    puts "Name\tSignal Predicted\tnn Cmax\tnn Cmax Position\t"
    AminoAcidSequence.find(:all,
      :include => {:coding_region => {:plasmodb_gene_list_entries => :plasmodb_gene_list}},
      :conditions => "plasmodb_gene_lists.description='#{list_name}'"
    ).each do |aa|
      result = SignalP.calculate_signal(aa.sequence)
      res = [
        aa.coding_region.string_id,
        result.signal?,
        result.all_results
      ]
      res.flatten!
      puts res.join(',')
      #      puts "#{aa.coding_region.string_id}\t#{result.signal?}\t#{result.nn_Cmax}\t#{result.nn_Cmax_position}\t"
    end
  end
  
  
  def signalps_from_official_orthomcl_list
    File.open("#{PHD_DIR}/babesiaApicoplastReAnnotation/annotation1/crypto_groups.sorted").each do |line|
      splits = line.split("\t")
      if splits.length != 2
        raise Exception, "Bad line encountered: #{line.strip}"
      end
      
      group_name = splits[0]
      codes = CodingRegion.find(:all,
        :include => [
          {:orthomcl_genes => {:orthomcl_group => :orthomcl_run}},
          :annotation,
          :amino_acid_sequence
        ],
        :conditions => "orthomcl_groups.orthomcl_name='#{group_name}'"+
          " and orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}'"+
          " and (orthomcl_genes.orthomcl_name like 'cpa%' or orthomcl_genes.orthomcl_name like 'cho%')"
      )
      
      # for each of the crypto genes in the group, print out the signalP
      toprint = [group_name]
      codes.each do |code|
        toprint.push code.string_id
        
        # add the annotation
        if code.annotation
          toprint.push code.annotation.annotation.gsub(/,/, ' comma')
        else
          raise Exception, "No annotation found for coding region #{code.string_id}"
        end
        
        # Find the sequence
        if code.amino_acid_sequence
          toprint.push code.amino_acid_sequence.sequence
          ss = SignalP.calculate_signal(code.amino_acid_sequence.sequence)
          toprint.push ss.all_results
        else
          raise Exception, "No sequence found for coding region #{code.string_id}"
        end
      end
      
      puts toprint.flatten.join(',')
      
      
    end
  end
  
  
  def upload_theileria_fasta
    t = TigrFasta.new
    fa = t.load("#{DATA_DIR}/Theileria annulata/TANN.GeneDB.pep")
    scaff = Scaffold.find(:first,
      :include => :species,
      :conditions => "species.name='Theileria annulata'"
    )
    upload_fasta_simplistic(fa, scaff)

    t = TigrFasta.new
    fa = t.load("#{DATA_DIR}/Theileria parva/TPA1.pep")
    scaff = Scaffold.find(:first,
      :include => :species,
      :conditions => "species.name='Theileria annulata'"
    )
    upload_fasta_simplistic(fa, scaff)
  end
  
  # Upload a fasta file in the simplistic manner
  def upload_fasta_simplistic(fa, scaff)
    while f = fa.next_entry
      code = CodingRegion.find_by_name_or_alternate(f.name)
      if !code
        g = Gene.find_or_create_by_scaffold_id_and_name(
          scaff.id,
          f.name
        )
        code = CodingRegion.find_or_create_by_string_id_and_gene_id_and_orientation(
          f.name,
          g.id,
          CodingRegion.unknown_orientation_char
        )
      end
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
        code.id,
        f.sequence
      )
      Annotation.find_or_create_by_coding_region_id_and_annotation(
        code.id,
        f.annotation
      )
    end
  end
  
  
  # Upload a fasta file by filling in scaffold, annotation, sequence
  # Accepts a block that takes the name from the fasta line and turns it into something more useful
  def upload_fasta_general(fa, species)
    while f = fa.next_entry
      name = f.name
      if block_given?
        name = yield f.name
      end
      code = CodingRegion.fs(name, species.name)
      if !code
        scaff = Scaffold.find_or_create_by_species_id_and_name(
          species.id,
          f.scaffold
        )
        g = Gene.find_or_create_by_scaffold_id_and_name(
          scaff.id,
          name
        )
        code = CodingRegion.find_or_create_by_string_id_and_gene_id(
          name,
          g.id
        )
      end
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
        code.id,
        f.sequence
      )
      Annotation.find_or_create_by_coding_region_id_and_annotation(
        code.id,
        f.annotation
      )
    end
  end
  
  # Upload a fasta file by filling in scaffold, annotation, sequence, but do not create coding regions, genes or scaffolds - assume they
  # already exist in the database, and throw an exception if that isn't the case.
  # Accepts a block that takes the name from the fasta line and turns it into something more useful - untested!
  def upload_fasta_general!(fa, species)
    while f = fa.next_entry
      name = f.name
      if block_given?
        name = yield f.name
      end
      code = CodingRegion.fs(name, species.name)
      raise Exception, "No coding region found to attach a sequence/annotation to: #{f.name}" if !code
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
        code.id,
        f.sequence
      )
      Annotation.find_or_create_by_coding_region_id_and_annotation(
        code.id,
        f.annotation
      )
    end
  end
  
  
  # Upload a transcript fasta file by filling in scaffold, annotation, sequence, but do not create coding regions, genes or scaffolds - assume they
  # already exist in the database, and throw an exception if that isn't the case.
  # Accepts a block that takes the name from the fasta line and turns it into something more useful - untested!
  def upload_transcript_fasta_general!(fa, species)
    while f = fa.next_entry
      name = f.name
      if block_given?
        name = yield f.name
      end
      code = CodingRegion.fs(name, species.name)
      unless code
        $stderr.puts "No coding region found to attach a sequence/annotation to: #{f.name}. Ignored."
        next
      end
      TranscriptSequence.find_or_create_by_coding_region_id_and_sequence(
        code.id,
        f.sequence
      )
    end
  end
  
  def seven_species_no_filter_orthomcl_upload
    run = OrthomclRun.find_or_create_by_name(OrthomclRun.seven_species_no_filtering_name)
    
    File.open("#{PHD_DIR}/babesiaApicoplastReAnnotation/Apr_29/all_orthomcl.out").each do |groupline|
      splits = groupline.split("\t")
      
      if splits.length != 2
        raise Exception, "Badly parsed line"
      end
      
      # eg. 'ORTHOMCL0(161 genes,1 taxa):\t'
      matches = splits[0].match('(ORTHOMCL\d+)\(.*')
      group = OrthomclGroup.find_or_create_by_orthomcl_name_and_orthomcl_run_id(
        matches[1],
        run.id
      )
      
      splits[1].split(' ').each do |ogene|
        # eg. TA02955(TANN.GeneDB.pep)
        matches = ogene.match('^(.+)\((.*)\)$')
        if !matches
          raise Exception, "Badly parsed gene: '#{ogene}'"
        end
        
        # Create the gene
        orthomcl_gene = OrthomclGene.find_or_create_by_orthomcl_name_and_orthomcl_group_id(
          matches[1],
          group.id
        )
        
        
        # Join it up with the rest of the database
        
        # Assumes the data is already in the database, and falls over if it is not.
        code_name = nil
        
        case matches[2]
        when 'BabesiaWGS'
          code_name = matches[1]
        when 'TANN.GeneDB.pep'
          code_name = matches[1]
        when 'ChominisAnnotatedProtein.fsa'
          ems = matches[1].match('Cryptosporidium_.*?\|.*?\|(.*)\|Annotation\|GenBank|\(protein')
          if !ems
            raise Exception, "Unexpected gene name: #{matches[1]}"
          end
          code_name = ems[1]
        when 'CparvumAnnotatedProtein.fsa'
          #eg. Cryptosporidium_parvum|AAEE01000005|cgd2_3950|Annotation|GenBank|(protein
          ems = matches[1].match('Cryptosporidium_parvum\|.*?\|(.+?)\|Annotation\|.+\|\(protein')
          if !ems
            raise Exception, "Badly handled crypto: #{matches[1]}"
          end
          code_name = ems[1]
        when 'PvivaxAnnotatedProteins_plasmoDB-5.2'
          ems = matches[1].match('Plasmodium_vivax.*?\|.*?\|(.*)\|Pv')
          code_name = ems[1]
        when 'TPA1.pep'
          code_name = matches[1]
        else
          if matches[1].match('^Plasmodium_falciparum_3D7')
            ems = matches[1].match('Plasmodium_falciparum_3D7\|.*?\|(.*)\|Pf')
            code_name = ems[1]
          else
            raise Exception, "Didn't recognize source: '#{matches[2]}', #{matches}"
          end
        end
        
        code = CodingRegion.find_by_name_or_alternate(code_name)
        
        if !code
          # This can be legit, if a model is present in 5.2 but not 5.4 of orthoMCL
          $stderr.puts "Couldn't find gene model #{matches[0]}"
        else
          #Create the final gene entry in orthomcl
          OrthomclGeneCodingRegion.find_or_create_by_coding_region_id_and_orthomcl_gene_id(
            code.id,
            orthomcl_gene.id
          )
        end
      end
    end
  end
  
  
  def test
    hitsHigh = [CodingRegion.find_by_string_id('PFI0880c')]
    hitsLow = []
    results = []
    
    our_hits = [hitsHigh,hitsLow].flatten
    p our_hits
    groups = OrthomclGroup.find(:all,
      :include => [
        :orthomcl_run,
        {:orthomcl_genes =>:coding_regions}
      ],
      :conditions => "orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}'"+
        " and coding_regions.id in (#{our_hits.collect{|code| code.id}})"
    )
    p groups
    codes = CodingRegion.find(:all,
      :include => {:orthomcl_genes => {:orthomcl_group => :orthomcl_run}},
      :conditions => 
        "(orthomcl_genes.orthomcl_name like 'cpa%' or orthomcl_genes.orthomcl_name like 'cho%')"+
        " and orthomcl_groups.id in (#{groups.collect{|g| g.id}.join(',')})"
    )
    p codes
    if codes and codes != []
      results.push codes.collect{|code| code.string_id}.join(' ')
      results.push codes.collect{|code| code.annotation.annotation}.join(' ')
    else
      results.push ' ' 
      results.push ' '
    end
    p results
  end
  

  def high_confidence_falciparum_apicoplast
    PlasmodbGeneListEntry.find(:all,
      :include => [
        :plasmodb_gene_list,
        {:coding_region => {:gene => {:scaffold => :species}}}
      ],
      :conditions => "plasmodb_gene_lists.description='Pvi_Pfa_Tpa_HIGH_confid_set3' and species.name='#{Species.falciparum_name}'"
    ).each do |e|
      puts ">#{e.coding_region.string_id}"
      puts "#{e.coding_region.amino_acid_sequence.sequence}"
    end
  end
  
  def upload_orthomcl_official_sequences(fasta_filename="#{WORK_DIR}/Orthomcl/seqs_orthomcl-2.fasta")
    flat = Bio::FlatFile.open(Bio::FastaFormat, fasta_filename)
    
    run = OrthomclRun.official_run_v2
    
    flat.each do |seq|
      
      # Parse out the official ID
      line = seq.definition
      splits_space = line.split(' ')
      if splits_space.length < 3
        raise Exception, "Badly handled line because of spaces: #{line}"
      end
      orthomcl_id = splits_space[0]
      
      orthomcl_group_name = splits_space[2]
      ogene = nil
      
      if orthomcl_group_name == 'no_group'
        # Upload the gene as well now
        ogene = OrthomclGene.find_or_create_by_orthomcl_name(orthomcl_id)
        
        OrthomclGeneOrthomclGroupOrthomclRun.find_or_create_by_orthomcl_gene_id_and_orthomcl_run_id(
          ogene.id, run.id
        )
      else
        ogenes = OrthomclGene.official.find(:all,
          :conditions => {:orthomcl_genes => {:orthomcl_name => orthomcl_id}}
        )
        
        if ogenes.length != 1
          if ogenes.length == 0
            # Raise exceptions now because singlets are uploaded now - this gene apparently has a group
            raise Exception, "No gene found for #{line} when there should be"
          else
            raise Exception, "Too many genes found for #{orthomcl_id}"
          end
        end
        
        ogene = ogenes[0]
      end
      
      # find the annotation
      splits_bar = line.split('|')
      if splits_bar.length == 3
        annot = ''
      elsif splits_bar.length > 4
        annot = splits_bar[3..splits_bar.length-1].join('|')
      elsif splits_bar.length != 4
        raise Exception, "Bad number of bars (#{splits_bar.length}): #{line}"
      else
        annot = splits_bar[3].strip
      end
  
      OrthomclGeneOfficialData.find_or_create_by_orthomcl_gene_id_and_sequence_and_annotation(
        ogene.id,
        seq.aaseq,
        annot
      )
    end
  end
  
  def gene_list_descriptions(listname)
    
    puts [
      "Gene Name",
      "Annotation",
      "Sequence",
      "SignalP Prediction",
      SignalPResult.all_result_names
    ].join(',')
    
    lists = PlasmodbGeneList.find(:all,
      :include => {:plasmodb_gene_list_entries => {:coding_region => :annotation}},
      :conditions => "plasmodb_gene_lists.description='#{listname}'"
    )
    
    if lists.length !=1
      raise Exception, "Bad number of gene lists found: #{lists.length}"
    end
    
    lists[0].plasmodb_gene_list_entries.each do |entry|
      code = entry.coding_region
      stuff = [code.string_id]
      if code.annotation
        stuff.push "\"#{code.annotation.annotation}\""
      else
        stuff.push ''
      end
      
      if code.amino_acid_sequence
        stuff.push code.amino_acid_sequence.sequence
        
        signal_prediction = SignalP.calculate_signal(code.amino_acid_sequence.sequence)
        stuff.push signal_prediction.signal?
        stuff.push signal_prediction.all_results
      end
      
      puts stuff.join(',')
      
    end
  end
  
  # Creation of the spreadsheets for the collation of the babesia apicoplast finding mission
  def babesia_all_data
    f1 = File.open "babesiaAllGenesSheet1.csv", 'w'
    f2 = File.open "babesiaAllGenesSheet2.csv", 'w'

    
    
    # Read in the blast data
    # Gene	Min HSP Start Babesia	Corresponding Hit HSP Start	 Min HSP Start Hit	Start Site Difference	HitName	Desc	Len	Num_Hsps	Start_Query	Start_Hit	PerIden	HspLen	Evalue
    #BBOV_III000120	1	1	1	0	gi|168027491|ref|XP_001766263.1|	gi|162682477|gb|EDQ68895.1| predicted protein [Physcomitrella patens subsp. patens]	75	1	1	1	44	75	7.28E-011

    blast_hits = Hash.new
    headings = []
    
    first = true
    CSV.open("#{PHD_DIR}/babesiaApicoplastReAnnotation/blastcl3/parser/BabesiaVnr.blast.fixed.parsed.csv", 'r') do |row|
      if first
        first = false
        headings = row[1..row.length-1]
        next
      end
      blast_hits[row[0]] = row[1..row.length-1]
    end
    num_n_terminal_cols = headings.length
    
    
        
    # Print the titles
    f1.puts [
      'Gene',
      'Annotation',
      'N-terminal Extension',
      'Sequence'
    ].join(',')
    f2.puts [
      'Gene',
      'SignalP Result',
      SignalPResult.all_result_names,
      headings
    ].flatten.join(',')
    
    
    
    CodingRegion.find(:all,
      :include => [
        {:gene => {:scaffold => :species}},
        :annotation,
        :amino_acid_sequence
      ],
      :conditions => "species.name='#{Species.babesia_bovis_name}'"
    ).each do |code|
      # Print the easy stuff
      stuff1 = [
        code.string_id,
        "\"#{code.annotation.annotation}\""
      ]
      
      sigp = code.amino_acid_sequence.signal_p
      stuff2 = [
        code.string_id,
        sigp.signal?,
        sigp.all_results
      ]
      
      
      # Print the N-terminal extension data
      if blast_hits[code.string_id]
        data = blast_hits[code.string_id]
        stuff2.push data
        if data[1].to_i < 60 and
            data[0].to_i-data[1].to_i > 0
          stuff1.push data[0].to_i-data[1].to_i
        else
          stuff1.push ''
        end
      else
        num_n_terminal_cols.times {stuff2.push(nil)}
        stuff1.push ''
      end
      
      stuff1.push code.amino_acid_sequence.sequence
      
      # Output to file
      f1.puts stuff1.flatten.join(',')
      f2.puts stuff2.flatten.join(',')
    end
    
    f1.close
    f2.close
  end
  
  
  def yeast_gfp_cellcycle_overlap
    method = LocalisationMethod.find_by_description LocalisationMethod.yeast_gfp_description
    
    puts CodingRegion.count(
      :include =>[
        :coding_region_localisations,
        {:plasmodb_gene_list_entries => :plasmodb_gene_list}
      ],
      :conditions => "plasmodb_gene_lists.description='Yeast Cell Cycle From GO' and "+
        "coding_region_localisations.localisation_method_id=#{method.id}"
    )
  end
  
  
  
  def upload_yeast_cellcycle_alphaarrest
    microarray = Microarray.find_or_create_by_description Microarray.yeast_alpha_arrest_name
    
    
          
    #eg.
    #	cln3-1	cln3-2	clb	clb2-2	clb2-1	alpha	alpha0	alpha7	alpha14	alpha21	alpha28	alpha35	alpha42	alpha49	alpha56	alpha63	alpha70	alpha77	alpha84	alpha91	alpha98	alpha105	alpha112	alpha119	cdc15	cdc15_10	cdc15_30	cdc15_50	cdc15_70	cdc15_80	cdc15_90	cdc15_100	cdc15_110	cdc15_120	cdc15_130	cdc15_140	cdc15_150	cdc15_160	cdc15_170	cdc15_180	cdc15_190	cdc15_200	cdc15_210	cdc15_220	cdc15_230	cdc15_240	cdc15_250	cdc15_270	cdc15_290	cdc28	cdc28_0	cdc28_10	cdc28_20	cdc28_30	cdc28_40	cdc28_50	cdc28_60	cdc28_70	cdc28_80	cdc28_90	cdc28_100	cdc28_110	cdc28_120	cdc28_130	cdc28_140	cdc28_150	cdc28_160	elu	elu0	elu30	elu60	elu90	elu120	elu150	elu180	elu210	elu240	elu270	elu300	elu330	elu360	elu390
    #YAL001C	0.15			-0.22	0.07		-0.15	-0.15	-0.21	0.17	-0.42	-0.44	-0.15	0.24	-0.1		0.18	0.42	-0.25	-0.01	-0.13	0.77	-0.21	0.43		-0.16	0.09	-0.23	0.03	-0.04	-0.12	-0.28	-0.44	-0.09	0.12	0.06	-0.04	0.31	0.59	0.34	-0.28	-0.09	-0.44	0.31	0.03	0.57	0	0.02	-0.26		-0.19	-0.77	-0.17	-0.19	0.13	-0.36	-0.55	-0.07	-0.01	0.03	0.27	0.49	0.85	0.66	-0.24	0.03	0.09		0.3	-0.12	0.24	0.18	-0.24	0.11	-0.12	0.37	0.07	-0.09	-0.32	0.04	-0.48	0.04
    alpha_cols = 7..24
    orf_name_col = 0
    timepoints = []
    
    first = true
    
    CSV.open("#{DATA_DIR}/yeast/microarray/cellcycle/combined.csv", 'r', "\t") do |row|
      if first
        #        p row
        #        p row[alpha_cols]
        timepoints = row[alpha_cols].collect do |name|
          #          p name
          #          return
          MicroarrayTimepoint.find_or_create_by_microarray_id_and_name(
            microarray.id,
            name
          )
        end
        
        first = false
        next
      end
      
      # find the coding regions
      orf_name = row[orf_name_col]
      code = CodingRegion.find_by_name_or_alternate(orf_name)
      if !code
        $stderr.puts "No coding region #{orf_name} found"
        next
      end

      # Normal Column. Add the data
      alpha_cols.each do |i|
        cell = row[i]
        value = cell
        if value
          t = timepoints[i-alpha_cols.begin]
          
          if MicroarrayMeasurement.find_by_microarray_timepoint_id_and_measurement_and_coding_region_id(
              t.id,
              value,
              code.id
            )
            next #ignore ones already uploaded.
          end
          
          if MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(
              code.id,
              t.id
            )
            $stderr.puts "A second coding region was found for #{code.string_id}: orf_name. Merged gene model? Newest one ignored"
            next
          end
          MicroarrayMeasurement.find_or_create_by_microarray_timepoint_id_and_measurement_and_coding_region_id(
            t.id,
            value,
            code.id
          )
        end
      end
    end
  end
  
  
  # Print out all the microarray data for coding regions that have A) GFP data and B) microarray data and C) are included in the yeast cellcycle as given by GO
  def yeast_gfp_cellcycle_microarray(multiple_locations_boolean)
    localisation_measurements = Hash.new
    
    codes = CodingRegion.find(:all,
      :include => [
        {:coding_region_localisations => [
            :localisation_method,
            :localisation
          ]},
        :plasmodb_gene_lists,
        {:microarray_measurements => {:microarray_timepoint => :microarray}},
      ],
      :conditions => "microarrays.description='#{Microarray.yeast_alpha_arrest_name}'"+
        " and localisation_methods.description='#{LocalisationMethod.yeast_gfp_description}'"+
        " and plasmodb_gene_lists.description='Spellman Cell Cycle Genes'"
    )
    
    codes.each do |code|
      locs = code.localisations
      # discard multiple locations for the moment
      if locs.length < 1
        raise Exception, "No lcoalisations. How can that be?"
      end
      
      # Skip multiple locations if required
      if !multiple_locations_boolean and locs.length > 1
        next
      end
      
      locs.each do |loc|
        key = loc.name
        if !localisation_measurements[key]
          localisation_measurements[key] = []
        end
        
        localisation_measurements[key].push [
          code.string_id,
          code.microarray_measurements.max{|a,b| a.measurement <=> b.measurement}.microarray_timepoint.name.gsub('alpha','')
        ]
      end
    end
    
    localisation_measurements.keys.each do |loc_key|
      localisation_measurements[loc_key].each do |entry|
        puts "#{entry[0]}\t#{loc_key}\t#{entry[1..entry.length-1].join("\t")}"
      end
    end
  end
  
  
  # upload the derisi data to my second microarray database implementation
  def derisi_microarray_to_database2
    microarray = Microarray.find_or_create_by_description Microarray.derisi_2006_3D7_default
    
    microarray.microarray_timepoints.each do |t|
      # destroys timepoint and all measurements as well
      t.destroy
    end
          
    alpha_cols = 2..63
    orf_name_col = 1
    timepoints = []
    
    first = true
    
    CSV.open("#{DATA_DIR}/falciparum/microarray/DeRisi2006/S03_3D7_QC.tab", 'r', "\t") do |row|
      if first
        timepoints = row[alpha_cols].collect do |name|
          MicroarrayTimepoint.find_or_create_by_microarray_id_and_name(
            microarray.id,
            name
          )
        end
        
        first = false
        next
      end
      
      # find the coding regions
      orf_name = row[orf_name_col]
      code = CodingRegion.falciparum.find_by_name_or_alternate(orf_name)
      if !code
        $stderr.puts "No coding region #{orf_name} found"
        next
      end

      # Normal Column. Add the data
      alpha_cols.each do |i|
        cell = row[i]
        value = cell
        if value
          t = timepoints[i-alpha_cols.begin]
          
          # Uploading mulitple at one time is fine. Assume the whole dataset is being uploaded at once here
          
          # There is actually a small bug here. It is theoretically possible that you can have the same region be measured twice.
          MicroarrayMeasurement.create!(
            :microarray_timepoint_id => t.id,
            :measurement => value,
            :coding_region_id => code.id
          )
        end
      end
    end
  end
  
  # Print out the phases of genes in a certain gene list, provided they have a minimum of 70%
  # power.
  def derisi_boxplot_gene_list_data(gene_list_name)
    microarray = Microarray.find_by_description Microarray.derisi_2006_3D7_default
    
    # For each gene in the list
    CodingRegion.find(:all,
      :include => :plasmodb_gene_lists,
      :conditions => "plasmodb_gene_lists.description='#{gene_list_name}'"
    ).each do |code|
      
      
      percent = MicroarrayMeasurement.find(:first,
        :include => [
          :coding_region,
          {:microarray_timepoint => :microarray}
        ],
        :conditions => "microarray_timepoints.name='Percentage' and "+
          "microarray_timepoints.microarray_id=#{microarray.id} and "+
          "microarray_measurements.coding_region_id=#{code.id}",
        :order => 'microarray_measurements.id'
      )
      
      
      phase = MicroarrayMeasurement.find(:first,
        :include => [
          :coding_region,
          {:microarray_timepoint => :microarray}
        ],
        :conditions => "microarray_timepoints.name='Phase' and "+
          "microarray_timepoints.microarray_id=#{microarray.id} and "+
          "microarray_measurements.coding_region_id=#{code.id}",
        :order => 'microarray_measurements.id'
      )
      
      freqMax = MicroarrayMeasurement.find(:first,
        :include => [
          :coding_region,
          {:microarray_timepoint => :microarray}
        ],
        :conditions => "microarray_timepoints.name='freqMAX' and "+
          "microarray_timepoints.microarray_id=#{microarray.id} and "+
          "microarray_measurements.coding_region_id=#{code.id}",
        :order => 'microarray_measurements.id'
      )

      
      if phase and percent and percent.measurement > 0.7 
        #p code.string_id
        #p freqMax.measurement.to_i
        #return
      
        if freqMax.measurement.to_i == 1
          print code.string_id
          print ",#{percent.measurement}"
          print ",#{phase_to_timepoint(phase.measurement, 53)}"
          puts
        end
      end
    end
  end
  
  # Convert a phase (from FFT) to the timepoint of maximum expression
  def phase_to_timepoint(phase, cycle_time=48)
    # Maximal expression time is normalised(phase+pi/2)*lifecycle_time
    
    max_hour = (-phase+Math::PI/2)/(Math::PI*2)*cycle_time
    if max_hour < 0
      return max_hour+cycle_time
    elsif max_hour > cycle_time
      return max_hour-cycle_time
    else
      return max_hour
    end
  end
  
  
  def derisi_max_hour_boxplot_gene_list_data(gene_list_name)
    microarray = Microarray.find_by_description Microarray.derisi_2006_3D7_default
    
    # For each gene in the list
    CodingRegion.find(:all,
      :include => :plasmodb_gene_lists,
      :conditions => "plasmodb_gene_lists.description='#{gene_list_name}'"
    ).each do |code|
      maxHour = MicroarrayMeasurement.find(:first,
        :include => [
          :coding_region,
          {:microarray_timepoint => :microarray}
        ],
        :conditions => "microarray_timepoints.name='MAX HOUR' and "+
          "microarray_timepoints.microarray_id=#{microarray.id} and "+
          "microarray_measurements.coding_region_id=#{code.id}",
        :order => 'microarray_measurements.id'
      )
      
      if maxHour
        puts [
          code.string_id,
          maxHour.measurement.to_i
        ].join("\t")
      end
    end
  end
  
  # print out all the names of things that are in the list, and have a derisi 3D7 data point associated with them
  def gene_list_and_derisi_data(list_name)
    CodingRegion.find(:all,
      :include => [
        :plasmodb_gene_lists,
        {:microarray_measurements => {:microarray_timepoint => :microarray}}
      ],
      :conditions => "plasmodb_gene_lists.description='#{list_name}' and "+
        "microarrays.description='#{Microarray.derisi_2006_3D7_default}'"
    ).each do |code|
      puts code.string_id
    end
    
  end
  
  
  # For each of the metabolic maps we think are in the cytoplasm, define their localisation as cytoplasm
  def cytoplasm_metabolic_pathways_to_localisation
    list_names = [
      'folateBiosythesisPlasmoDb5.4',
      'glycolysisPlasmoDb5.4',
      'purinePlasmoDb5.4',
      'purinePlasmoDb5.4',
      'pyrimidinePlasmoDb5.4',
      'shikimatePlasmoDb5.4'
    ]
    
    method = LocalisationMethod.find_or_create_by_description('Metabolic Map')
    loc = Localisation.find_or_create_by_name('cytoplasm')
    
    count = CodingRegionLocalisation.count(
      :conditions => "localisation_method_id=#{method.id} and localisation_id=#{loc.id}"
    )
    puts "Started with #{count} localisations."
    
    list_names.each do |name|
      CodingRegion.find(:all,
        :include => :plasmodb_gene_lists,
        :conditions => "plasmodb_gene_lists.description='#{name}'"
      ).each do |code|
        CodingRegionLocalisation.find_or_create_by_coding_region_id_and_localisation_method_id_and_localisation_id(
          code.id,
          method.id,
          loc.id
        )
      end
    end
    
    count = CodingRegionLocalisation.count(
      :conditions => "localisation_method_id=#{method.id} and localisation_id=#{loc.id}"
    )
    puts "Ended with #{count} localisations."
  end
  
  
  def cytoplasm_metabolic_pathways_to_gene_list
    list_names = [
      'folateBiosythesisPlasmoDb5.4',
      'glycolysisPlasmoDb5.4',
      'purinePlasmoDb5.4',
      'purinePlasmoDb5.4',
      'pyrimidinePlasmoDb5.4',
      'shikimatePlasmoDb5.4'
    ]
    
    master_list = PlasmodbGeneList.find_or_create_by_description('CytoplasmMasterList')
    
    list_names.each do |name|
      CodingRegion.find(:all,
        :include => :plasmodb_gene_lists,
        :conditions => "plasmodb_gene_lists.description='#{name}'"
      ).each do |code|
        PlasmodbGeneListEntry.find_or_create_by_plasmodb_gene_list_id_and_coding_region_id(
          master_list.id,
          code.id
        )
      end
    end
    
    count = PlasmodbGeneListEntry.count(
      :conditions => "plasmodb_gene_list_id=#{master_list.id}"
    )
    puts "Ended with #{count} localisations."
  end
  
  
  def hypothetical_annotations
    Annotation.find(:all,
      :include => {:coding_region => {:gene => {:scaffold => :species}}},
      :conditions => "annotations.annotation like '%hypoth%' and species.name='#{Species.falciparum_name}'"
    ).each {|a| puts a.annotation}
  end
  
  
  # Reads the file sent to me by PlasmoDB and outputs the min, max, mean etc. for each protein
  def transmembrane_plasmodb
    
    splitter = ","
    puts [
      'Name',
      'Average',
      'Number',
      'Max',
      'Min'
    ].join(splitter)
    
    header = true
    last_gene_name =nil
    domains = []
    CSV.open("#{DATA_DIR}/falciparum/genome/plasmodb/5.4/plasmodb-5.4.2-tm.txt", 'r', "\t").each do |row|
      if header
        header = false
        next
      end
      
      
      if row[0] === last_gene_name
        t = TransmembraneDomain.new
        t.start = row[1].to_i
        t.stop = row[2].to_i
        domains.push t
      else
        # print the previous gene if this isn't the first
        if last_gene_name
          lengths = domains.collect{|d| d.length}
          
          # print out the stats
          stats = [
            last_gene_name,
            lengths.inject{|sum, n| sum+=n}.to_f/lengths.length.to_f,
            lengths.length,
            lengths.max,
            lengths.min
          ]
          puts "#{stats.join splitter}"
          
          # setup for the next one
          last_gene_name = row[0]
          t = TransmembraneDomain.new
          t.start = row[1].to_i
          t.stop = row[2].to_i
          domains = [t]
        else
          # First one in the whole list
          last_gene_name = row[0]
          t = TransmembraneDomain.new
          t.start = row[1].to_i
          t.stop = row[2].to_i
          domains = [t]          
        end
        
      end
    end
  end
  
  
  # For derisi, a certain percentage of genes are present. What is the Venn diagram when you compare
  # it with glucose yeast cellcycle data, for all the genes in falciparum?
  def derisi_v_orthomcl_glucose
    # How many in DeRisi in total?
    dees = CodingRegion.count(
      :include => [
        {:microarray_measurements => {:microarray_timepoint => :microarray}},
        {:gene => {:scaffold => :species}}
      ],
      :conditions => ["#{Microarray.table_name}.description=? and species.name=?",
        Microarray.derisi_2006_3D7_default,
        Species.falciparum_name
      ]
    )
    puts "Total #{Microarray.derisi_2006_3D7_default}: #{dees}"
    
    
    # How many are there if you track through the yeast genome via orthomcl official v2?
    # Oh god I love rails sometimes. Imagine the SQL here..
    yeasts = CodingRegion.count(
      :include => [
        {:gene => {:scaffold => :species}},
        { :orthomcl_genes =>{:orthomcl_group => [
              :orthomcl_run,
              {:orthomcl_genes => {:coding_regions => :plasmodb_gene_lists}}
            ]}}
      ],
      :conditions => ["#{OrthomclRun.table_name}.name = ? and "+
          "#{PlasmodbGeneList.table_name}.description= ? and "+
          "species.name=?",
        
        OrthomclRun.official_run_v2_name,
        'ygs98probes.Mar2008',
        Species.falciparum_name
      ]
    )
    puts "Yeast glucose via orthomcl: #{yeasts}"
    
    yeasts_derisi = CodingRegion.count(
      :include => [
        {:microarray_measurements => {:microarray_timepoint => :microarray}},
        {:gene => {:scaffold => :species}},
        { :orthomcl_genes =>{:orthomcl_group => [
              :orthomcl_run,
              {:orthomcl_genes => {:coding_regions => :plasmodb_gene_lists}}
            ]}}
      ],
      :conditions => ["#{Microarray.table_name}.description=? and "+
          "#{OrthomclRun.table_name}.name = ? and "+
          "#{PlasmodbGeneList.table_name}.description= ? and "+
          "species.name=?",
        
        Microarray.derisi_2006_3D7_default,
        OrthomclRun.official_run_v2_name,
        'ygs98probes.Mar2008',
        Species.falciparum_name
      ]
    )
    puts "Yeast glucose via orthomcl and derisi: #{yeasts_derisi}"
  end
  
  def min_transmembrane_domain_upload
    MinTransmembraneDomainLength.delete_all
    
    CSV.open("#{PHD_DIR}/transmembrane/falciparum_transmembranes.csv",'r').each do |row|
      code = CodingRegion.find_by_name_or_alternate_and_organism(row[0], Species.falciparum_name)
      if !code
        $stderr.puts "No coding region found for #{row[0]}"
      else
        MinTransmembraneDomainLength.create!(
          :coding_region_id => code.id,
          :domain_length => row[4]
        )
      end
      
    end
  end
  
  def min_transmembrane_length    
    count = anti_count = 0
    $stdin.each do |line|
      code = CodingRegion.find_by_name_or_alternate_and_organism(line.strip, Species.falciparum_name)
      
      if !code
        $stderr.puts "No coding region #{line.strip} found."
        next
      end
      
      if code.memsat_min_transmembrane_domain_length and code.memsat_transmembrane_domain_count.measurement > 1
        
        puts "#{code.string_id}  #{code.memsat_min_transmembrane_domain_length.measurement}"
        count += 1
      else
        anti_count += 1
      end
      
    end
    
    $stderr.puts "Printed #{count} and failed to print #{anti_count}"
  end
  
  # Upload the min and average toppred scores for all of the coding regions
  def toppred_domain_lengths_upload
    require 'toppred_parser'
    
    parser = ToppredParser.new("#{PHD_DIR}/transmembrane/toppred/toppred.out")
    while p = parser.next_prediction
      matches = p.name.match 'Plasmodium_falciparum_3D7_(.+?)_(.+)_Annotation'
      if !matches
        raise Exception, "couldn't parse protein name: #{p.name}"
      end
      
      code = CodingRegion.find_by_name_or_alternate_and_organism(matches[2], Species.falciparum_name)
      if !code
        code = CodingRegion.find_by_name_or_alternate_and_organism(matches[2].gsub('_','.'), Species.falciparum_name)
        if !code
          raise Exception, "Coudn't find coding region #{matches[2]} from #{matches[0]}"
        end
      end
      
      lengths = p.transmembrane_domains.collect {|tmd| tmd.length}
      
      # ignore empties
      if lengths.length == 0
        next
      end
      
      ToppredMinTransmembraneDomainLength.find_or_create_by_coding_region_id_and_measurement(
        code.id,
        lengths.min
      )
      
      ToppredAverageTransmembraneDomainLength.find_or_create_by_coding_region_id_and_measurement(
        code.id,
        lengths.inject{|sum, n| sum+=n}/lengths.length
      )
    end
  end
  
  # print out a fasta file of all the sequences in falciparum, except without a signal sequence
  def falciparum_minus_signal_peptides
    CodingRegion.find(:all,
      :include => [
        {:gene => {:scaffold => :species}},
        :amino_acid_sequence
      ],
      :conditions => "species.name='#{Species.falciparum_name}'"
    ).each do |code|
      if !code.amino_acid_sequence
        $stderr.puts "No sequence found for #{code.string_id}"
        next
      end
      aa =code.amino_acid_sequence.sequence
      sig = SignalP.calculate_signal(aa)
      
      puts ">#{code.string_id}"
      puts sig.cleave(aa)
    end
  end
  
  def babesia_genes_minus_signal_peptides
    $stdin.each_line do |line|
      code = CodingRegion.find_by_name_or_alternate_and_organism(line.strip, Species.babesia_bovis_name)
      if !code
        raise Exception, "#{line} not found"
      end
      
      if !code.amino_acid_sequence
        raise Exception, "No coding region found for #{line}"
      end
      aa = code.amino_acid_sequence.sequence
      sig = SignalP.calculate_signal(aa)
      
      puts ">#{code.string_id}"
      puts sig.cleave(aa)
    end
  end
  
  def memsat_upload
    memsat_upload_generic(Species.falciparum_name,"#{PHD_DIR}/transmembrane/no_signalp", 5460)
  end
  
  def memsat_upload_yeast
    memsat_upload_generic(Species.yeast_name, "#{PHD_DIR}/transmembrane/yeast/memsat_run", 5883)
  end
  
  # Upload results. All results are in a single directory and were generated by memsat_multifasta.rb
  def memsat_upload_generic(species_name, memsat_results_directory, num_entries)
    parser = MemsatParser.new
    
    (1..num_entries).each do |n|
      seqname = Bio::FlatFile.auto("#{memsat_results_directory}/memsat#{n}").next_entry.entry_id
      
      code = CodingRegion.find_by_name_or_alternate_and_organism(seqname, species_name)
      if !code
        raise Exception, "Couldn't find '#{seqname}'"
      end
      
      tmds = parser.parse("#{memsat_results_directory}/memsat#{n}.memsat")
      if tmds.has_domain?
        MemsatAverageTransmembraneDomainLength.find_or_create_by_coding_region_id_and_measurement(code.id, tmds.average_length)
        MemsatMinTransmembraneDomainLength.find_or_create_by_coding_region_id_and_measurement(code.id, tmds.minimum_length)
        MemsatTransmembraneDomainCount.find_or_create_by_coding_region_id_and_measurement(code.id, tmds.transmembrane_domains.length)
        MemsatMaxTransmembraneDomainLength.find_or_create_by_coding_region_id_and_measurement(code.id, tmds.maximum_length)
      end
    end
  end
  
  def tmhmm_datas
    count = anti_count = 0
    $stdin.each do |line|
      code = CodingRegion.find_by_name_or_alternate_and_organism(line.strip, Species.falciparum_name)
      
      if !code
        $stderr.puts "No coding region #{line.strip} found."
        next
      end
      
      minus_sp = code.sequence_without_signal_peptide
      tmhmm_result = TmHmmWrapper.new.calculate(minus_sp)
      
      if tmhmm_result.transmembrane_domains.length > 1  
        puts "#{code.string_id}  #{tmhmm_result.minimum_length}  #{tmhmm_result.average_length}  #{tmhmm_result.maximum_length}"
        count += 1
      else
        anti_count += 1
      end
      
    end
    
    $stderr.puts "Printed #{count} and failed to print #{anti_count}"
  end
  
  # print out all the calculated transmembrane data for proteins in the input lists
  def transmembrane_data
    sep = "\t"
    puts CodingRegion.transmembrane_data_columns.join(sep)
    
    $stdin.each do |line|
      code = CodingRegion.find_by_name_or_alternate_and_organism(line.strip, Species.falciparum_name)
      
      if !code
        $stderr.puts "No coding region #{line.strip} found."
        next
      end

      puts code.transmembrane_data.join(sep)
    end
    
  end
  
  def transmembrane_data_yeast
    CodingRegion.all(
      :include => {:gene =>{ :scaffold => :species}},
      :conditions => "species.name = '#{Species.yeast_name}'"
    ).each do |code|
      begin
        puts code.transmembrane_data.join("\t")
      rescue Exception
        $stderr.puts "failed on one: #{$!}"
      end
    end
  end
  
  def upload_yeast_genome
    Bio::FlatFile.auto("#{DATA_DIR}/yeast/genome/20080606/orf_trans.fasta").each do |seq|
      name = seq.entry_id
      
      code = CodingRegion.find_by_name_or_alternate_and_organism(name, Species.yeast_name)
      if !code
        $stderr.puts "Couldn't find coding region name: #{name}. Ignoring."
        next
      end
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
        code.id,
        seq.seq
      )
    end
  end
  
  
  def genome_minus_signal_peptide(species_name=Species.yeast_name)
    CodingRegion.find(:all,
      :include => [
        {:gene => {:scaffold => :species}},
        :amino_acid_sequence
      ],
      :conditions => "species.name='#{species_name}'"
    ).each do |code|
      if !code.amino_acid_sequence
        $stderr.puts "No sequence found for #{code.string_id}"
        next
      end
      aa =code.amino_acid_sequence.sequence
      sig = SignalP.calculate_signal(aa)
      
      puts ">#{code.string_id}"
      puts sig.cleave(aa)
    end
  end
  
  
  def all_falciparum_transmembrane_data
    sep = "\t"
    puts CodingRegion.transmembrane_data_columns.join(sep)
    
    AminoAcidSequence.all(:conditions => "species.name='#{Species.falciparum_name}'", 
      :include => [
        {:coding_region => {:gene => {:scaffold => :species}}}
      ]
    ).each do |seq|
      puts seq.coding_region.transmembrane_data.join(sep)
    end
  end
  
  
  # upload uniprot, but don't bother with the species or gene or any of that.
  def upload_uniprot_kb_sequences
    sp = Species.find_or_create_by_name('uniprot dummy')
    scaff = Scaffold.find_or_create_by_name_and_species_id(
      'uniprot dummy',
      sp.id
    )
    dummy_gene = Gene.find_or_create_by_name_and_scaffold_id("UniprotKB Dummy #{Date.today}", scaff.id)
    
    # I think bio::flatfile screws it up so..
    #    FileUtils.cp('/blastdb/uniprot_sprot.fasta', '/blastdb/uniprot_sprot.bak.fasta')
    Bio::FlatFile.auto('/blastdb/uniprot_sprot.bak.fasta').each do |seq|
      splits = seq.identifiers.to_s.split(' ')
      
      code = CodingRegion.find_or_create_by_string_id_and_gene_id(
        splits[0],
        dummy_gene.id
      )
      Annotation.find_or_create_by_coding_region_id_and_annotation(
        code.id,
        splits[2..-1].join(' ')
      )
      CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(
        code.id,
        splits[1]
      )
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
        code.id,
        seq.seq
      )
    end
  end
  
  # just upload the mRNA stuff for the moment.
  # also upload the genes (before mRNA, because they are more awesome)
  def upload_elegans_gff3
    require 'gff3_genes'
    
    # create some dummies
    sp = Species.find_or_create_by_name(Species.elegans_name)
    scaf = Scaffold.find_or_create_by_species_id_and_name(
      sp.id,
      'Elegens dummy scaffold'
    )
    
    
    # upload the genes
    GFF3ParserLight.new(File.open( "#{DATA_DIR}/elegans/wormbase/WS187/elegansWS187.geneOnly.gff3")).each_feature('gene') do |record|
      name = record.attributes['Name']
      raise Exception("No name found for gene record: #{record}") if !name
        
      #attributes:
      #ID=Gene:WBGene00003564;Name=WBGene00003564;Alias=F10G8.5,ncs-2;Dbxref=CGC:ncs-2
      
      gene = Gene.find_or_create_by_name_and_scaffold_id(
        name,
        scaf.id
      )
      
      # add alias if they exist
      if record.attributes['Alias']
        record.attributes['Alias'].split(',').each do |al|
          GeneAlternateName.find_or_create_by_gene_id_and_name(
            gene.id,
            al
          )
        end
      end
      
    end
    
    


    # Brought the size down to 23MB, much more manageable than 1.7GB for the whole thing, less memory intensive that way
    GFF3ParserLight.new(File.open( "#{DATA_DIR}/elegans/wormbase/WS187/elegansWS187.mRNAonly.gff3")).each_feature('mRNA') do |record|
      name = record.attributes['Name']
      raise Exception("No name found for mRNA record: #{record}") if !name
      
      # find the gene_id
      #Parent=Gene:WBGene00008662
      parent  = record.attributes['Parent']
      if !parent
        $stderr.puts "No parent for #{name} found"
        next
      end
      match = parent.match('^Gene:(.+)$')
      if !match
        $stderr.puts "No gene parent for #{parent} in #{name}"
        next
      end
      gene = Gene.find_by_name_or_alternate_and_organism(match[1], Species.elegans_name)
        
      code = CodingRegion.find_or_create_by_string_id_and_gene_id(
        name,
        gene.id
      )
        
      # include aliai
      if alias_string = record.attributes['Alias']
        #assumes there is no commas in the aliases. I very much doubt there is.
        alias_string.split(',').each do |a|
          CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(
            code.id,
            a
          )
        end

      end
    end

    #    apidb_species_to_database(Species.elegans,)
  end
  
  def upload_esldb_elegans
    
    #setup experimental and similarity localisations
    experimental = LocalisationMethod.find_or_create_by_description(LocalisationMethod.esldb_experimental)
    #    all = LocalisationMethod.find_or_create_by_description(LocalisationMethod.esldb_all)
    
    first = true
    CSV.open("#{DATA_DIR}/localisation/eSLDB/eSLDB_Caenorhabditis_elegans.csv", 'r', "\t") do |row|
      if first #skip the header line
        first = false
        next
      end
      
      # eg.
      # eSLDB code	Original Database Code	Experimental annotation	SwissProt fulltext annotation	SwissProt entry	Similarity based annotation	SwissProt homologue	E-value	Prediction	Aminoacidic sequence	Common mame
      # CE000000073	T21H3.1a	None	None	None	None	None	None	None	MQALLLAAVLLPLASAFVLPEAPKNPENLDVYTIPYNDATARKKILFAAGAAYGSNPQQCLDKAFTGASIRRIITARCDVNPADKCVGYTAVSPQDKAIIVVFRGTNNNVQLILEGLETVFEYHTPWAAGGVVSQYFNDGFLNIWNAGLKDDFNTLAAQNPGFQVWVTGHSLGGAMASLAASYITYNKLFDASKLQLVTYGQPRVGDKAYAAAVDRDVTNKFRVTHAHDPVPHLPKENMQGFTHHKAEVFYKEKMTKYNICDDIDESEFCSNGQVLPDTSIKDHLHYFDVDVSDLGYSNCANVKN	None

      name = row[1]
      experimental_text = row[2]
      #      consensus = rows[]
      
      # find the coding region
      c1 = CodingRegion.find_by_name_or_alternate_and_organism(name, Species.elegans_name)
      
      # if no coding region, say so
      if !c1
        $stderr.puts "No coding region #{name} found"
        next
      end
      
      # split each of the experimental annots, and upload
      if experimental_text and experimental_text != 'None'
        experimental_text.split(',').each do |locname|
          l = Localisation.find_or_create_by_name locname.strip
          CodingRegionLocalisation.find_or_create_by_coding_region_id_and_localisation_id_and_localisation_method_id(
            c1.id,
            l.id,
            experimental.id
          )
        end
      end
      
      #      consensus.split(',').each do |locname|
      #        l = Localisation.find_or_create_by_description locname.strip
      #        CodingRegionLocalisation.find_or_create_by_coding_region_id_and_localisation_id_and_localisation_method_id(
      #          c1.id,
      #          l.id,
      #          experimental.id
      #        )
      #      end
    end
  end
  
  def upload_wormnet
   
    net = Network.find_or_create_by_name(
      Network::WORMNET_NAME
    )
    first = true
    #test_on_one_gene
    CSV.open("#{DATA_DIR}/elegans/lee/ng.2007.70-S3.txt", 'r', "\t") do |row|
      
      if first #skip the header line
        first = false
        next
      end
      
      # Wormnet finds genes and not coding regions, which is kind of confusing.
      # find gene if it exists
      g1 = CodingRegion.find_by_name_or_alternate_and_organism(row[0], Species.elegans_name)
      g2 = CodingRegion.find_by_name_or_alternate_and_organism(row[1], Species.elegans_name)

      
      if !g1
        puts "Couldn't find gene1 #{[row[0],row[1],row[11]].join("\t")}"
        next
      end
      
      if !g2
        puts "Couldn't find gene2 #{[row[0],row[1],row[11]].join("\t")}"
        next
      end
          
 
      CodingRegionNetworkEdge.find_or_create_by_network_id_and_coding_region_id_first_and_coding_region_id_second_and_strength(
        net.id,
        g1.id,
        g2.id,
        row[11]
      )
    end
  end
  
  def remove_secstr_from_pdb
    FileUtils.cp "#{PHD_DIR}/transmembrane/pdb_blast/ss.txt", '/tmp/pdb_ss.fa'
    out = File.open('/blastdb/pdb.fa', 'w')
    count_seq = count_str = 0
    Bio::FlatFile.auto('/tmp/pdb_ss.fa').each do |seq|
      if !seq.entry_id.match('secstr')
        out.puts seq.to_s
        count_seq +=1
      else
        count_str +=1
      end
    end
    if count_seq != count_str
      raise Exception, "Different numbers found: #{count_seq} vs str #{count_str}"
    end
  end
  
  def upload_membrain_curated
    dummy_gene = Gene.new.create_dummy 'membrain_dummy'
    Bio::FlatFile.auto('/blastdb/membrain.fa').each do |seq|
      bits = seq.identifiers.to_s.split(' ') #split on whitespace
      code = CodingRegion.find_or_create_by_string_id_and_gene_id(
        bits[0],
        dummy_gene.id
      )
      bits[1..bits.length-1].each do |bit|
        matches = bit.match('^(\d+)-(\d+)$')
        if !matches
          raise Exception, "badly parsed transmembrane domain"
        end
        
        MembrainTransmembraneDomain.find_or_create_by_coding_region_id_and_start_and_stop(
          code.id,
          matches[1],
          matches[2]
        )
      end
    end
  end
  
  def upload_membrain_pdb_observed_tmds
    
    #    MembrainTransmembraneDomain.destroy_all
    
    count = 0
    code = nil
    File.open("#{DATA_DIR}/papers/membrain/pdb_results.txt").each do |line|
      #PDB code: 1AP9_A
      #
      #Observed	10-30; 39-62; 77-101; 105-127; 134-157; 169-191; 202-224
      #MemBrain	10-29; 43-63; 78-97; 107-127; 134-154; 172-191; 203-224
      matches = line.strip.match '^PDB code: (......)$'
      if matches
        count = 1
        ems2 = matches[1].match('(....)_(.)') or raise Exception, "Didn't match pdb_id properly"
        name = "#{ems2[1]}.pdb_#{ems2[2]}"
        code = CodingRegion.find_by_string_id(name, :include => :gene, :conditions => "genes.name='membrain_dummy'")
        #        puts code.string_id
      elsif count == 1
        count += 1 #almost there
      elsif count == 2
        line = line.strip.gsub(/^Observed\t+/,'') or raise Exeption, "Badly parsed oberve line"
        #        p line
        regex = /^(\d+)-(\d+)(\; ){0,1}/
        while matches = line.match(regex)
          MembrainTransmembraneDomain.find_or_create_by_coding_region_id_and_start_and_stop(
            code.id,
            matches[1],
            matches[2]
          )
          #          puts "#{code.string_id} = #{matches[1]} to #{matches[2]}"
          line = line.gsub(regex, '')
          #          p line
          #        return
        end
        count = 0
      else
        count = 0
      end
    end
  end
  
  
  # Find the genes in falciparum that blast well to a transmembrane domain 
  # in a well-characterised protein
  def falciparum_blast_membrain_overlaps
    File.open("#{PHD_DIR}/transmembrane/pdb_blast/membrainVpfalciparum.blast.tab").each do |line|
      # skip comment lines
      next if line.match(/^\s*\#/)
      
      bits = line.strip.split("\t")
      #      p bits
      subject_name = bits[1]
      subject_start = bits[8]
      subject_stop = bits[9]
      
      # overlapping if either the start or stop is within the borders
      magics = MembrainTransmembraneDomain.all(
        :include => :coding_region,
        :conditions => "coding_regions.string_id='#{subject_name}' and ((transmembrane_domains.start<=#{subject_start} and transmembrane_domains.stop>=#{subject_start})    or     (transmembrane_domains.start<=#{subject_stop} and transmembrane_domains.stop>=#{subject_stop}))"
      )
      magics.each do |tmd|
        puts [
          subject_name,
          bits[0],
          subject_start,
          subject_stop,
          tmd.start,
          tmd.stop
        ].join("\t")
      end
    end
  end

  def falciparum_blast_membrain_overlaps_totally
    File.open("#{PHD_DIR}/transmembrane/pdb_blast/membrainVpfalciparum.blast.tab").each do |line|
      # skip comment lines
      next if line.match(/^\s*\#/)
      
      bits = line.strip.split("\t")
      #      p bits
      subject_name = bits[1]
      subject_start = bits[8]
      subject_stop = bits[9]
      
      # overlapping if either the start or stop is within the borders
      magics = MembrainTransmembraneDomain.all(
        :include => :coding_region,
        :conditions => "coding_regions.string_id='#{subject_name}' and ((transmembrane_domains.start >= #{subject_start} and transmembrane_domains.stop <= #{subject_stop}))"
      )
      magics.each do |tmd|
        puts [
          subject_name,
          bits[0],
          subject_start,
          subject_stop,
          tmd.start,
          tmd.stop
        ].join("\t")
      end
    end
  end
  
  
  # for each line of stdin (one string_id per line), what is the annotation?
  def annotation(species_name=nil)
    $stdin.each do |line|
      next if line.strip === '' #skip blank lines
      
      code = nil
      if species_name
        code = CodingRegion.find_by_name_or_alternate_and_organism(line.strip, species_name)
      else
        code = CodingRegion.find_by_name_or_alternate(line.strip)
      end
      
      puts [
        code.string_id,
        code.annotation.nil? ? nil : code.annotation.annotation
      ].join("\t")
    end
  end
  
  #assumes the coding regions are created - now just have to upload sequences
  def upload_membrain_fasta
    Bio::FlatFile.auto('/blastdb/membrain.fa').each do |seq|
      code = CodingRegion.find_by_name_or_alternate_and_organism(seq.string_id, 'membrain_dummy')
      if !code
        raise Exception, "No coding region '#{seq.entry_id}' found."
      end
      
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
        code.id,
        seq.seq
      )
      
    end
  end
  
  
  # given a list of string_ids, only print them if their annotation
  # is not contained in the given list (case insensitive searching)
  def exclude_on_annotation(annotation_array)
    $stdin.each do |line|
      name = line.strip
      code = CodingRegion.find_by_name_or_alternate(name)
      if !code
        raise Exception, "no coding region #{name} found"
      end
      
      if !code.annotation
        raise Exception, "No annotation found for #{name}"
      end
      
      print = true
      annotation_array.each do |term|
        if code.annotation.annotation.match(/#{term}/i)
          print = false
        end
      end
      
      if print
        puts name
      end
    end
  end
  
  
  # Write out localisation stats for each of the localisations given by the yeast GFP dataset.
  def yeast_gfp_localisation_transmembrane_lengths
    Localisation.all.each do |loc|
      puts "Localisation: #{loc.name}"
      file = File.open("#{PHD_DIR}/transmembrane/yeast/gfp/#{loc.name.gsub(' ','_')}_all_results.tab", 'w')
      
      # for each of the coding regions that were generated from the Yeast GFP data set for this localisation
      codes = CodingRegion.all(
        :include => {:coding_region_localisations => [
            :localisation,
            :localisation_method
          ]
        },
        :conditions => "localisation_methods.description='#{LocalisationMethod.yeast_gfp_description}' and "+
          "localisations.id=#{loc.id}"
      )
      puts "Found #{codes.length} coding regions"
      
      codes.each do |code|
        begin
          file.puts code.transmembrane_data.join("\t")
        rescue Exception
          $stderr.puts "failed on one: #{$!}"
        end
      end
      
      file.close
    end
  end
  
  # Upload all the sequences that are in the LOCATE fasta file
  #
  # names - I'll just take the entry_id - the names are a bit messy and I don't care.
  def upload_human_plasma_membrane_fasta
    gene = Gene.new.create_dummy('Human LOCATE Plasma Membrane Dummy')
    
    Bio::FlatFile.auto("#{PHD_DIR}/transmembrane/human_plasma_membrane/HumanPMLocate.fa").each do |seq|
      name = seq.entry_id
      code = CodingRegion.find_or_create_by_gene_id_and_string_id(
        gene.id,
        name
      )
      
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
        code.id,
        seq.seq
      )
    end
  end
  
  def human_plasma_membrane_memsat_upload
    memsat_upload_generic('Human LOCATE Plasma Membrane Dummy', "#{PHD_DIR}/transmembrane/human_plasma_membrane/results", 4929)
  end
  
  
  def transmembrane_data_human_plasma_membrane
    CodingRegion.all(
      :include => :gene,
      :conditions => "genes.name ='Human LOCATE Plasma Membrane Dummy'"
    ).each do |code|
      begin
        puts code.transmembrane_data.join("\t")
      rescue Exception
        $stderr.puts "failed on one: #{$!}"
      end
    end
  end
  


  # Take the wormnet and work out what the average length of the localisations to each other is,
  def wormnet_falciparum_localisation_first
    require 'array_pair'
    #    Localisation.all(
    #      :include => {:coding_regions => {:gene => {:scaffold => :species}}},
    #      :conditions => ['species.name = ?', Species.falciparum_name]
    #    ).each do |loc|
    #      puts loc.name
      
    #      # collect the pairwise distances between each of the coding regions with those localisations
    #      CodingRegion.all(
    #        :include => [
    #          {:gene => {:scaffold => :species}},
    #          :localisations
    #        ],
    #        :conditions => ["species.name = ? and localisations.id = ?",
    #          Species.falciparum_name,
    #          loc.id
    #        ]
    CodingRegion.all(
      :include => :plasmodb_gene_lists,
      :conditions => ['plasmodb_gene_lists.description = ?', 'apicopalst.Stuart.20080215']
    ).pairs.collect do |pair|
      
      #      p pair
      #      pair = [CodingRegion.find(4705), CodingRegion.find(4012)]
      #      pair = [CodingRegion.find(3128), CodingRegion.find(3479)]
        
      # Each coding region now has to be taken across the species divide using orthoMCL.
      # What if there is more than 1 elegans gene? I could do something complex, but for the
      # moment it'll just be the first one (so essentially random).
        
        
      # Find all the falciparum genes with orthomcl linked elegans genes that have 
      # 
      # I have pairs of falciparum coding regions. I want the average strength of the corresponding elegans ones
        
      # Bringing edges into it is complicated, since gene1 and gene2 can be switched. So first of all just get the
      # Elegans Genes for each of the genes separately.
        
      # NB: PF10_0084 and PFD1050w are good for testing here
      eleones = [
        pair[0].orthomcls(Species.elegans_name),
        pair[1].orthomcls(Species.elegans_name)
      ]
        
      # Now get the edges between the genes
        
      # For each pair in between the two of groups, collect the strength of the 
      strengths = eleones[0].pairs(eleones[1]).collect{|elegan_code_pairs|
        if elegan_code_pairs[0].gene and
            elegan_code_pairs[1].gene and
            edge = GeneNetworkEdge.find_by_gene_ids(GeneNetwork.wormnet_name, elegan_code_pairs[0].gene.id, elegan_code_pairs[1].gene.id)
          edge.strength.to_f
        else
          nil
        end
      }
       
      strengths.reject!{|i| !i}
      if strengths and !strengths.empty?
        puts pair.collect{|p| [p.string_id, p.id]}.push(strengths.average).join("\t")
      end
    end
  end

  
  
  def upload_transmembrane_gene_lists
    base = "#{PHD_DIR}/transmembrane/again"
    lists = [
      ["#{base}/apicoplast.stuart.20080215.csv", 'apicopalst.Stuart.20080215'],
      ["#{base}/fv.csv", 'fv.transmembrane'],
      ["#{base}/ht.csv", 'ht.transmembrane'],
      ["#{base}/pexel.csv", 'pexel.transmembrane']
    ]
    
    lists.each do |pair|
      list = PlasmodbGeneList.find_or_create_by_description(pair[1])
      
      File.open(pair[0]).each do |line|
        next if line.strip === ''
        
        code = CodingRegion.find_by_name_or_alternate_and_organism(line.strip, Species.falciparum_name)
        if !code
          raise Exception, "no coding region '#{line}' found"
        end
        
        PlasmodbGeneListEntry.find_or_create_by_plasmodb_gene_list_id_and_coding_region_id(
          list.id,
          code.id
        )
      end
    end
  end
  
  
  def transmembrane_data
    sep = "\t"
    lists = [
      'apicoplast.Stuart.20080215',
      #      'fv.transmembrane',
      #      'ht.transmembrane',
      #      'pexel.transmembrane'
    ]
    lists.each do |list|
      File.open("#{PHD_DIR}/transmembrane/post_holidays/rerun/#{list}.csv", 'w') do |f|
        f.puts CodingRegion.transmembrane_data_columns.join(sep)
        PlasmodbGeneList.find_by_description(list).coding_regions.each{ |c| 
          f.puts c.transmembrane_data.join(sep)
        }
      end
    end
    
    # now the genes not in any of the lists
    #    File.open("#{PHD_DIR}/transmembrane/post_holidays/rerun/other.csv", 'w') do |f|
    #      f.puts CodingRegion.transmembrane_data_columns.join(sep)
    #      CodingRegion.all(
    #        :include => [
    #          {:gene => {:scaffold => :species}},
    #          :plasmodb_gene_lists
    #        ],
    #        :conditions =>
    #          "species.name = '#{Species.falciparum_name}' and "+
    #          "coding_regions.id not in (select coding_regions.id from coding_regions LEFT OUTER JOIN \"plasmodb_gene_list_entries\" ON (\"coding_regions\".\"id\" = \"plasmodb_gene_list_entries\".\"coding_region_id\") LEFT OUTER JOIN \"plasmodb_gene_lists\" ON (\"plasmodb_gene_lists\".\"id\" = \"plasmodb_gene_list_entries\".\"plasmodb_gene_list_id\") WHERE ("+
    #          "plasmodb_gene_lists.description=E'#{lists[0]}' or "+
    #          "plasmodb_gene_lists.description=E'#{lists[1]}' or "+
    #          "plasmodb_gene_lists.description=E'#{lists[2]}' or "+
    #          "plasmodb_gene_lists.description=E'#{lists[3]}'"+
    #          "))"
    #      ).each do |code|
    #        begin
    #          f.puts code.transmembrane_data.join(sep)
    #        rescue CodingRegionNotFoundException
    #          $stderr.puts $!
    #        end
    #      end
    #    end
  end

  def not_var_rifin_stevor_transmembrane_data
    sep = "\t"
    list = 'Exported Minus Var Rifin Stevor'
    bads = ['var','rifin','stevor']
    File.open("#{PHD_DIR}/transmembrane/post_holidays/rerun/#{list}.csv", 'w') do |f|
      f.puts CodingRegion.transmembrane_data_columns.join(sep)
      CodingRegion.all(:include => [:plasmodb_gene_lists, :annotation], :conditions => "plasmodb_gene_lists.description in ('pexel.transmembrane','ht.transmembrane','exportPred10')").each {|c|
        ann = c.annotation.annotation
        found = false
        bads.each do |bad|
          if /#{bad}/i.match(ann)
            found = true
          end
        end
        p found
        p ann
        if !found
          f.puts c.transmembrane_data.join(sep)
        end
      }
    end
  end
  
  def ben_celegans_phenotype_information_to_database
    Mscript.new.celegans_phenotype_information_to_database("#{DATA_DIR}/Essentiality/Celegans/cel_wormbase_pheno.tsv")
  end
  
  def ben_celegans_phenotype_observed_to_database
    Mscript.new.celegans_phenotype_observed_to_database("#{DATA_DIR}/Essentiality/Celegans/cel_wormbase_pheno.tsv")
  end
  
  def upload_mouse_essentiality_data
    puts "Deleting old entries.."
    MousePhenotype.delete_all
    MousePhenotypeDictionaryEntry.delete_all
    CodingRegionMousePhenotype.delete_all
    MousePhenotypeMousePhenotypeDictionaryEntry.delete_all
    puts "Uploading Descriptions.."
    ben_upload_mouse_phenotype_descriptions
    puts "Uploading phenotypes.."
    ben_upload_mouse_phenotype_information
  end
  
  def ben_upload_mouse_phenotype_descriptions
    Mscript.new.upload_mouse_phenotype_descriptions("#{DATA_DIR}/Essentiality/Mouse/VOC_MammalianPhenotype.rpt")
  end
  
  def ben_upload_mouse_phenotype_information
    Mscript.new.upload_mouse_phenotype_information("#{DATA_DIR}/Essentiality/Mouse/MGI_PhenotypicAllele.rpt")
  end
  
  def ben_yeast_phenotype_information_to_database
    Mscript.new.yeast_phenotype_information_to_database("#{DATA_DIR}/Essentiality/Yeast/phenotype_data.tab")
  end
  
  def ben_drosophila_phenotypes_to_db
    Mscript.new.drosophila_phenotypes_to_db("#{DATA_DIR}/Essentiality/Drosophila")
  end
  
  # Print out the maximal orfs from the babesia genome contigs
  def babesia_orf_finder
    require 'orf_finder'
    finder = Orf::OrfFinder.new
    count = 1
    Bio::FlatFile.auto("#{DATA_DIR}/bovis/genome/NCBI/BabesiaWGS-96909.fasta").each do |seq|
      orf_threads = finder.generate_longest_orfs(seq.seq)
      orf_threads.each do |orfs|
        orfs.each do |orf|
          if orf.length > 1
            puts ">orf_finder_orf_#{count} #{seq.entry_id} #{orf.start} #{orf.stop}"
            puts orf.aa_sequence
            count += 1
          end
        end
      end
    end
  end
  
  def spit_babesia_files
    gb = File.open("#{DATA_DIR}/bovis/genome/NCBI/AAXT01000000.gb")
    cur = nil
    gb.each do |line|
      matches = line.match(/^LOCUS\s+(AA\S+)/)
      if matches
        p matches[1]
        cur = File.open("#{DATA_DIR}/bovis/genome/NCBI/#{matches[1]}.gb",'w')
        cur.print line
      else
        cur.print line
      end
    end
  end
  
  # Upload the GenBank file into the database
  def babesia_bovis_genbank_upload
    # Just upload the cds for the moment, 
    scaff = nil
    species = Species.find_by_name(Species.babesia_bovis_name)
    Dir.new("#{DATA_DIR}/bovis/genome/NCBI").entries.each do |entry|
      #         use all entries that but not the all-encompassing one
      if entry.match(/AAXT010000/) and !entry.match(/AAXT01000000/)
        scaff = Scaffold.find_or_create_by_species_id_and_name(species.id, entry)
        gb = Bio::GenBank.new(File.open("#{DATA_DIR}/bovis/genome/NCBI/#{entry}").read)
                
        gb.each_cds do |feature|
          string = feature.to_hash['locus_tag']
          if !string
            raise Exception, "Couldn't find locus in #{feature.inspect}"
          end
      
          code = CodingRegion.find_by_name_or_alternate_and_organism(string, Species.babesia_bovis_name)
          if !code
            raise Exception, "Couldn't find coding region name #{string}"
          end

          feature.locations.each do |location|
            Cd.find_or_create_by_coding_region_id_and_start_and_stop(
              code.id,
              location.from,
              location.to
            ) or raise Exception, "Failed to upload Cd: #{location}"
          end
        
          # Set orientation of gene
          complement = feature.locations.first.strand
          if complement < 0
            code.set_negative_orientation
          else
            code.set_positive_orientation
          end
          code.save!
        
          # Fix scaffold if not done already
          code.gene.scaffold = scaff
          code.gene.save!

        end
      end
    end
  end
  
  # Find all the genes where there is a 5 prime extension (but without the need of an upstream exon) relative to the 
  # official genome. Assumes Script.new.babesia_bovis_cds and verification
  def babesia_five_prime_extensions
    # for each of the generated coding regions
    require 'orf_finder'
    finder = Orf::OrfFinder.new
    Bio::FlatFile.auto("#{DATA_DIR}/bovis/genome/NCBI/BabesiaWGS-96909.fasta").each do |seq|
      genbank_id = seq.definition.match(/^Babesia bovis .*, whole genome shotgun sequence. \| (\S+)$/)[1]
      scaff = Scaffold.find_by_name "#{genbank_id}.gb"
      raise if !scaff
      
      # forward direction
      orf_threads = finder.generate_longest_orfs(seq.seq)
      orf_threads.each do |orfs|
        orfs.each do |orf|
          if orf.length > 1
            # Does this orf encompass another one that is already in the genome?
            codes = CodingRegion.all(
              :include => [
                :cds,
                :gene
              ],
              :conditions =>
                "coding_regions.orientation = '#{CodingRegion.positive_orientation}' and "+ # Coding regions must be positive
              "genes.scaffold_id = #{scaff.id} and "+ #has to be on the same stretch
              "cds.start-1 > #{orf.start} and cds.stop-1 <= #{orf.stop} and "+# start must be before and end same or after 
              "(cds.start - #{orf.start}) % 3 = 1" #must be in frame. 1 is somewhat of a hack, but seems to be true for BBOV_III000190
            )
            codes.each do |code|
              puts [
                code.string_id,
                code.cds[0].start,
                orf.start,
                code.orientation,
                orf.aa_sequence,
                code.amino_acid_sequence.sequence
              ].join("\t")
            end
          end
        end
      end
        
      # reverse direction
      orf_threads = finder.generate_longest_orfs(Bio::Sequence::NA.new(seq.seq).complement)
      orf_threads.each do |orfs|
        orfs.each do |orf|
          if orf.length > 1
            # Does this orf encompass another one that is already in the genome?
            codes = CodingRegion.all(
              :include => [
                :cds,
                :gene
              ],
              :conditions =>
                "coding_regions.orientation = '#{CodingRegion.negative_orientation}' and "+ # Coding regions must be positive
              "genes.scaffold_id = #{scaff.id} and "+ #has to be on the same stretch
              "cds.stop+1 < #{seq.length-orf.start} and cds.start+1 >= #{seq.length - orf.stop} and "+# start must be before and end same or after 
              "(cds.stop - #{seq.length-orf.start}) % 3 = 1" #must be in frame. 1 is somewhat of a hack, but seems to be true for BBOV_III000190
            )
            codes.each do |code|
              puts [
                code.string_id,
                code.cds[0].start,
                orf.start,
                code.orientation,
                orf.aa_sequence,
                code.amino_acid_sequence.sequence
              ].join("\t")
            end
          end
        end
      end
    end
  end
  
  def upload_other_meta
    DevelopmentalStage.new.upload_known_falciparum_developmental_stages
    Localisation.new.upload_known_localisations
    Localisation.new.upload_localisation_synonyms
    Localisation.new.upload_falciparum_list
    TopLevelLocalisation.new.upload_localisations
  end
  
  def localisation_signalp
    Localisation.known.all.each do |loc|
      
      # work out if it has a signal peptide
      yes = total = 0
      loc.expression_contexts.collect do |context|
        total += 1
        if context.coding_region.amino_acid_sequence.signalp?
          yes += 1
        end
      end
      
      puts [
        loc.name,
        yes.to_f / total.to_f,
        yes,
        total
      ].join("\t")
    end
  end
  
  def localisation_targetp
    Localisation.known.all.each do |loc|
      
      # work out if it has a signal peptide
      counts = {
        'M' => 0,
        '_' => 0,
        'S' => 0
      }
      total = 0
      loc.expression_contexts.collect do |context|
        total += 1
        t = context.coding_region.amino_acid_sequence.targetp
        counts[t.pred['Loc']] += 1
      end
      
      puts [
        loc.name,
        counts['M'].to_f / total.to_f,
        counts['M'],
        counts['_'].to_f / total.to_f,
        counts['_'],
        counts['S'].to_f / total.to_f,
        counts['S'],
        total
      ].join("\t")
    end
  end
  
  # Some methods to help upload the data before the localisation spreadsheet can
  # be created
  def localisation_spreadsheet_preparation
    OrthomclGene.new.link_orthomcl_and_coding_regions(['pfa'])
    seven_species_orthomcl_upload
    upload_snp_data_jeffares
    derisi_microarray_to_database2
  end
  
  def test_spreadsheet
    first = true
    # nicknames for rows that should be there
    pfemp = snp = false
    CSV.open("#{PHD_DIR}/spreadsheet/falciparum_localisation_spreadsheet20080909.tsv", 'r', "\t") do |row|
      if first
        expected = "PlasmoDB ID	Annotation	Amino Acid Sequence	Number of P. falciparum Genes in Official Orthomcl Group	Number of P. vivax Genes in Official Orthomcl Group	Number of C. parvum Genes in Official Orthomcl Group	Number of C. homonis Genes in Official Orthomcl Group	Number of T. parva Genes in Official Orthomcl Group	Number of T. annulata Genes in Official Orthomcl Group	Number of Arabidopsis Genes in Official Orthomcl Group	Number of Yeast Genes in Official Orthomcl Group	Number of Mouse Genes in Official Orthomcl Group	Number of P. falciparum Genes in 7species Orthomcl Group	Number of P. vivax Genes in 7species Orthomcl Group	Number of Babesia Genes in 7species Orthomcl Group	Number of Synonymous IT SNPs according to Jeffares et al	Number of Non-Synonymous IT SNPs according to Jeffares et al	Number of Synonymous Clinical SNPs according to Jeffares et al	Number of Non-Synonymous Clinical SNPs according to Jeffares et al	SignalP Prediction	PlasmoAP Score	DeRisi 2006 3D7 freqMAX	DeRisi 2006 3D7 powerTOTAL	DeRisi 2006 3D7 powerSIGNAL	DeRisi 2006 3D7 Percentage	DeRisi 2006 3D7 Phase	DeRisi 2006 3D7 MAX HOUR	DeRisi 2006 3D7 MIN HOUR	DeRisi 2006 3D7 AMPLITUDE	DeRisi 2006 3D7 Timepoint 1	DeRisi 2006 3D7 Timepoint 2	DeRisi 2006 3D7 Timepoint 3	DeRisi 2006 3D7 Timepoint 4	DeRisi 2006 3D7 Timepoint 5	DeRisi 2006 3D7 Timepoint 6	DeRisi 2006 3D7 Timepoint 7	DeRisi 2006 3D7 Timepoint 8	DeRisi 2006 3D7 Timepoint 9	DeRisi 2006 3D7 Timepoint 10	DeRisi 2006 3D7 Timepoint 11	DeRisi 2006 3D7 Timepoint 12	DeRisi 2006 3D7 Timepoint 13	DeRisi 2006 3D7 Timepoint 14	DeRisi 2006 3D7 Timepoint 15	DeRisi 2006 3D7 Timepoint 16	DeRisi 2006 3D7 Timepoint 17	DeRisi 2006 3D7 Timepoint 18	DeRisi 2006 3D7 Timepoint 19	DeRisi 2006 3D7 Timepoint 20	DeRisi 2006 3D7 Timepoint 21	DeRisi 2006 3D7 Timepoint 22	DeRisi 2006 3D7 Timepoint 23	DeRisi 2006 3D7 Timepoint 24	DeRisi 2006 3D7 Timepoint 25	DeRisi 2006 3D7 Timepoint 26	DeRisi 2006 3D7 Timepoint 27	DeRisi 2006 3D7 Timepoint 28	DeRisi 2006 3D7 Timepoint 29	DeRisi 2006 3D7 Timepoint 30	DeRisi 2006 3D7 Timepoint 31	DeRisi 2006 3D7 Timepoint 32	DeRisi 2006 3D7 Timepoint 33	DeRisi 2006 3D7 Timepoint 34	DeRisi 2006 3D7 Timepoint 35	DeRisi 2006 3D7 Timepoint 36	DeRisi 2006 3D7 Timepoint 37	DeRisi 2006 3D7 Timepoint 38	DeRisi 2006 3D7 Timepoint 39	DeRisi 2006 3D7 Timepoint 40	DeRisi 2006 3D7 Timepoint 41	DeRisi 2006 3D7 Timepoint 42	DeRisi 2006 3D7 Timepoint 43	DeRisi 2006 3D7 Timepoint 44	DeRisi 2006 3D7 Timepoint 45	DeRisi 2006 3D7 Timepoint 46	DeRisi 2006 3D7 Timepoint 47	DeRisi 2006 3D7 Timepoint 48	DeRisi 2006 3D7 Timepoint 49	DeRisi 2006 3D7 Timepoint 50	DeRisi 2006 3D7 Timepoint 51	DeRisi 2006 3D7 Timepoint 52	DeRisi 2006 3D7 Timepoint 53	Top Level Localisations".split("\t")
        raise Exception, "first row was expected #{expected.inspect} vs. #{row.inspect}" if row != expected
        first = false
        raise Exception, "#{expected.inspect} expected, but #{row.inspect} found." if expected != row
      end

      if row[0] == 'PFA0110w'
        raise if pfemp
        pfemp = true
        expected = "PFA0110w	(protein coding) ring-infected erythrocyte surface antigen	MRPFHAYSWIFSQQYMDTKNVKEKNPTIYSFDDEEKRNENKSFLKVLCSKRGVLPIIGILYIILNGNLGYNGSSSSGVQFTDRCSRNLYGETLPVNPYADSENPIVVSQVFGLPFEKPTFTLESPPDIDHTNILGFNEKFMTDVNRYRYSNNYEAIPHISEFNPLIVDKVLFDYNEKVDNLGRSGGDIIKKMQTLWDEIMDINKRKYDSLKEKLQKTYSQYKVQYDMPKEAYESKWTQCIKLIDQGGENLEERLNSQFKNWYRQKYLNLEEYRRLTVLNQIAWKALSNQIQYSCRKIMNSDISSFKHINELKSLEHRAAKAAEAEMKKRAQKPKKKKSRRGWLCCGGGDIETVEPQQEEPVQTVQEQQVNEYGDILPSLRASITNSAINYYDTVKDGVYLDHETSDALYTDEDLLFDLEKQKYMDMLDTSEEESVKENEEEHTVDDEHVEEHTADDEHVEEPTVADDEHVEEPTVADEHVEEPTVAEEHVEEPTVAEEHVEEPASDVQQTSEAAPTIEIPDTLYYDILGVGVNADMNEITERYFKLAENYYPYQRSGSTVFHNFRKVNEAYQVLGDIDKKRWYNKYGYDGIKQVNFMNPSIFYLLSSLEKFKDFTGTPQIVTLLRFFFEKRLSMNDLENKSEHLLKFMEQYQKEREAHVSEYLLNILQPCIAGDSKWNVPIITKLEGLKGSRFDIPILESLRWIFKHVAKTHLKKSSKSAKKLQQRTQANKQELANINNNLMSTLKEYVGSSEQMNSITYNFENINSNVDNGNQSKNISDLSYTDQKEILEKIVSYIVDISLYDIENTALNAAEQLLSDNSVDEKTLKKRAQSLKKLSSIMERYAGGKRNDKKAKKYDTQDVVGYIMHGISTINKEMKNQNENVPEHVQHNAEANVEHDAEENVEHDAEENVEENVEENVEENVEENVEENVEENVEENVEENVEENVEENVEENVEENVEENVEENVEEYDEENVEEVEENVEEYDEENVEEVEENVEENVEENVEENVEEYDEENVEEVEENVEENVEENVEENVEENVEEVEENVEENVEENVEENVEENVEENVEEYDEENVEEHNEEYDE	7	0	0	0	0	0	0	0	0	9	0	0					false	0	1.0	65.15064125	61.8514768	0.946496287	-0.213406933	53.0	33.0	4.8	0.950989117	2.547809381	2.440242599	2.132644048	2.8065786	2.92410527	2.228015733	1.618724087	1.789188313	2.282408184	1.217526673	1.233878	1.162968466	0.973226078	1.167071673	0.850600785	0.631416235	0.729440491	0.505505975	0.536052781	0.535533558	0.426743915	0.240154404	0.216655955	0.155230136	0.126317157	0.178000599	0.110052583	0.149322669	0.170624622	0.088041575	0.127260058	0.107923081	0.085341258	0.124155261	0.130252248	0.155654932	0.225190376	0.265762162	0.406316062	0.266200706	0.190359656	0.400755818	0.589980928	0.952900824	0.933452278	1.030005562	0.724372281	0.962402703	0.977516449	4.179638111	3.597917291	2.340871178	apical, exported, parasitophorous vacuole".split("\t")
        expected = expected.collect{|e| e=="" ? nil : e}
        raise Exception, "#{expected.inspect} expected, but #{row.inspect} found." if expected != row
      elsif row[0] == 'PFA0410w'
        raise if snp
        snp = true
        expected = "PFA0410w	hypothetical protein, conserved	MESYIRESKKLTLKSNKGKKLLRYLDISLNNKSLHDSHILELVKILKKIIKIVYNTYYCLNIDLSENYITCIGLKTLLKYILNYNENIGVNILKLYKNSIKDDGALLIKQLVYIQKIPMEELHLSHNLIQDNACKELLLSFVQAKKDSTYVYPRYDKYQNPYKHAQIPVWIRLEYNCIHNPKDILKEVEDCAKKKRGYKSNLIVCSALKSDKRCCPYKCLNASIRNTPIMHVYMFIHQKENIVNGKMKEEKNDFVSLEGVLDKNEKSNFNNDKNADENMIKLDSSKLGNKNKFKNENDEFEEEEEEIDVDDVDDVDDVDDVDDVDDVDDVDDDEDDEDDEDDEDDDEDDDEDDDDDEDEDDDDDEDEDDDEDDDDDEDYDDDDDEDYDEDEDDDDENYNLKDKNNLKGFENNKRIKGNKKGSEKPFVVNKEMVVENKNKNINNEEDEKNIDKKKSMNKKKRKKKKKRVNNYNNNNNINNNNNNNSNNKKKSNLVKDKKNSSTSTCNKFMNNTHNLNKSFSNIASDMYNKDTNMSSLNTSENTLPLYIILDCSAVLDMKELWKDKSILPFSFPGLLYLYNNKLLKANTIGNNNIHMNSNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNSSSGNNNTNKPGNDNFICLMCSYVANELKMVCQKSEIIRQKMINLKLNIWDKLSELGIIEFLSVPKDFKENKKNFLNSSFLTDEQIKLANEYYDISYETLQMIQFSIVWSTYIFKISNKEIIIENNKKEINKSDMKKSKKTIFTEVLYLTSSSNIYSFFEYLYEQDINFILPLCVTVNQINKYIQDEHSYIIDILMNNAKADKYGKLQFNKSFFQQFIKEKYSKYLYTNTKEEIINDKKKQSKSTLCNTKPLSCDILEQVNEEQQMFNSIKNKDGILSSQNNLQNNNGSEYLIDDGMGTMRISDDMLNNSNDIKKKKNNNNKKFSSVQQMVDNKSVAQPILSHNNNNNNNVNSINNNNNSYDIYDIISVKSFSNDNVNNMCNVDKMMNVHNNIVSSKNMKEDELLKEHHLYLKKGSEVVPNNQYYNLGEYNKLNLQMLNITDLDILEKRTDINDIFNNSLSETNKSANNTTTNNNNNNNNIHNNIHNNIHNNIHNNGAVRTNPVSSENHLILDNRNNKKKTDMLENMLYCSTVESKLMGLNKNKMEANLDMNNDNINNDNINNDHLNNDNINNVARGHTVDSELTTEDPVIQKKGVCKDKSGTPSDNKVSIYELLINAFNGKKKNVTKNVNEKNKNGVNEEGVGLMNDANCNTNNMNNVDNTNNVDNTDKLDNTDNLDNTNNVDNTNNVDNTNNVDNTNNMNNNNNMNRDDKDQSILMSQIKLKNDHRIEEEELQLKGKTNHKDNVINEKRKSMVEKKSISLHKNVNNNDNLAFLNNQQDDNVSHANHTRSTIHKMSVFHNNNMSNIPSGCAMQNDEDNMVLLGNENMLFKKGGSIMNFGDVDNNTTCAMNKNERRLTNNMKSGHNIIADNKDEELLNVEKINNGELLHIGKNICSEQLINQRKVVEWKHSFENHKVDIVNTSMLLEELILNPTVCKYVPGELYNRILKCYEKLDFMITNLNNINEEMETMKNVYNTEGNNNKNNNNNNNNEHGEHNIDNIVNKNVRTSLLKNDNIKTTTTERNNSINHSMNKNDVSMMYDDFKNYWDSPLGKNNSINNLMMMNNSINNINSGFNSMNLTASELMKSLSNGIHLNQKMNTLTSSLPHDFLLNNNMLGSMTNNNNNSNNNNNNNNSNNNNNSNNNNNSNNNNINLGMTTPLNNANIIQNHLNNSMLKNNMVNKNSAHNLASHLNNNNKVSKKKSTLSTYNNNMNEGNNSMNLNMNMNSTNNLNSSSVMMMLMNSAQNNSIQKKYINNNNNNNYNNNSNSNNNSSNSNNNNDMTVLLNNMNDVRINPNVLLNNNNLFFQGNNYKKDESNTGNKMSKDMNVINNAHANVEIMKNDNMSNNNSSNNNFVVGRDLKDIKTLNKILLLNNSNLNSVKGVSLNEKQLLNYINNNNNNSSSSSNNNMSGIPSVNSNIDTNLLTLLNMTKNNNNNNNNNNNNNNYINNIGSGINSTGISNKNLMINHQNAKNNNHNNNNNDKFKGNPFNDFNGIVTSNNIKKILNNENNNNNNLYMMNNNKTPINDINVKYVEALNSQFNFLSRDSRKIDTENNAINILNFSNDLEKKSNNTMVDICEKTNDKKI	1	1	0	0	0	0	0	0	0	1	1	0	0.97	1.8	1.0	0.92	false	0	1.0	16.54179211	15.90733899	0.961645442	1.058371784	18.0	42.0	2.9	0.708414508	0.850474392	1.164846555	1.214640754	1.349986931	1.833209262	1.694371744	1.570810607	1.807170141	2.199797692	1.657571066	1.548516884	1.53369642	1.994006464	2.202698416	1.828353161	1.849147589	2.39714168	1.873107239	2.042406007	1.738207721	1.79773823	1.52686801	1.220617631	1.238416874	0.850535574	0.934000916	0.805808757	1.12965851	3.996632785	0.604604122	0.569513843	0.485653866	0.429168049	0.413672558	0.366930112	0.434992442	0.48674689	0.44596171	0.337057639	0.235187045	0.241183843	0.286254145	0.405704757	0.368652491	0.485168222	0.596610953	0.605134095	0.465628506	0.42103379	1.062214377	0.815042508	0.735352181	exported, gametocyte surface".split("\t")
        expected = expected.collect{|e| e=="" ? nil : e}
        raise Exception, "#{expected.inspect} expected, but #{row.inspect} found." if expected != row
      end
    end
    
    raise if !pfemp
    raise if !snp
  end
  
  def top_level_localisation_overlap
    TopLevelLocalisation.known.all.each do |top|
      codes = CodingRegion.all(
        :joins => {:expressed_localisations => :malaria_localisation_top_level_localisation},
        :conditions => ['top_level_localisation_id = ?', top.id]
      )
      results = [top.name, codes.length]
      hash = {}
      
      codes.each do |code|
        code.expressed_localisations.each do |l|
          t = l.malaria_top_level_localisation
          if !t
            $stderr.puts "No top level found for #{l.inspect}"
            next
          end
          
          if t.id != top.id
            if hash[t.name].nil?
              hash[t.name] = 1
            else
              hash[t.name] += 1
            end
          end
          
        end
      end
      results.push hash.sort{|a,b|
        b[1] <=> a[1]
      }
      puts results.flatten.join("\t")
    end
  end
  
  def top_level_localisation_overlap_annotation
    TopLevelLocalisation.known.all.each do |top|
      codes = CodingRegion.all(
        :joins => {:expressed_localisations => :malaria_localisation_top_level_localisation},
        :conditions => ['top_level_localisation_id = ?', top.id]
      )
      
      codes.uniq.each do |code|
        next if code.uniq_top?
        puts [
          top.name,
          code.string_id,
          code.tops.pick(:name).uniq.sort.join(', '),
          code.annotation.annotation
        ].join("\t")
      end
    end
  end
  
  def membrane_and_other_localisations
    goods = Localisation::KNOWN_FALCIPARUM_LOCALISATIONS.reject do |l|
      l != 'endoplasmic reticulum' and l != 'golgi' and !l.match(/membrane/i) 
    end
    
    CodingRegion.species_name(Species.falciparum_name).all(
      :include => :expressed_localisations,
      :conditions => ['localisations.name in (?)', goods]
    ).each do |code|
      puts [
        code.string_id,
        code.annotation.annotation,
        code.expressed_localisations(:reload => true).pick(:name).join(",")
      ].join("\t")
    end
  end
  
  def upload_snp_data_jeffares
    # http://www.nature.com.ezproxy.lib.unimelb.edu.au/ng/journal/v39/n1/suppinfo/ng1931_S1.html
    # Supplementary Table 1, saved as csv using tab separation and no text delimiter
    good_stuff = 0
    CSV.open("#{DATA_DIR}/falciparum/polymorphism/Jeffares2007/ng1931-S4.csv", 'r', "\t") do |row|
      # skip until the useful bit
      if good_stuff == 0
        if row[0] === '#Data'
          good_stuff = 1
        end
        next
      elsif good_stuff == 1
        good_stuff += 1
        next
      end
      
      gene = row[0]
      it_syn = row[7]
      it_non_syn = row[6]
      pf_clin_syn = row[11]
      pf_clin_non_syn = row[10]
      reich_dnds = row[12]
      reich_syn = row[15]
      reich_non_syn = row[14]
      
      code = CodingRegion.ff(gene)
      if !code
        $stderr.puts "Coding region not find: #{gene}"
        next   
      end
      
      if it_syn != 'NA' and it_non_syn != 'NA'
        ItSynonymousSnp.find_or_create_by_coding_region_id_and_value(code.id, it_syn) or raise
        ItNonSynonymousSnp.find_or_create_by_coding_region_id_and_value(code.id, it_non_syn) or raise
      end
      
      if pf_clin_syn !='NA' and pf_clin_non_syn !='NA'
        PfClinSynonymousSnp.find_or_create_by_coding_region_id_and_value(code.id, pf_clin_syn) or raise
        PfClinNonSynonymousSnp.find_or_create_by_coding_region_id_and_value(code.id, pf_clin_non_syn) or raise
      end
      
      if reich_dnds != 'NA' and reich_syn != 'NA' and reich_non_syn != 'NA'
        puts "#{gene},#{code.string_id}"
        ReichenowiDnds.find_or_create_by_coding_region_id_and_value(code.id, reich_dnds) or raise
        ReichenowiNonSynonymousSnp.find_or_create_by_coding_region_id_and_value(code.id, reich_non_syn) or raise
        ReichenowiSynonymousSnp.find_or_create_by_coding_region_id_and_value(code.id, reich_syn) or raise
      end
    end
  end
  
  # print out a fasta file of all the proteins with known localisation
  # uniq_top - only print out proteins that have a single localisation
  # id_only - only use the PlasmoDB id in the name, not anything else
  def localisation_fasta(uniq_top=false, id_only=false)
    print localisation_fasta_programmatic(uniq_top, id_only)
  end
  
  def localisation_fasta_programmatic(uniq_top=false, id_only=false)
    to_return = ""
    ExpressionContext.all(:select => 'distinct(coding_region_id)').each do |context|
      code = context.coding_region
      raise Exception, "Coding region for context #{context.inspect} not found!" if !code
      
      next if uniq_top and !code.uniq_top?
      
      if id_only
        to_return.concat ">#{code.string_id}\n"
      else
        to_return.concat ">#{code.string_id}|#{code.localisation_english}|#{code.annotation.annotation}\n"
      end
      to_return.concat code.amino_acid_sequence.sequence
      to_return.concat "\n"
    end
    return to_return
  end
  
  # Print out proteins predicted to be type 2 transmembrane proteins and that are localised
  # in ApiLoc
  def type_2_localisation_fasta
    ExpressionContext.all(:select => 'distinct(coding_region_id)').each do |context|
      code = context.coding_region
      
      tmhmm_result = TmHmmWrapper.new.calculate(code.amino_acid_sequence.sequence)
      
      next if !tmhmm_result.transmembrane_type_2?
      
      raise Exception, "Coding region for context #{context.inspect} not found!" if !code
      
      puts ">#{code.string_id}|#{code.localisation_english}|#{code.annotation.annotation}"
      puts code.amino_acid_sequence.sequence
    end
  end
  
  def upload_nucleo_predictions
    CSV.open("#{DATA_DIR}/falciparum/localisation/prediction outputs/nucleoV20080902.tab",'r',"\t").each do |row|
      raise if !match = row[0].match(/^(.+?)\|(.+)$/)
      p match[0]
      p match[1]
      code = CodingRegion.ff(match[1])
      raise if !code
      NucleoNls.find_or_create_by_value_and_coding_region_id(row[1], code.id)
      NucleoNonNls.find_or_create_by_value_and_coding_region_id(row[2], code.id)
    end
  end
  
  def nucleo_test
    Localisation.known.all.each do |loc|
      total = 0
      yes = 0
      loc.expression_contexts.collect do |context|
        total += 1
        code = context.coding_region
        yes += 1 if code.nucleo_nls.value > code.nucleo_non_nls.value
      end
      
      puts [
        loc.name,
        yes.to_f / total.to_f,
        yes,
        total
      ].join("\t")
    end
  end
  
  def pats_to_database
    require 'pats'
    
    p = Bio::Pats::Report.new
    p.parse(File.open("#{DATA_DIR}/falciparum/localisation/prediction outputs/patsV20080902.1.txt").read)
    
    p.predictions.each do |pro, result|
      p pro
      code = deencode(pro)
      raise if !code
      
      PatsPrediction.find_or_create_by_value_and_coding_region_id result.prediction, code.id
      PatsScore.find_or_create_by_value_and_coding_region_id result.score, code.id
    end
  end
  
  def deencode(long_id)
    if matches = long_id.match(/^(.+?)\|/)
      return CodingRegion.ff(matches[1])
    end
    raise Exception, "Couldn't parse line: #{long_id}"
  end
  
  def pats_test
    Localisation.known.all.each do |loc|
      total = 0
      yes = 0
      loc.expression_contexts.collect do |context|
        total += 1
        code = context.coding_region
        yes += 1 if code.pats_prediction.value
      end
      
      puts [
        loc.name,
        yes.to_f / total.to_f,
        yes,
        total
      ].join("\t")
    end
  end
  
  def pprowler_to_database
    require 'pprowler'
    
    p = Bio::Pprowler::Report.new
    p.parse(File.open("#{DATA_DIR}/falciparum/localisation/prediction outputs/pprowlerV20080902.1.tab").read)
    
    p.predictions.each do |pro, result|
      code = deencode(pro)
      raise if !code
      
      PprowlerSignalScore.find_or_create_by_value_and_coding_region_id result.sp, code.id
      PprowlerMtpScore.find_or_create_by_value_and_coding_region_id result.mtp, code.id
      PprowlerOtherScore.find_or_create_by_value_and_coding_region_id result.other, code.id
    end
  end
  
  def pprowler_test
    Localisation.known.all.each do |loc|
      total = 0
      mtp = signal = other = 0
      
      CodingRegion.all(:joins => :expression_contexts, 
        :conditions => {:expression_contexts => {:localisation_id => loc.id}}).collect do |code|
        
        total += 1

        isignal = code.pprowler_signal_score.value
        imtp = code.pprowler_mtp_score.value
        iother = code.pprowler_other_score.value
        
        if imtp > isignal and imtp > iother
          mtp += 1
        elsif isignal > imtp and isignal > iother
          signal += 1
        elsif iother >isignal and iother > imtp
          other += 1
        else
          $stderr.puts "Unsure about #{code.inspect}"
        end
      end
      
      puts [
        loc.name,
        signal.to_f / total.to_f,
        #        signal,
        mtp.to_f / total.to_f,
        #        mtp,
        other.to_f / total.to_f,
        #        other,
        total
      ].join("\t")
    end
  end
  
  def destroy_dead_orthomcl_genes
    count = 0
    OrthomclGene.all(:select => 'id, orthomcl_group_id').each do |gene|
      if !gene.orthomcl_group
        gene.destroy
        count += 1
        nil # Don't retain anything
      end
    end
    puts "Deleted #{count} genes"
  end
  
  def babesia_localised_conserved
    puts [
      'Top Level Localisation',
      'Falciparum PlasmoDB ID',
      'Falciparum Common Names',
      'Falciparum Annotation',
      'Falciparum Localisations',
      'Falciparum Localisation PubMed IDs',
      'Babesia Orthologs',
      'Babesia Annotations',
      'Falciparum Paralogs'
    ].join("\t")
    TopLevelLocalisation.find_all_by_name('exported').each do |top|
      CodingRegion.top(top.name).uniq.each do |code|
        results = code.babesia_ortholog_anntoations
        if results
          puts [
            top.name,
            results
          ].flatten.join("\t")
        end
      end
    end
  end
  
  # How many are conserved across the species gap for each localisation?
  def babesia_localised_conserved_count
    puts [
      'Top Level Localisation',
      'Number Orthologues',
      'Number Known'
    ].join("\t")
    TopLevelLocalisation.all.each do |top|
      count = 0
      CodingRegion.top(top.name).uniq.each do |code|
        begin
          code.single_orthomcl(OrthomclRun.seven_species_name).orthomcl_group.orthomcl_genes.all(
            :conditions => ['orthomcl_name like ?', 'BB%']
          )
          count += 1
        rescue UnexpectedOrthomclGeneCount => e
        end
      end
      total = CodingRegion.top(top.name).count
      puts [top.name, count, total, count.to_f/total.to_f].join("\t")
    end
  end
  
  def babesia_orthologs_signal_peptides
    puts [
      'bovis id',
      'bovis annotation',
      'bovis SignalP?',
      'ortholog name',
      'ortholog SignalP?',
      'repeat for each ortholog'
    ].join("\t")
    PlasmodbGeneList.find_by_description('babesiaInteresting20080908').coding_regions.each do |code|
      results = [
        code.string_id,
        code.annotation.annotation,
        code.amino_acid_sequence.signalp?
      ]
      begin
        og = code.single_orthomcl(OrthomclRun.seven_species_filtering_name)
      
        og.orthomcl_group.orthomcl_genes.all(:conditions => ['orthomcl_name not like ?', 'BB%']).each do |gene|
          code = gene.single_code
          results.push code.string_id
          results.push code.amino_acid_sequence.signalp?
        end
      rescue UnexpectedOrthomclGeneCount => e
        $stderr.puts e
      end
      puts results.join("\t")
    end
  end
  
  
  def crypto_to_database
    #    apidb_species_to_database(Species.cryptosporidium_hominis_name, "#{DATA_DIR}/Cryptosporidium homonis/genome/cryptoDB/3.4/c_hominis_tu502.gff")
    #    puts "Uploading hominis GFF"
    #    apidb_species_to_database(Species.cryptosporidium_hominis_name, "#{DATA_DIR}/Cryptosporidium homonis/genome/cryptoDB/4.0/c_hominis_tu502.gff")
    #    puts "Uploading parvum GFF"
    #    apidb_species_to_database(Species.cryptosporidium_parvum_name, "#{DATA_DIR}/Cryptosporidium parvum/genome/cryptoDB/4.0/c_parvum_iowa_ii.gff")

    puts "Uploading FASTA files"
    crypto_fasta_to_database
  end
  
  def previous_signalp
    loc_counts = {}
    loc_totals = {}
    TopLevelLocalisation.all.each do |l|
      loc_counts[l.name] = 0
      loc_totals[l.name] = 0
    end
    CodingRegion.species_name(Species.falciparum_name).all(:include => {:expressed_localisations => :malaria_top_level_localisation}).each do |code|
      if code.uniq_top?
        loc_totals[code.tops[0].name] += 1
        if code.amino_acid_sequence.signalp?
          loc_counts[code.tops[0].name] += 1
        end
      end
    end
    
    loc_counts.each do |loc, count|
      puts [
        loc,
        count,
        loc_totals[loc],
        count.to_f / loc_totals[loc].to_f
      ].join("\t")
    end
  end
  
  def previous_plasmoap
    loc_counts = {}
    loc_totals = {}
    TopLevelLocalisation.all.each do |l|
      loc_counts[l.name] = 0
      loc_totals[l.name] = 0
    end
    CodingRegion.species_name(Species.falciparum_name).all(:include => {:expressed_localisations => :malaria_top_level_localisation}).each do |code|
      if code.uniq_top?
        loc_totals[code.tops[0].name] += 1
        if code.amino_acid_sequence.plasmo_a_p.points >= 4
          loc_counts[code.tops[0].name] += 1
        end
      end
    end
    
    loc_counts.each do |loc, count|
      puts [
        loc,
        count,
        loc_totals[loc],
        count.to_f / loc_totals[loc].to_f
      ].join("\t")
    end
  end
  
  
  def previous_exportpred
    loc_counts = {}
    loc_totals = {}
    TopLevelLocalisation.all.each do |l|
      loc_counts[l.name] = 0
      loc_totals[l.name] = 0
    end
    CodingRegion.species_name(Species.falciparum_name).all(:include => {:expressed_localisations => :malaria_top_level_localisation}).each do |code|
      if code.uniq_top?
        loc_totals[code.tops[0].name] += 1
        if code.amino_acid_sequence.exportpred.predicted?
        end
      end
    end
    
    loc_counts.each do |loc, count|
      puts [
        loc,
        count,
        loc_totals[loc],
        count.to_f / loc_totals[loc].to_f
      ].join("\t")
    end
  end
  
  # A generic method for counting up the percentages for the
  # the (unique) top level localisations
  def localisation_counts
    loc_counts = {}
    loc_totals = {}
    TopLevelLocalisation.all.each do |l|
      loc_counts[l.name] = 0
      loc_totals[l.name] = 0
    end
    CodingRegion.species_name(Species.falciparum_name).all(:include => {:expressed_localisations => :malaria_top_level_localisation}).each do |code|
      if code.uniq_top?
        loc_totals[code.tops[0].name] += 1
        if yield code
          loc_counts[code.tops[0].name] += 1
        end
      end
    end
    
    loc_counts.each do |loc, count|
      puts [
        loc,
        count,
        loc_totals[loc],
        count.to_f / loc_totals[loc].to_f
      ].join("\t")
    end
    return loc_counts, loc_totals
  end
  
  
  def predictor_orthology_paralogs_falciparum
    localisation_counts do |code|
      begin
        code.single_orthomcl.orthomcl_group.orthomcl_genes.code('pfa').count > 1
      rescue UnexpectedOrthomclGeneCount
        false
      end
    end
  end
  
  def has_orthologs_outside_of_apicomplexa
    localisation_counts do |code|
      begin
        group = code.single_orthomcl.orthomcl_group
        if group.orthomcl_genes.count > group.orthomcl_genes.codes(OrthomclGene.official_orthomcl_apicomplexa_codes).count
          true
        end
      rescue UnexpectedOrthomclGeneCount
        false
      end
    end
  end
  
  def genome_wide_has_orthologs_outside_of_apicomplexa
    count = total = 0
    CodingRegion.species_name(Species.falciparum_name).all(:select => 'coding_regions.id').each do |code|
      total += 1
      begin
        group = code.single_orthomcl.orthomcl_group
        if group.orthomcl_genes.count > group.orthomcl_genes.codes(OrthomclGene.official_orthomcl_apicomplexa_codes).count
          count += 1
        end
      rescue UnexpectedOrthomclGeneCount
        # not in the same group or not anywhere else
      end
    end
    puts [
      count,
      total,
      count.to_f/total.to_f
    ].join("\t")
  end
  
  def falciparum_non_hypothetical_count
    # Count genes that have relatives outside apicomplexa / alveolata
    collect = CodingRegion.species_name(Species.falciparum_name).all.collect do |code|
      begin
        inc = 0
        group = code.single_orthomcl.orthomcl_group
        if group.orthomcl_genes.count > group.orthomcl_genes.codes(OrthomclGene.official_orthomcl_apicomplexa_codes).count
          inc = 1
        else
        end
      rescue UnexpectedOrthomclGeneCount
      end
      inc
    end
    puts [
      collect.sum,
      collect.length,
      collect.sum.to_f / collect.length.to_f
    ].join("\t")
  end
  
  
  def localisation_timing_max
    loc_counts = {}
    TopLevelLocalisation.all.each do |l|
      loc_counts[l.name] = {}
    end
    CodingRegion.species_name(Species.falciparum_name).all(:include => {:expressed_localisations => :malaria_top_level_localisation}).each do |code|
      if code.uniq_top?
        loc = code.tops[0].name
        if timepoint = code.microarray_timepoints.first(:include => :microarray, 
            :conditions => ['microarrays.description = ? and microarray_timepoints.name = ?', Microarray.derisi_2006_3D7_default, 'MAX HOUR'])
          meas = MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(code.id, timepoint.id)
          max = meas.measurement.to_i
          p [loc, code.string_id, max]
          if loc_counts[loc][max]
            loc_counts[loc][max] += 1
          else
            loc_counts[loc][max] = 1
          end
        end
      end
    end
    
    print 'Localisation'
    (1..53).each do |j|
      print "\t#{j}."
    end
    puts
    loc_counts.each do |loc, hash|
      results = [loc]
      (1..53).each do |num|
        if hash[num]
          results.push hash[num]
        else
          results.push 0
        end
      end
      puts results.join("\t")
    end
  end
  
  def nuclear_in_vivax
    # nuclear localisation should be much easier to predict in vivax because
    # of the lower AT content.
    CodingRegion.all(
      :include => {:expressed_localisations => :malaria_top_level_localisation},
      :conditions => ['top_level_localisations.id = ?', TopLevelLocalisation.find_by_name('nucleus').id]
    ).each do |code|
      #        puts [
      #          code.string_id,
      #          code.single_orthomcl.orthomcl_group.orthomcl_genes.code('pvi').reach.orthomcl_name.gsub('pvi|','').retract.join(', ')
      #        ].join("\t")
      oes = code.single_orthomcl.orthomcl_group.orthomcl_genes.code('pvi').all
      oes.each do |ogene|
        puts ">#{code.string_id}|#{ogene.orthomcl_name}"
        puts ogene.orthomcl_gene_official_data.sequence
      end
    end
  end
  
  # Print out the mapping of high level to low level mappings in latex format
  def localisation_map_table
    TopLevelLocalisation::TOP_LEVEL_LOCALISATIONS.each do |top|
      t = TopLevelLocalisation.find_by_name(top)
      raise if !t
      
      print "#{top}"
      t.malaria_localisations.each do |m|
        puts " & #{m.name}\\\\"
      end
      puts '\hline'
    end
  end
  
  
  def yeast_gfp_er_apicomplexa_orthologues
    CodingRegion.species_name(Species.yeast_name).all(
      :select => 'coding_regions.id, coding_regions.string_id', 
      :joins => [:localisations],
      :conditions => ['localisations.id = ?', Localisation.find_by_name_or_alternate('ER').id]
    ).each do |yeast_code|
      begin
        group = yeast_code.single_orthomcl.orthomcl_group
        fals = group.orthomcl_genes.code('pfa').all
        if fals.length == 1 and group.orthomcl_genes.code('sce').count == 1 and yeast_code.localisations.length == 1
          c = fals[0].single_code
          puts ">#{c.string_id}"
          seq = c.amino_acid_sequence.sequence
          puts seq[seq.length-5..seq.length-1]
        else
          $stderr.puts "#{yeast_code.string_id} is no good - it has #{fals.length} orthomcls"
        end
      rescue UnexpectedOrthomclGeneCount => e
        $stderr.puts e
      end
    end
  end
  
  
  def experimental_align_er
    Localisation.find_by_name('endoplasmic reticulum').expressed_coding_regions.uniq.each do |code|
      puts ">#{code.string_id}"
      a = code.amino_acid_sequence.sequence
      puts a[a.length-5..a.length-1]
    end
  end
  
  def top_db_membrane_length_distribution
    dir = "#{DATA_DIR}/transmembrane/topdb/1/topdb_releases"
    counts = []
    Dir.foreach(dir) do |file|
      next if !file.match(/.xml$/) #skip non-xml files like .svn directories
      
      xml = File.open(File.join(dir, file))
      
      t = Bio::TopDb::TopDbXml.new(xml.read)
      t.transmembrane_domains.each do |tmd|
        if counts[tmd.length]
          counts[tmd.length] += 1
        else
          counts[tmd.length] = 1
        end
      end
    end
    
    (0..counts.length-1).each do |length|
      puts [
        length,
        counts[length]
      ].join("\t")
    end
  end
  
  
  def pdb_tm_membrane_length_distribution
    counts = []
    Bio::PdbTm::Xml.new(File.open("#{DATA_DIR}/transmembrane/pdbtm/20080923/pdbtmalpha.xml")).entries.each do |e|
      e.transmembrane_domains.each do |tmd|
        if counts[tmd.length]
          counts[tmd.length] += 1
        else
          counts[tmd.length] = 1
        end
      end
    end

    (0..counts.length-1).each do |length|
      puts [
        length,
        counts[length]
      ].join("\t")
    end
  end
  
  
  def parsed_full_spreadsheet
    puts [
      'Common Name(s)',
      'PlasmoDB ID',
      'Localisation',
      'PubMed Id / URL',
      'Comments'
    ].join("\t")
    ExpressionContext.all.each do |context|
      puts context.spreadsheet_english.join("\t")
    end
  end

  
  # Orthologs of all exportpred-positive falciparum
  # proteins that have better 
  def babesia_exportpred_orthologs
    puts [
      'Falciparum PlasmoDB ID',
      'Falciparum Common Names',
      'Falciparum Annotation',
      'Falciparum Experimental Localisations',
      'Falciparum Experimental Localisation Reference',
      'Babesia Orthologs',
      'Babesia Annotations',
      'Falciparum Paralogs'
    ].join("\t")
    CodingRegion.falciparum.all.each do |code|
      next if !code.amino_acid_sequence
      next if !code.amino_acid_sequence.exportpred.predicted
      puts code.babesia_ortholog_anntoations.join("\t")
    end
  end
  
  
  def export_pred_on_babesia
    CodingRegion.species_name(Species.babesia_bovis_name).all.each do |code|
      if code.amino_acid_sequence.exportpred.predicted
        puts [
          code.string_id,
          code.annotation.annotation
        ].join("\t")
      end
    end
  end
  
  
  # Download all the GO annotations for all the proteins in PDB_TM
  # and put them in the database
  def transmembrane_pdb_tm_go_annotations
    gene = Gene.new.create_dummy('pdbtm_dummy')
    go_getter = Bio::Go.new
    
    Bio::PdbTm::Xml.new(File.open("#{DATA_DIR}/transmembrane/pdbtm/20080923/pdbtmalpha.xml")).entries.each do |e|
      next if !['1su4', '1sqv'].include?(e.pdb_id) #the annoying ones
      #    Bio::PdbTm::Xml.new(File.open("lib/testFiles/pdbtmalpha.extract.xml")).entries.each do |e|
      
      # skip ones already done
      next if CodingRegion.find_by_gene_id_and_string_id(
        gene.id,
        e.pdb_id
      )
      
      # PDB entries are modelled as coding regions - it will do for now.
      code = CodingRegion.find_or_create_by_gene_id_and_string_id(
        gene.id,
        e.pdb_id
      )
      
      begin
        gos = go_getter.cc_pdb_to_go(e.pdb_id)

        gos.each do |g|
          go = GoTerm.find_or_create_by_go_identifier(g)
          CodingRegionGoTerm.find_or_create_by_coding_region_id_and_go_term_id(
            code.id, go.id
          )
        end
      
      rescue Exception
        $stderr.puts "Failed to retrieve pdb id #{e.pdb_id}"
      end
    end
  end
  
  
  def transmembrane_er_versus_plasma_membrane
    localisations = {
      'endoplasmic reticulum' => 'GO:0005783',
      'plasma membrane' => 'GO:0005886',
      'golgi apparatus' => 'GO:0005794'
    }
    
    # Print headings
    (0..36).each do |me|
      print "\t"
      print me
    end
    puts
    
    
    # Print the baseline counts, for all of pdb_tm
    lengths = []
    CodingRegion.s(Species.pdb_tm_dummy_name).all(:include => :transmembrane_domain_lengths).each do |code|
      code.transmembrane_domain_lengths.reach.measurement.each do |length|
        if lengths[length]
          lengths[length] += 1
        else
          lengths[length] = 1
        end
      end        
    end
    puts [
      'PDBTM',
      lengths
    ].flatten.join("\t")
    
    
    # Collect the coding regions in each localisation
    localisations.keys.collect do |loc|
      # get all the descendents as an array
      terms = Bio::Go.new.cellular_component_offspring(localisations[loc])

      # retrieve all the coding regions that have one or more of these descendents
      # annotated as such
      lengths = []
      CodingRegion.species_name('pdbtm_dummy').all(:include => :go_terms).each do |code|
        goods = code.go_terms.reach.go_identifier.select{|go_id| terms.include?(go_id)}
        if goods.length > 0
          code.transmembrane_domain_lengths.reach.measurement.each do |length|
            if lengths[length]
              lengths[length] += 1
            else
              lengths[length] = 1
            end
          end
        end
      end
      
      
      
      puts [
        loc,
        lengths
      ].flatten.join("\t")
    end
  end
  
  def transmembrane_er_versus_plasma_membrane_verbose
    localisations = {
      #      'endoplasmic reticulum' => 'GO:0005783',
      'plasma membrane' => 'GO:0005886',
      #      'golgi apparatus' => 'GO:0005794'
    }
    
    puts [
      'Localisation',
      #      'PDB',
      'TMDLength'
    ].join("\t")
    
    # Print the baseline counts, for all of pdb_tm
    #    lengths = []
    #    CodingRegion.s(Species.pdb_tm_dummy_name).all(:include => :transmembrane_domain_lengths).each do |code|
    #      code.transmembrane_domain_lengths.reach.measurement.each do |length|
    #        if lengths[length]
    #          lengths[length] += 1
    #        else
    #          lengths[length] = 1
    #        end
    #      end        
    #    end
    #    puts [
    #      'PDBTM',
    #      lengths
    #    ].flatten.join("\t")
    
    
    # Collect the coding regions in each localisation
    localisations.keys.collect do |loc|
      # get all the descendents as an array
      terms = Bio::Go.new.cellular_component_offspring(localisations[loc])

      # retrieve all the coding regions that have one or more of these descendents
      # annotated as such
      CodingRegion.species_name('pdbtm_dummy').all(:include => :go_terms).each do |code|
        goods = code.go_terms.reach.go_identifier.select{|go_id| terms.include?(go_id)}
        if goods.length > 0
          code.transmembrane_domain_lengths.reach.measurement.each do |length|
            puts [
              loc.gsub(' ','_'), 
              #              code.string_id, 
              length.to_i
            ].join("\t")
          end
        end
      end
    end
  end
    
  def transmembrane_er_versus_plasma_membrane_first
    localisations = {
      'endoplasmic reticulum' => 'GO:0005783',
      'plasma membrane' => 'GO:0005886',
      'golgi apparatus' => 'GO:0005794'
    }
    
    puts [
      'Localisation',
      #      'PDB',
      'First TMD Length'
    ].join("\t")
    
    # Print the baseline counts, for all of pdb_tm
    #    lengths = []
    #    CodingRegion.s(Species.pdb_tm_dummy_name).all(:include => :transmembrane_domain_lengths).each do |code|
    #      code.transmembrane_domain_lengths.reach.measurement.each do |length|
    #        if lengths[length]
    #          lengths[length] += 1
    #        else
    #          lengths[length] = 1
    #        end
    #      end        
    #    end
    #    puts [
    #      'PDBTM',
    #      lengths
    #    ].flatten.join("\t")
    
    
    # Collect the coding regions in each localisation
    localisations.keys.collect do |loc|
      # get all the descendents as an array
      terms = Bio::Go.new.cellular_component_offspring(localisations[loc])

      # retrieve all the coding regions that have one or more of these descendents
      # annotated as such
      CodingRegion.species_name('pdbtm_dummy').all(:include => :go_terms).each do |code|
        goods = code.go_terms.reach.go_identifier.select{|go_id| terms.include?(go_id)}
        if goods.length > 0
          tmd = code.transmembrane_domain_lengths.first(:order => 'id')
          puts [
            loc.gsub(' ','_'), 
            #              code.string_id, 
            tmd.measurement.to_i
          ].join("\t")
        end
      end
    end
  end
  
  
  # Upload Wormbase genes, proteins and go terms from scratch
  def upload_elegans_go_terms_and_genes
    genes = Bio::WormbaseGoFile.new("#{DATA_DIR}/elegans/wormbase/WS194/annotations/gene_ontology/c_elegans.WS194.gene_ontology.txt").genes
    
    protein_names = []
    File.open("#{DATA_DIR}/elegans/wormbase/WS191/cel_protein-coding_geneids_v191").each do |line|
      protein_names.push line.strip
    end
    
    #    #    $ grep WBGene GO.WS190.txt |wc -l
    #  #31499
    #    #$ grep WBGene GO.WS187.txt |wc -l
    #    #31316
    #    if genes.length != 31316
    #      raise Exception, "Unexpected number of genes found in GO file."
    #    end
    

    sp = Species.find_or_create_by_name(Species.elegans_name)
    raise if sp.scaffolds.length > 1 #make sure we are still hacking this stuff
    scaf = Scaffold.find_or_create_by_species_id_and_name(sp.id, Species.elegans_name)
    
    genes.each do |gene|
      # Ignore genes not given to me by Maria
      next if !protein_names.include?(gene.gene_name)
      gd = Gene.find_or_create_by_name_and_scaffold_id(gene.gene_name, scaf.id)
      cd = CodingRegion.find_or_create_by_string_id_and_gene_id(gene.protein_name, gd.id)
      CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(cd.id, gene.gene_name)
      gene.go_identifiers.each do |go_id|
        g = GoTerm.find_or_create_by_go_identifier(go_id)
        CodingRegionGoTerm.find_or_create_by_go_term_id_and_coding_region_id_and_evidence_code(
          g.id, cd.id, go_id
        )
      end
    end
  end
  
  def check_elegans_go
    genes = Bio::WormbaseGoFile.new("/home/ben/phd/data/elegans/wormbase/WS187/annotations/GO/GO.WS187.txt").genes

    genes.each do |gene|
      if gene.protein_name and !gene.go_identifiers.empty? and !CodingRegion.fs(gene.protein_name, Species.elegans_name)
        puts gene.gene_name
      end
    end
  end
  
  # Print out a list of elegans genes classed as enzymes, gpcr, etc. - stuff that is assayable
  def elegans_enzyme_genes
    go_getter = Bio::Go.new
    gos = [
      #      'GO:0005215', #transport
      # 'GO:0004930', # G-Protein Coupled Receptors
      'GO:0003824' # Enzyme
    ]
    good_gos = []
    gos.each do |go|
      good_gos = [
        good_gos, 
        go_getter.molecular_function_offspring(go)
      ].uniq.flatten
    end
    CodingRegion.s(Species.elegans_name).all.each do |code|
      yes = false
      code.go_terms.reach.go_identifier.each do |go|
        if good_gos.include?(go)
          yes = true
        end
      end
      if yes
        puts [
          code.gene.name,
          code.string_id
        ].join("\t")
      end
    end
  end
  
  def check_elegans_protein_coding_differences
    File.open("#{DATA_DIR}/elegans/wormbase/WS191/cel_protein-coding_geneids_v191").each do |line|

      line.strip!
      if !CodingRegion.fs(line, Species.elegans_name)
        puts line
      end
    end
  end

  def enzyme_go_ids_and_descriptions
    go_getter = Bio::Go.new
    gos = [
      #      'GO:0005215', #transport
      #'GO:0004930', # G-Protein Coupled Receptors
      'GO:0003824' # Enzyme
    ]
    good_gos = []
    gos.each do |go|
      good_gos = [
        good_gos, 
        go_getter.molecular_function_offspring(go)
      ].flatten.sort.uniq
    end
    
    good_gos.each do |go_id|
      puts [
        go_id,
        go_getter.term(go_id)
      ].join("\t")
    end
  end

  def go_synonym_hypothesis
    gos = %w(GO:0048253 GO:0046971 GO:0046913 GO:0047984 GO:0050517 GO:0047752 GO:0047477 GO:0047340 GO:0047523 GO:0047226 GO:0048059 GO:0047737 GO:0046407 GO:0046420 GO:0050222 GO:0047607 GO:0045546 GO:0050443 GO:0047767 GO:0050375 GO:0048044 GO:0048043 GO:0050475 GO:0050516 GO:0047076 GO:0047318 GO:0047314)
    go_getter = Bio::Go.new
    
    puts '------Email GO Term Testing----------'
    gos.each do |g|
      begin
        if go_getter.primary_go_id(g) == g
          puts "#{g} found as a primary id!"
        end
      rescue RException
        puts "#{g} raised exception - too new for GO.db R library?"
      end
    end
    
    puts '------Text File Testing----------'
    File.open("#{PHD_DIR}/essentiality/goidsNOTin_ben_list.txt").each do |g|
      begin
        g.strip!
        if go_getter.primary_go_id(g) == g
          puts "#{g} found as a primary id!"
        end
      rescue RException
        puts "#{g} raised exception - too new for GO.db R library?"
      end      
    end
  end  
  
  # Upload all the data from Winzeler 2005 experiments downloaded from
  # http://carrier.gnf.org/publications/CellCycle/index.html
  def winzeler_2003_measurements_to_database
    base_dir = "#{DATA_DIR}/falciparum/microarray/Winzeler2003"
    microarray = Microarray.find_or_create_by_description(Microarray::WINZELER_2003_NAME)
    sporozoite_replicate = 1
    
    # the original Description&Normalization.txt was originally created using a mixture of tabs and spaces
    # I converted them all to tabs so it now makes sense.
    FasterCSV.foreach("#{base_dir}/Description&Normalization.tabbed.txt", :col_sep => "\t", :headers => true) do |description_row|
      description = description_row[4]
      if description.match(/Sporozoite/)
        description = "#{description} #{sporozoite_replicate}"
        sporozoite_replicate += 1
      else
        next #just uploading sporozoite replicates right now as a fix
      end
      
      timepoint = MicroarrayTimepoint.find_or_create_by_name_and_microarray_id(description, microarray.id)
      
      FasterCSV.foreach("#{base_dir}/#{description_row[0]}.tsv", :col_sep => "\t") do |entry|
        code = CodingRegion.ff(entry[0])
        
        if !code
          $stderr.puts "Couldn't find coding region '#{entry[0]}'"
          next
        end
        
        levels = entry[6].split(',')
        raise Exception, "Mismatch on the number of levels and apparent number of levels for #{entry[0]}" if entry[5].to_i != levels.length
        
        # Cannot do find_or_create here because you might get the same measurement twice in the same go.
        levels.each do |level|
          MicroarrayMeasurement.create!(
            :coding_region_id => code.id,
            :measurement => level,
            :microarray_timepoint_id => timepoint.id
          )
        end
      end
    end
  end
      
  def elegans_specific_by_orthomcl
    OrthomclGene.code('cel').all({:include => :orthomcl_group}).reach.orthomcl_group.reject {|g|
      # Reject if the count of cel genes is different to the count of all genes in the group
      g.orthomcl_genes.code('cel').count != g.orthomcl_genes.count
    }.uniq{|a,b| a.id == b.id}.collect do |uniq_gene|
      yield uniq_gene
    end
  end
  
  
  def voss_nuclear_proteome_2008_upload
    codes = []
    FasterCSV.foreach("#{DATA_DIR}/falciparum/proteomics/VossNuclearProteome/October2008List.csv",
      :col_sep => "\t", :headers => true) do |row|
      codes.push row['Protein AC']
    end
    
    PlasmodbGeneList.create_gene_list(PlasmodbGeneList::VOSS_NUCLEAR_PROTEOME_OCTOBER_2008, Species::FALCIPARUM, codes)
    
    puts "Done. Checking.."
    Verification.new.voss_nuclear_proteome_2008_upload
  end
  

  # for each of the nuclear proteins in the proteomics list, print out the average and list of winzeler 2003 cell
  # cycle absolute counts
  def nuclear_proteome_winzeler_data

    
    array_constants = [
      WINZELER_2003_EARLY_RING_SORBITOL,
      WINZELER_2003_LATE_RING_SORBITOL,
      WINZELER_2003_EARLY_TROPHOZOITE_SORBITOL,
      WINZELER_2003_LATE_TROPHOZOITE_SORBITOL,
      WINZELER_2003_EARLY_SCHIZONT_SORBITOL,
      WINZELER_2003_LATE_SCHIZONT_SORBITOL,
      WINZELER_2003_MEROZOITE_SORBITOL,
      WINZELER_2003_EARLY_RING_TEMPERATURE,
      WINZELER_2003_LATE_RING_TEMPERATURE,
      WINZELER_2003_EARLY_TROPHOZOITE_TEMPERATURE,
      WINZELER_2003_LATE_TROPHOZOITE_TEMPERATURE,
      WINZELER_2003_EARLY_SCHIZONT_TEMPERATURE,
      WINZELER_2003_LATE_SCHIZONT_TEMPERATURE,
      WINZELER_2003_MEROZOITE_TEMPERATURE,

      WINZELER_2005_GAMETOCYTE_NF54_DAY_1,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_2,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_3,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_4,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_5,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_6,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_7,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_8,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_9,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_10,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_11,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_12,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_13
    ]
    
    # Headers
    puts [
      'PlasmoDB ID',
      array_constants
    ].flatten.join("\t")
    
    # For each gene in the proteome list
    PlasmodbGeneList.find_by_description(PlasmodbGeneList::VOSS_NUCLEAR_PROTEOME_OCTOBER_2008).coding_regions.falciparum.all(
      :order => 'plasmodb_gene_list_entries.id').each do |code|
      results = [code.string_id]
      
      array_constants.each do |timepoints|
        results.push code.microarray_measurements.timepoint_names([timepoints].flatten).all.reach.percentile.average
      end
      
      puts results.join("\t")
    end
  end
  
  def nuclear_proteome_winzeler_classification
    
  end

  def elegans_only_and_lethal
    #    elegans_specific_by_orthomcl do ||
  end
  
  def nuclear_wolf_psort_accuracy
    Bio::PSORT::WoLF_PSORT::ORGANISM_TYPES.each do |organism_type|
      tp = fp = tn = fn = 0
      
      CodingRegion.falciparum.all(:joins => :expression_contexts).uniq.each do |code|
        # if nuclear prediction
        tops = code.expressed_localisations.reach.malaria_top_level_localisation.retract.reject{|t| t.nil?} #reject those that don't have top level locs
        
        if tops.reach.name.include?('nucleus')
          if code.cached_wold_psort_localisation(organism_type) == 'nucl'
            tp += 1
          else
            fn += 1
          end
          
        else # not nuclear at all
          if code.cached_wold_psort_localisation(organism_type) == 'nucl'
            fp += 1
          else
            tn += 1
          end
        end
      end
      
      p = PredictionAccuracy.new(tp, fp, tn, fn)
      puts "#{organism_type}:"
      puts p.to_s
      puts
    end
  end
  
  def nuclear_wolf_psort_accuracy_no_signal
    Bio::PSORT::WoLF_PSORT::ORGANISM_TYPES.each do |organism_type|
      tp = fp = tn = fn = 0
      
      CodingRegion.falciparum.all(:joins => :expression_contexts).uniq.each do |code|
        # if nuclear prediction
        tops = code.expressed_localisations.reach.malaria_top_level_localisation.retract.reject{|t| t.nil?} #reject those that don't have top level locs
        next if code.signalp?
        
        if tops.reach.name.include?('nucleus')
          if code.cached_wold_psort_localisation(organism_type) == 'nucl'
            tp += 1
          else
            fn += 1
          end
          
        else # not nuclear at all
          if code.cached_wold_psort_localisation(organism_type) == 'nucl'
            fp += 1
          else
            tn += 1
          end
        end
      end
      
      p = PredictionAccuracy.new(tp, fp, tn, fn)
      puts "#{organism_type}:"
      puts p.to_s
      puts
    end
  end
  


  # Find groups where there is a falciparum and toxo, but no
  # blargh - just realised toxo is not in the 7 species, making this harder.
  # Will need to rerun the the blast with toxo included
  def babesia_loss
    
  end  
  
  def falciparum_simple_fasta
    CodingRegion.s(Species::FALCIPARUM_NAME).all(:joins => :amino_acid_sequence).each do |code|
      puts ">pfa|#{code.string_id}"
      puts code.amino_acid_sequence.sequence
    end
  end
  
  # How good is the predictor that predicts uses the toxo ortholog's psort prediction as the predictor?
  def toxo_to_falciparum_nuclear_prediction
    Bio::PSORT::WoLF_PSORT::ORGANISM_TYPES.each do |organism_type|
      tp = fp = tn = fn = 0
      no_orthologue_count = 0
      
      CodingRegion.falciparum.all(:joins => {:expressed_localisations => :malaria_top_level_localisation}).uniq.each do |code|
        # Reject from all prediction where there is not exactly 1 toxo orthologue
        toxos = []
        begin
          toxos = code.single_orthomcl.orthomcl_group.orthomcl_genes.code('tgo').all
        rescue CodingRegion::UnexpectedOrthomclGeneCount
        end
        
        if toxos.length != 1
          no_orthologue_count += 1
          next 
        end
        toxo = toxos[0].single_code
        
        # if nuclear prediction
        tops = code.expressed_localisations.reach.malaria_top_level_localisation.retract.reject{|t| t.nil?} #reject those that don't have top level locs
        
        if tops.reach.name.include?('nucleus')
          if toxo.cached_wold_psort_localisation(organism_type) == 'nucl'
            tp += 1
          else
            fn += 1
          end
          
        else # not nuclear at all
          if toxo.cached_wold_psort_localisation(organism_type) == 'nucl'
            fp += 1
          else
            tn += 1
          end
        end
      end
      
      p = PredictionAccuracy.new(tp, fp, tn, fn, no_orthologue_count)
      puts "#{organism_type}:"
      puts p.to_s
      puts
    end
  end
  
  # How good is the predictor that predicts uses the toxo ortholog's psort prediction as the predictor?
  def toxo_to_falciparum_nuclear_prediction_no_signal
    Bio::PSORT::WoLF_PSORT::ORGANISM_TYPES.each do |organism_type|
      tp = fp = tn = fn = 0
      no_orthologue_count = 0
      
      CodingRegion.falciparum.all(:joins => {:expressed_localisations => :malaria_top_level_localisation}).uniq.each do |code|
        # Reject from all prediction where there is not exactly 1 toxo orthologue
        toxos = []
        begin
          toxos = code.single_orthomcl.orthomcl_group.orthomcl_genes.code('tgo').all
        rescue CodingRegion::UnexpectedOrthomclGeneCount
        end
        
        if toxos.length != 1
          no_orthologue_count += 1
          next 
        end
        toxo = toxos[0].single_code
        
        # if nuclear prediction
        tops = code.expressed_localisations.reach.malaria_top_level_localisation.retract.reject{|t| t.nil?} #reject those that don't have top level locs
        next if code.signalp?
        
        if tops.reach.name.include?('nucleus')
          if toxo.cached_wold_psort_localisation(organism_type) == 'nucl'
            tp += 1
          else
            fn += 1
          end
          
        else # not nuclear at all
          if toxo.cached_wold_psort_localisation(organism_type) == 'nucl'
            fp += 1
          else
            tn += 1
          end
        end
      end
      
      p = PredictionAccuracy.new(tp, fp, tn, fn, no_orthologue_count)
      puts "#{organism_type}:"
      puts p.to_s
      putsg
    end
  end
  
  # generate the files necessary to run a prediction run
  # in LIBSVM format
  def gmars_exported
    gmars = GMARS.new
    
    (0..6).each do |max_gap|
      puts "Gap #{max_gap}"
      
      exported_count = other_count = 0
      f = File.open("../svm/gmars/apiloc.exportedVothers.gap#{max_gap}.txt", 'w')
    
      CodingRegion.s(Species::FALCIPARUM).all(
        :joins => :expressed_localisations
      ).each do |code|
        next if !code.uniq_top? #skip dual localised for the moment
      
        if code.tops[0].name == 'exported'
          f.puts code.gmars_vector(max_gap, gmars).libsvm_format(1)
          exported_count += 1
        else
          next if 
          f.puts code.gmars_vector(max_gap, gmars).libsvm_format(-1)
          other_count += 1
        end
      end
    end
  end
  
  # generate the files necessary to run a prediction run
  # in LIBSVM format
  def gmars_arff
    gmars = GMARS.new
    
    
    raise Exception, "too many lines output from each I think - doubtful this routine is bug free"
    
    top_hash = {}
    TopLevelLocalisation.all.each_with_index do |top, index|
      i = index+1
      top_hash[top] = i
      puts [top.name, i].join(' - ')
    end
    
    (0..6).each do |max_gap|
      puts "Gap #{max_gap}"
      
      f = File.open("../svm/gmars/apiloc.all_localisationss.gap#{max_gap}.txt", 'w')
    
      CodingRegion.s(Species::FALCIPARUM).all(
        :joins => :expressed_localisations
      ).each do |code|
        next if !code.uniq_top? #skip dual localised for the moment
      
        f.puts code.gmars_vector(max_gap, gmars).libsvm_format(top_hash[code.tops[0]])
      end
    end
  end
    
  
  def golgi_consensus_falciparum
    # May as well run the upload of the signals because it is fast and easy
    GolgiNTerminalSignal.new.florian_fill
    GolgiCTerminalSignal.new.florian_fill
    
    signals = [GolgiNTerminalSignal.all, GolgiCTerminalSignal.all].flatten.reach.regex
     
    puts [
      'PlasmoDB ID',
      'Annotation',
      'Confirmed Localisations',
      'GPI Anchor (Predicted by Gilson et al 2006)',
      'TMHMM2 Type I/II',
      'TMHMM2 TMD Length',
      'TMHMM2 TMD Start',
      'TMHMM2 TMD End',
      'Protein Length',
      'Signal Peptide by SignalP 3.0?',
      'ExportPred Prediction',
      'Published in PEXEL List',
      'Published in HT List',
      signals.collect{|s| s.inspect}
    ].flatten.join("\t")
     
    gpi_list = PlasmodbGeneList.find_by_description "Gilson Published GPI 2006"
    
    CodingRegion.s(Species::FALCIPARUM_NAME).all(
      :include => [:amino_acid_sequence, :annotation]
    ).each do |code|
      # ignore surface crap and pseudogenes
      next if code.falciparum_cruft?
      
      # I only care about the protein minus the signal peptide
      next unless code.aaseq
      sp = code.signalp
      seq = code.aaseq
      seq = sp.cleave(seq) if sp.signal?
      
      # only count those that are predicted to have 1 TMD by TMHMM2
      tmhmm_result = TmHmmWrapper.new.calculate(seq)
      next unless tmhmm_result.transmembrane_domains.length == 1
      
      # fill in columns as possible
      m = [
        code.string_id,
        code.annotation.annotation,
        code.expressed_localisations.reach.name.join(', '),
        gpi_list.coding_regions.include?(code) ? 'GPI' : 'no GPI',
        tmhmm_result.transmembrane_type,
        tmhmm_result.transmembrane_domains[0].length,
        tmhmm_result.transmembrane_domains[0].start,
        tmhmm_result.transmembrane_domains[0].stop,
        code.aaseq.length,
        sp.signal?,
        code.amino_acid_sequence.exportpred.predicted?,
        !CodingRegion.list('pexelPlasmoDB5.5').find_by_id(code.id).nil?,
        !CodingRegion.list('htPlasmoDB5.5').find_by_id(code.id).nil?
      ]
      
      # fill in the golgi signal peptides
      signals.each do |signal|
        if code.aaseq and matches = code.aaseq.match(/(#{signal})/)
          m.push matches[1]
        else
          m.push nil
        end
      end
      puts m.join("\t")
    end
  end
  
  
  def upload_gilson_gpi_list
    l = PlasmodbGeneList.find_or_create_by_description("Gilson Published GPI 2006")
    File.open("#{DATA_DIR}/falciparum/localisation/Gilson2006Apr7.GPI.list.csv").each do |line|
      p line
      code = CodingRegion.ff(line.strip)
      raise if !code
      PlasmodbGeneListEntry.find_or_create_by_plasmodb_gene_list_id_and_coding_region_id(
        l.id, code.id
      )
    end
  end
    
  # Collect results for candidates for sequencing
  def babesia_apicoplast_candidate_selection
    auto_babesia_candidates.each do |c|
      puts [
        c.query_def, 
        c.hit_def, 
        c.nterminal_query_start, 
        c.nterminal_hit_start, 
        c.difference,
        c.bl2seq_result.hits.length,
        c.bl2seq_result.hits[0].hsps.length,
        c.bl2seq_result.shuffled_start?
      ].join("\t")
    end
  end
  
  def auto_babesia_candidates
    #   1. Get all the genes that blast against the falciparum high and low confidence orthologs using 7 species orthomcl
    groups = OrthomclGroup.run(OrthomclRun.seven_species_filtering_name).all(
      :joins => {:orthomcl_genes => {:coding_regions => :plasmodb_gene_lists}},
      :conditions => ['(plasmodb_gene_lists.description = ?'+
          ' or plasmodb_gene_lists.description = ?)'+
          ' and orthomcl_runs.name = ?', 
        'Pvi_Pfa_Tpa_HIGH_confid_set3', 'Pvi_Pfa_Tpa_LOWER_confid_set',
        OrthomclRun.seven_species_filtering_name
      ]
    )
    
    babesias = groups.select{|g| 
      g.orthomcl_genes.count(:conditions => ['orthomcl_genes.orthomcl_name like ? ', 'BBOV%'])>0
    }.collect{|group|
      group.orthomcl_genes.first(:conditions => ['orthomcl_genes.orthomcl_name like ? ', 'BBOV%'])
    }
    m = []
    
    
    babesia_with_signal_peptides_count = 0
    babesia_without_falciparum_hit_count = 0
      
    babesias.uniq!
    $stderr.puts "Number of babesia orthologs in total: #{babesias.length}"
    
    babesias.each do |og|
      code = og.single_code #raises exception if something is askew
      
      #   2. discard if the babesia gene has a signal peptide
      if code.signalp.signal?
        babesia_with_signal_peptides_count += 1
      end
      
      #   3. bl2seq the babesia gene against the falciparum gene. Discard if there is no overhang
      falciparums = og.orthomcl_group.orthomcl_genes.all(
        :joins => {:coding_regions => {:gene => {:scaffold => :species}}},
        :conditions => ['species.name = ?', Species::FALCIPARUM_NAME]
      )
      # skip where there is no orthologs
      next if falciparums.length == 0
      
      # if there are multiple orthologs choose the best one by blasting them
      fal = nil
      if falciparums.length > 1
        fal = code.amino_acid_sequence.best_bl2seq(falciparums.reach.single_code.amino_acid_sequence.retract)[0].coding_region
      else
        fal = falciparums[0].single_code
      end
      
      bl2seq = fal.amino_acid_sequence.blastp(code.amino_acid_sequence, :evalue => 1e-5)
      if bl2seq.hits.empty?
        babesia_without_falciparum_hit_count += 1
      else
        m.push Bio::Blast::Bl2seq::BabesiaCandidateWrapper.new(
          bl2seq,
          fal.amino_acid_sequence.fasta,
          code.amino_acid_sequence.fasta
        )
      end
      #      return m
    end
    
    $stderr.puts "Babesias with signal peptides: #{babesia_with_signal_peptides_count}"
    $stderr.puts "Babesia without decent falciparum hit: #{babesia_without_falciparum_hit_count}"
    
    return m
  end
  
  # WARNING: Run once only!
  def update_falciparum_to_5p5
    raise if Species.find_by_name('falciparum v5.4')
    four = Species.find_by_name(Species::FALCIPARUM_NAME)
    four.name = 'falciparum v5.4'
    four.orthomcl_three_letter = nil
    four.save
    
    five = Species.find_or_create_by_name(
      Species::FALCIPARUM
    )
    
    falciparum_to_database
    falciparum_fasta_to_database
  end
  
  def florian_thanks_in_advance
    puts PlasmodbGeneList.find_by_description('florian temp').coding_regions.collect {|code|
      if code.orthomcl_genes.official.count == 0
        "#{code.string_id}\tno orthomcl group"
      else
        group = code.single_orthomcl.orthomcl_group
        [
          code.string_id,
          group.orthomcl_genes.code('sce').all.reach.orthomcl_name.join(', '), 
          group.orthomcl_genes.code('ath').all.reach.orthomcl_name.join(', '), 
          group.orthomcl_genes.code('hsa').all.reach.orthomcl_name.join(', '),
          group.orthomcl_genes.codes(OrthomclGene.official_orthomcl_apicomplexa_codes).all.reach.orthomcl_name.join(', '),
          group.orthomcl_genes.all.reach.orthomcl_name.reject{|name| 
            ['sce','ath','hsa',OrthomclGene.official_orthomcl_apicomplexa_codes].flatten.include?(name[0..2])
          }.join(', ')
        ].join("\t")
      end
    }.join("\n")
  end
  
  def testa
    c1 = CodingRegion.f('BBOV_III011730')
    c2 = CodingRegion.f('MAL7P1.92')
    code = c2
    fal = c1

    puts code.amino_acid_sequence.blastp(fal.amino_acid_sequence, {:evalue => 1e-5}).shuffled_start?
  end
  
  def babesia_apicoplast_signal_peptide_plasmo_ap_scores
    #   1. Get all the genes that blast against the falciparum high and low confidence orthologs using 7 species orthomcl
    groups = OrthomclGroup.run(OrthomclRun.seven_species_filtering_name).all(
      :joins => {:orthomcl_genes => {:coding_regions => :plasmodb_gene_lists}},
      :conditions => ['(plasmodb_gene_lists.description = ?'+
          ' or plasmodb_gene_lists.description = ?)'+
          ' and orthomcl_runs.name = ?', 
        'Pvi_Pfa_Tpa_HIGH_confid_set3', 'Pvi_Pfa_Tpa_LOWER_confid_set',
        OrthomclRun.seven_species_filtering_name
      ]
    )
    
    babesias = groups.select{|g| 
      g.orthomcl_genes.count(:conditions => ['orthomcl_genes.orthomcl_name like ? ', 'BBOV%'])>0
    }.collect{|group|
      group.orthomcl_genes.first(:conditions => ['orthomcl_genes.orthomcl_name like ? ', 'BBOV%'])
    }
    
    babesias.uniq!
    
    babesias.each do |bab|
      code = bab.single_code
      puts [
        code.signalp.signal?,
        code.amino_acid_sequence.plasmo_a_p.points
      ].join("\t")
    end
  end
  
  def localisation_libsvm_normalised
    raise Exception, "No longer maintained - use ARFF instead"
    
    # headings
    headings = [
      #      'PlasmoDB ID',
      #      'Annotation',
      #      'Top Level Localisations',
      #      'Amino Acid Sequence',
      #      'Class',
      'SignalP Prediction',
      'PlasmoAP Score'
    ]
    #    Bio::PSORT::WoLF_PSORT::ORGANISM_TYPES.each do |organism|
    #      Bio::PSORT::WoLF_PSORT::LOCALISATIONS.each do |loc|
    #        headings.push "WoLF PSORT Prediction #{organism}: #{loc}"
    #      end
    #    end
    headings.push [
      'Number of P. falciparum Genes in Official Orthomcl Group', #orthomcl
      'Number of P. vivax Genes in Official Orthomcl Group',
      'Number of C. parvum Genes in Official Orthomcl Group',
      'Number of C. homonis Genes in Official Orthomcl Group',
      'Number of T. parva Genes in Official Orthomcl Group',
      'Number of T. annulata Genes in Official Orthomcl Group',
      'Number of Arabidopsis Genes in Official Orthomcl Group',
      'Number of Yeast Genes in Official Orthomcl Group',
      'Number of Mouse Genes in Official Orthomcl Group',
      'Number of P. falciparum Genes in 7species Orthomcl Group', #7species orthomcl
      'Number of P. vivax Genes in 7species Orthomcl Group',
      'Number of Babesia Genes in 7species Orthomcl Group',
      'Number of Synonymous IT SNPs according to Jeffares et al', #SNP Data
      'Number of Non-Synonymous IT SNPs according to Jeffares et al',
      'Number of Synonymous Clinical SNPs according to Jeffares et al',
      'Number of Non-Synonymous Clinical SNPs according to Jeffares et al',
    ]
    #    derisi_timepoints = Microarray.find_by_description(Microarray.derisi_2006_3D7_default).microarray_timepoints(:select => 'distinct(name)')
    derisi_timepoints = Microarray.find_by_description(Microarray.derisi_2006_3D7_default).microarray_timepoints(:select => 'distinct(name)', 
      :conditions => ['microarray_timepoints.name = ?', 'Phase']
    )
    headings.push derisi_timepoints.collect{|t| 
      'DeRisi 2006 3D7 '+t.name
    }
    
    headings = headings.flatten #The length of headings array is used later as a check, so need to actually modify it here
    #puts headings.join(sep)
    all_results = []
    all_result_classes = []
    
    # genes that are understandably not in the orthomcl databases, because
    # they were invented in plasmodb 5.4 and weren't present in 5.2. Might be worth investigating
    # if any of them has any old names that were included, but meh for the moment.
    fivepfour = ['PFL0040c', 'PF14_0078', 'PF14_0744','PF10_0344','PFD1150c','PFD1145c','PFD0110w','PFI1780w','PFI1740c','PFI0105c','PFI0100c','MAL7P1.231']
    # Genes that have 2 orthomcl entries but only 1 plasmoDB entry
    merged_genes = ['PFD0100c']
    
    localisation_to_index_hash = TopLevelLocalisation::TOP_LEVEL_LOCALISATIONS.to_hash
    
    # For all genes that only have 1 localisation
    CodingRegion.species_name(Species.falciparum_name).all(
      :joins => {:expressed_localisations => :malaria_top_level_localisation}
    ).uniq.each do |code|
      
      results = [
        #        code.string_id,
        #        code.annotation.annotation,
        #        code.tops.pick(:name).uniq.sort.join(', '),  # Top level localisations
        #        code.amino_acid_sequence.sequence,
      ]
      
      # ignore little loved locs and multiple localisations
      next unless code.uniq_top?
      
      # SignalP
      results.push(
        code.signalp_however.signal? ? 1 : 0
      )
      
      # PlasmoAP
      results.push code.amino_acid_sequence.plasmo_a_p.points
      
      #WoLF_PSORT
      #      Bio::PSORT::WoLF_PSORT::ORGANISM_TYPES.each do |organism|
      #        Bio::PSORT::WoLF_PSORT::LOCALISATIONS.each do |loc|
      #          if code.wolf_psort_localisations(organism).include?(loc)
      #            headings.push 1
      #          else
      #            headings.push 0
      #          end
      #        end
      #      end
      #      results.push code.wolf_psort_localisation('plant')
      #      results.push code.wolf_psort_localisation('animal')
      #      results.push code.wolf_psort_localisation('fungi')
      
      # official orthomcl
      interestings = ['pfa','pvi','cpa','cho','the','tan','ath','sce','mmu']
      
      # Some genes have 2 entries in orthomcl, but only 1 in plasmodb 5.4
      if merged_genes.include?(code.string_id)
        # Fill with non-empty cells
        group = code.orthomcl_genes[0].orthomcl_group
        interestings.each do |three|
          if group.orthomcl_genes.code(three).length>0
            results.push 1
          else
            results.push 0
          end
        end        
      elsif !fivepfour.include?(code.string_id) and single = code.single_orthomcl 
        # Fill with non-empty cells
        group = single.orthomcl_group
        interestings.each do |three|
          if group.orthomcl_genes.code(three).length>0
            results.push 1
          else
            results.push 0
          end
        end
      else
        # fill with empty cells
        1..interestings.length.times do
          results.push nil #is this correct? Can the machine learning technique deal with this? 
        end
      end
      
      # 7species orthomcl
      seven_name_hash = {}
      begin
        if !fivepfour.include?(code.string_id) #Used 5.2 for 7species too, so ignore new genes
          og = code.single_orthomcl(OrthomclRun.seven_species_filtering_name)
          raise Exception, "7species falciparum not found for #{code.inspect}" if !og
          og.orthomcl_group.orthomcl_genes.all.each do |gene|
            next if gene.orthomcl_name.match(/Plasmodium_vivax_SaI/) #skip vivax because of linking problems for the moment
            species_name = gene.single_code.gene.scaffold.species.name
            if seven_name_hash[species_name]
              seven_name_hash[species_name] += 1
            else
              seven_name_hash[species_name] = 1
            end
          end
        end
      rescue CodingRegion::UnexpectedOrthomclGeneCount => e
        # This happens for singlet genes
      end
      [Species.falciparum_name, Species.vivax_name, Species.babesia_bovis_name].each do |name|
        results.push seven_name_hash[name] ? 1 : 0
      end
      
      #                  'Number of Synonymous IT SNPs according to Jeffares et al', #SNP Data
      #            'Number of Non-Synonymous IT SNPs according to Jeffares et al',
      #            'Number of Synonymous Clinical SNPs according to Jeffares et al',
      #            'Number of Non-Synonymous Clinical SNPs according to Jeffares et al',
      [:it_synonymous_snp, :it_non_synonymous_snp, :pf_clin_synonymous_snp, :pf_clin_non_synonymous_snp].each do |method|
        if s = code.send(method)
          results.push s.value
        else
          results.push nil
        end
      end
      
      
  

      # Microarray DeRisi
      derisi_timepoints.each do |timepoint|
        measures = MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(
          code.id,
          timepoint.id
        )
        if !measures.nil?
          results.push measures.measurement
        else
          results.push nil
        end
      end
      
      # push all the gMARS data
      results.push code.gmars_vector(3)
      
      # Check to make sure that all the rows have the same number of entries as a debug thing
      #      if results.length != headings.length
      #        raise Exception, "Bad number of entries in the row (#{headings.length} headings vs. #{results.length} results) for code #{code.inspect}: #{results.inspect}"
      #      end
      all_results.push results.flatten
      all_result_classes.push localisation_to_index_hash[code.tops[0].name]
      #      puts code.string_id
      #      puts code.tops.reach.name.join(", ")
      #      puts localisation_to_index_hash
      #      puts localisation_to_index_hash['nucleus']
      #      puts headings.join("\t")
      #      puts results.join("\t")
      #      return
      #      @i ||= 0
      #      @i += 1
      #      break if @i>1
    end
    
    all_results.normalise_columns.each_with_index do |row, index|
      puts row.libsvm_format(all_result_classes[index])
    end
  end

  def amino_acid_composition_libsvm
    all_results = []
    all_result_classes = []
    
    localisation_to_index_hash = TopLevelLocalisation::TOP_LEVEL_LOCALISATIONS.to_hash
      
    amino_acid_hash = Bio::AminoAcid::Data::NAMES.keys.select{|k| k.length == 1}.reach.downcase.to_hash
    
    # For all genes that only have 1 localisation
    CodingRegion.species_name(Species.falciparum_name).all(
      :select => 'distinct(coding_regions.*)',
      :joins => {:expressed_localisations => :malaria_top_level_localisation}
    ).each do |code|
      next unless code.uniq_top?
      all_result_classes.push localisation_to_index_hash[code.tops[0].name]
        
      mine = []
      code.amino_acid_sequence.to_bioruby_sequence.composition.each do |aa, count|
        a = aa.downcase
        if amino_acid_hash[a]
          mine[amino_acid_hash[a]] = count.to_f
        end
      end
      # make all the rows the same
      amino_acid_hash.keys.each_with_index do |e, i|
        mine[i] ||=0.0
      end
     
      # add a signal peptide to see what difference that makes
      if code.signal?
        mine.push 1
      else
        mine.push 0
      end
      
      all_results.push mine
    end
      
    all_results.normalise_columns.each_with_index do |row, index|
      puts row.libsvm_format(all_result_classes[index])
    end
  end
  
  def falciparum_localistion_fasta
    hash = {}
    CodingRegion.falciparum.all(
      :include => {:expressed_localisations => :malaria_top_level_localisation}
    ).uniq.each do |code|
      next unless code.uniq_top?
      
      loc = code.tops[0].name
      hash[loc] ||= []
      hash[loc].push code
    end
    
    hash.each do |loc, codes|
      f = File.open("../falciparum_localisation_meme/#{loc}.fa", 'w')
      f.puts codes.reach.amino_acid_sequence.fasta.join("\n")
      f.close
      
      f = File.open("../falciparum_localisation_meme/#{loc}.nosignalp.fa", 'w')
      codes.each do |code|
        f.puts ">#{code.string_id} #{loc}"
        f.puts code.sequence_without_signal_peptide
      end
      f.close
    end
  end
  
  def localisation_libsvm_normalised_apicoplast_test
    
    raise Exception, "No longer maintained - use ARFF instead"
    # headings
    headings = [
      #      'PlasmoDB ID',
      #      'Annotation',
      #      'Top Level Localisations',
      #      'Amino Acid Sequence',
      #      'Class',
      'SignalP Prediction',
      'PlasmoAP Score'
    ]
    #    Bio::PSORT::WoLF_PSORT::ORGANISM_TYPES.each do |organism|
    #      Bio::PSORT::WoLF_PSORT::LOCALISATIONS.each do |loc|
    #        headings.push "WoLF PSORT Prediction #{organism}: #{loc}"
    #      end
    #    end
    headings.push [
      'Number of P. falciparum Genes in Official Orthomcl Group', #orthomcl
      'Number of P. vivax Genes in Official Orthomcl Group',
      'Number of C. parvum Genes in Official Orthomcl Group',
      'Number of C. homonis Genes in Official Orthomcl Group',
      'Number of T. parva Genes in Official Orthomcl Group',
      'Number of T. annulata Genes in Official Orthomcl Group',
      'Number of Arabidopsis Genes in Official Orthomcl Group',
      'Number of Yeast Genes in Official Orthomcl Group',
      'Number of Mouse Genes in Official Orthomcl Group',
      'Number of P. falciparum Genes in 7species Orthomcl Group', #7species orthomcl
      'Number of P. vivax Genes in 7species Orthomcl Group',
      'Number of Babesia Genes in 7species Orthomcl Group',
      'Number of Synonymous IT SNPs according to Jeffares et al', #SNP Data
      'Number of Non-Synonymous IT SNPs according to Jeffares et al',
      'Number of Synonymous Clinical SNPs according to Jeffares et al',
      'Number of Non-Synonymous Clinical SNPs according to Jeffares et al',
    ]
    #    derisi_timepoints = Microarray.find_by_description(Microarray.derisi_2006_3D7_default).microarray_timepoints(:select => 'distinct(name)')
    derisi_timepoints = Microarray.find_by_description(Microarray.derisi_2006_3D7_default).microarray_timepoints(:select => 'distinct(name)', 
      :conditions => ['microarray_timepoints.name = ?', 'Phase']
    )
    headings.push derisi_timepoints.collect{|t| 
      'DeRisi 2006 3D7 '+t.name
    }
    
    headings = headings.flatten #The length of headings array is used later as a check, so need to actually modify it here
    #puts headings.join(sep)
    all_results = []
    all_result_classes = []
    
    # genes that are understandably not in the orthomcl databases, because
    # they were invented in plasmodb 5.4 and weren't present in 5.2. Might be worth investigating
    # if any of them has any old names that were included, but meh for the moment.
    fivepfour = ['PFL0040c', 'PF14_0078', 'PF14_0744','PF10_0344','PFD1150c','PFD1145c','PFD0110w','PFI1780w','PFI1740c','PFI0105c','PFI0100c','MAL7P1.231']
    # Genes that have 2 orthomcl entries but only 1 plasmoDB entry
    merged_genes = ['PFD0100c']
    
    localisation_to_index_hash = TopLevelLocalisation::TOP_LEVEL_LOCALISATIONS.to_hash
    
    # To match the spreadsheet exactly so can compare with PlasmoAP
    %w(MAL13P1.186
MAL13P1.196
MAL13P1.220
MAL13P1.281
MAL13P1.324
MAL13P1.56
MAL13P1.67
MAL13P1.95
MAL7P1.12
MAL7P1.150
MAL7P1.151
MAL7P1.159
MAL7P1.20
MAL8P1.110
MAL8P1.140
MAL8P1.37
PF07_0068
PF07_0073
PF07_0115
PF08_0011
PF08_0014
PF08_0018
PF08_0063
PF08_0066
PF10_0053
PF10_0057
PF10_0149
PF10_0221
PF10_0332
PF10_0363
PF10_0407
PF11_0157
PF11_0175
PF11_0181
PF11_0256
PF11_0270
PF11_0386
PF13_0040
PF13_0066
PF13_0077
PF13_0109
PF13_0128
PF13_0180
PF13_0205
PF13_0354
PF14_0063
PF14_0112
PF14_0114
PF14_0132
PF14_0133
PF14_0155
PF14_0156
PF14_0164
PF14_0166
PF14_0192
PF14_0198
PF14_0270
PF14_0276
PF14_0286
PF14_0348
PF14_0381
PF14_0382
PF14_0401
PF14_0415
PF14_0428
PF14_0439
PF14_0441
PF14_0518
PF14_0581
PF14_0641
PF14_0658
PF14_0664
PF14_0695
PFA0225w
PFA0340w
PFA0485w
PFA0580c
PFB0180w
PFB0205c
PFB0385w
PFB0390w
PFB0420w
PFB0505c
PFB0525w
PFB0545c
PFB0890c
PFC0225c
PFC0250c
PFC0310c
PFC0470w
PFC0831w
PFC1005c
PFD0675w
PFD0710w
PFD0980w
PFE0150c
PFE0205w
PFE0215w
PFE0410w
PFE0435c
PFE0475w
PFE0715w
PFE1125w
PFE1225w
PFE1510c
PFF0115c
PFF0230c
PFF0360w
PFF0650w
PFF0730c
PFF0940c
PFF1115w
PFF1130c
PFF1275c
PFF1395c
PFI0230c
PFI0380c
PFI0525w
PFI0570w
PFI0685w
PFI0700c
PFI0890c
PFI0920c
PFI1050c
PFI1125c
PFI1170c
PFI1240c
PFI1485c
PFI1580c
PFI1585c
PFL0400w
PFL0480w
PFL0500w
PFL0595c
PFL0770w
PFL0780w
PFL0835w
PFL1120c
PFL1540c
PFL1545c
PFL1590c
PFL1915w
PFL2115c
PFL2180w
PFL2395c
    ).collect{|i| CodingRegion.falciparum.find_by_string_id(i)}.each do |code|
      #    CodingRegion.species_name(Species.falciparum_name).all(
      #      :joins => {:expressed_localisations => :malaria_top_level_localisation}
      #    ).uniq.each do |code|
      
      results = [
        #        code.string_id,
        #        code.annotation.annotation,
        #        code.tops.pick(:name).uniq.sort.join(', '),  # Top level localisations
        #        code.amino_acid_sequence.sequence,
      ]
      
      # ignore little loved locs and multiple localisations
      #      next unless code.uniq_top?
      
      # SignalP
      results.push(
        code.signalp_however.signal? ? 1 : 0
      )
      
      # PlasmoAP
      results.push code.amino_acid_sequence.plasmo_a_p.points
      
      #WoLF_PSORT
      #      Bio::PSORT::WoLF_PSORT::ORGANISM_TYPES.each do |organism|
      #        Bio::PSORT::WoLF_PSORT::LOCALISATIONS.each do |loc|
      #          if code.wolf_psort_localisations(organism).include?(loc)
      #            headings.push 1
      #          else
      #            headings.push 0
      #          end
      #        end
      #      end
      #      results.push code.wolf_psort_localisation('plant')
      #      results.push code.wolf_psort_localisation('animal')
      #      results.push code.wolf_psort_localisation('fungi')
      
      # official orthomcl
      interestings = ['pfa','pvi','cpa','cho','the','tan','ath','sce','mmu']
      
      # Some genes have 2 entries in orthomcl, but only 1 in plasmodb 5.4
      if merged_genes.include?(code.string_id)
        # Fill with non-empty cells
        group = code.orthomcl_genes[0].orthomcl_group
        interestings.each do |three|
          if group.orthomcl_genes.code(three).length>0
            results.push 1
          else
            results.push 0
          end
        end        
      elsif !fivepfour.include?(code.string_id) and single = code.single_orthomcl 
        # Fill with non-empty cells
        group = single.orthomcl_group
        interestings.each do |three|
          if group.orthomcl_genes.code(three).length>0
            results.push 1
          else
            results.push 0
          end
        end
      else
        # fill with empty cells
        1..interestings.length.times do
          results.push nil #is this correct? Can the machine learning technique deal with this? 
        end
      end
      
      # 7species orthomcl
      seven_name_hash = {}
      begin
        if !fivepfour.include?(code.string_id) #Used 5.2 for 7species too, so ignore new genes
          og = code.single_orthomcl(OrthomclRun.seven_species_filtering_name)
          raise Exception, "7species falciparum not found for #{code.inspect}" if !og
          og.orthomcl_group.orthomcl_genes.all.each do |gene|
            next if gene.orthomcl_name.match(/Plasmodium_vivax_SaI/) #skip vivax because of linking problems for the moment
            species_name = gene.single_code.gene.scaffold.species.name
            if seven_name_hash[species_name]
              seven_name_hash[species_name] += 1
            else
              seven_name_hash[species_name] = 1
            end
          end
        end
      rescue CodingRegion::UnexpectedOrthomclGeneCount => e
        # This happens for singlet genes
      end
      [Species.falciparum_name, Species.vivax_name, Species.babesia_bovis_name].each do |name|
        results.push seven_name_hash[name] ? 1 : 0
      end
      
      #                  'Number of Synonymous IT SNPs according to Jeffares et al', #SNP Data
      #            'Number of Non-Synonymous IT SNPs according to Jeffares et al',
      #            'Number of Synonymous Clinical SNPs according to Jeffares et al',
      #            'Number of Non-Synonymous Clinical SNPs according to Jeffares et al',
      [:it_synonymous_snp, :it_non_synonymous_snp, :pf_clin_synonymous_snp, :pf_clin_non_synonymous_snp].each do |method|
        if s = code.send(method)
          results.push s.value
        else
          results.push nil
        end
      end
      
      
  

      # Microarray DeRisi
      derisi_timepoints.each do |timepoint|
        measures = MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(
          code.id,
          timepoint.id
        )
        if !measures.nil?
          results.push measures.measurement
        else
          results.push nil
        end
      end
      
      # push all the gMARS data
      results.push code.gmars_vector(3)
      
      # Check to make sure that all the rows have the same number of entries as a debug thing
      #      if results.length != headings.length
      #        raise Exception, "Bad number of entries in the row (#{headings.length} headings vs. #{results.length} results) for code #{code.inspect}: #{results.inspect}"
      #      end
      all_results.push results.flatten
      all_result_classes.push localisation_to_index_hash['apicoplast']
      #      puts code.string_id
      #      puts code.tops.reach.name.join(", ")
      #      puts localisation_to_index_hash
      #      puts localisation_to_index_hash['nucleus']
      #      puts headings.join("\t")
      #      puts results.join("\t")
      #      return
      #      @i ||= 0
      #      @i += 1
      #      break if @i>1
    end
    
    all_results.normalise_columns.each_with_index do |row, index|
      puts row.libsvm_format(all_result_classes[index])
    end
  end

  def apicoplast_list_test
    PlasmodbGeneList.find_by_description('apicoplast.Stuart.20080215').coding_regions.uniq.reject{
      |code| code.hypothetical_by_annotation?
    }.each do |code|
      puts [
        code.string_id,
        code.annotation.annotation,
        code.amino_acid_sequence.plasmo_a_p.points,
        code.tops.reach.name.join(", ")
      ].join("\t")
    end
  end

  def florian_transmembrane_composition
    ['florian type1 composition foray', 'florian type2 composition foray'].each do |list_name|
      puts
      puts list_name
      PlasmodbGeneList.find_by_description(list_name).coding_regions.each do |code|
        tm = code.amino_acid_sequence.tmhmm_minus_signal_peptide
        
        # make sure we are only dealing with type 1 or 2 here
        raise Exception, "Unexepected number of TMDs found" unless tm.transmembrane_domains.length == 1
        
        seq = code.sequence_without_signal_peptide
        #        tmseq = tm.transmembrane_domains[0].sequence(seq)
        tmseq = tm.transmembrane_domains[0].sequence(seq, -10, 10)
        puts ">#{code.string_id} #{code.annotation ? code.annotation.annotation : nil}\n#{tmseq}"
      end
    end
  end
  
  def arff_test
    all_results = []
    
    # genes that are understandably not in the orthomcl databases, because
    # they were invented in plasmodb 5.4 and weren't present in 5.2. Might be worth investigating
    # if any of them has any old names that were included, but meh for the moment.
    fivepfour = ['PFL0040c', 'PF14_0078', 'PF14_0744','PF10_0344','PFD1150c','PFD1145c','PFD0110w','PFI1780w','PFI1740c','PFI0105c','PFI0100c','MAL7P1.231']
    # Genes that have 2 orthomcl entries but only 1 plasmoDB entry
    merged_genes = ['PFD0100c']
    
    first_code = true
    attribute_names = []
    
    # For all genes that only have 1 localisation
    CodingRegion.species_name(Species.falciparum_name).all(
      :joins => {:expressed_localisations => :malaria_top_level_localisation}
      #      :limit => 15
    ).uniq.each do |code|
      
      results = [
        #        code.string_id,
        #        code.annotation.annotation,
        #        code.tops.pick(:name).uniq.sort.join(', '),  # Top level localisations
        #        code.amino_acid_sequence.sequence,
      ]
      
      # ignore little loved locs and multiple localisations
      next unless code.uniq_top?
      
      # SignalP
      attribute_names.push 'SignalPSignal' if first_code
      h = code.signalp_however
      results.push h.signal?
      attribute_names.push 'SignalPnn_D' if first_code
      h = code.signalp_however
      results.push h.nn_D
      attribute_names.push 'SignalPhmm_S' if first_code
      h = code.signalp_however
      results.push h.hmm_Sprob
      
      # PlasmoAP
      attribute_names.push 'PlasmoAP' if first_code
      results.push code.amino_acid_sequence.plasmo_a_p.apicoplast_targeted?
      
      # ExportPred
      attribute_names.push 'ExportPred' if first_code
      results.push code.export_pred_however.predicted?
      
      # Final result
      attribute_names.push 'Localisation' if first_code
      results.push code.tops[0].name.gsub(' ','_')
      
      all_results.push results.flatten
      #      break unless first_code
      first_code = false
    end
    
    
    rel = Rarff::Relation.new('PfalciparumLocalisation')
    eyes = all_results.normalise_columns([0..(all_results.length-2)])
    rel.instances = eyes
    attribute_names.each_with_index do |name, index|
      rel.attributes[index].name = name
    end
    rel.attributes[rel.attributes.length-1].type = "{#{TopLevelLocalisation.all.reach.name.join(', ')}}"
    puts rel.to_s
  end
  
  def orthomcl_blast_result_fasta(m8='/home/ben/phd/cbm48/4/humanB1fragmentVorthomcl.blast.tab')
    oes = []
    FasterCSV.foreach(m8, :col_sep => "\t") do |row|
      o = OrthomclGene.find_by_orthomcl_name(row[1])
      return "Failed #{row[1]}" if o.nil?
      oes.push o
    end
    puts oes.reach.orthomcl_gene_official_data.fasta.join("\n")
  end
  
  # See phd.html [[Winzeler Gametocyte Microarray Upload]]
  # Uploads the gametocyte and previous results that come out from the MOID
  # analysis done by Winzeler and crew.
  def upload_winzeler_gametocyte_microarray
    columns = [
      nil,
      nil,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_PANOVA,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_PC,
      nil,
      MicroarrayTimepoint::WINZELER_2003_EARLY_RING_SORBITOL,
      MicroarrayTimepoint::WINZELER_2003_LATE_RING_SORBITOL,
      MicroarrayTimepoint::WINZELER_2003_EARLY_TROPHOZOITE_SORBITOL,
      MicroarrayTimepoint::WINZELER_2003_LATE_TROPHOZOITE_SORBITOL,
      MicroarrayTimepoint::WINZELER_2003_EARLY_SCHIZONT_SORBITOL,
      MicroarrayTimepoint::WINZELER_2003_LATE_SCHIZONT_SORBITOL,
      MicroarrayTimepoint::WINZELER_2003_MEROZOITE_SORBITOL,
      MicroarrayTimepoint::WINZELER_2003_EARLY_RING_TEMPERATURE,
      MicroarrayTimepoint::WINZELER_2003_LATE_RING_TEMPERATURE,
      MicroarrayTimepoint::WINZELER_2003_EARLY_TROPHOZOITE_TEMPERATURE,
      MicroarrayTimepoint::WINZELER_2003_LATE_TROPHOZOITE_TEMPERATURE,
      MicroarrayTimepoint::WINZELER_2003_EARLY_SCHIZONT_TEMPERATURE,
      MicroarrayTimepoint::WINZELER_2003_LATE_SCHIZONT_TEMPERATURE,
      MicroarrayTimepoint::WINZELER_2003_MEROZOITE_TEMPERATURE,

      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_EARLY_DAY_1,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_EARLY_DAY_2,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_EARLY_DAY_3,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_EARLY_DAY_4,

      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_DAY_1,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_DAY_2,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_DAY_3,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_DAY_6,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_DAY_8,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_3D7_DAY_12,

      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_1,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_2,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_3,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_4,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_5,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_6,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_7,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_8,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_9,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_10,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_11,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_12,
      MicroarrayTimepoint::WINZELER_2005_GAMETOCYTE_NF54_DAY_13
    ]
    
    microarray = Microarray.find_or_create_by_description(Microarray::WINZELER_2005_GAMETOCYTE_NAME)
    
    FasterCSV.foreach("#{DATA_DIR}/falciparum/microarray/WinzelerGametocyte/AllData.csv", 
      :col_sep => "\t", :headers => :first_row) do |row|
      
      raise if columns.length != row.length #checking
      
      code = CodingRegion.f(row['Gene'])
      
      if !code
        $stderr.puts "Could not find PlasmoDB ID #{row['Gene']}. Skipping."
        next
      end
      
      # upload each column
      columns.each_with_index do |column, index|
        next if column.nil? #ignore some columns, including the sporozoite one
        
        timepoint = MicroarrayTimepoint.find_or_create_by_name_and_microarray_id(column, microarray.id)
        raise unless timepoint
        cell = row[index]
        if [2,3].include?(index)
          # Had to comment out the to_f? checking because it didn't handle 1.20E-4 type things
          #raise Exception, "error parsing #{cell}" unless cell.to_f?
          cell = cell.to_f
        else
          raise Exception, "error parsing #{cell}" unless cell.to_i? # Every cell is expected to be an integer
          cell = cell.to_i
        end
        
        
        raise unless MicroarrayMeasurement.find_or_create_by_measurement_and_microarray_timepoint_id_and_coding_region_id(
          cell,
          timepoint.id,
          code.id
        )
      end
    end
  end
  
  # Florian spreadsheet to do
  #ben, 9 December 2008 (created 9 December 2008)
  #
  #check falciparum genome for TA proteins
  #
  #    * predict single spanning TMDs using various TMD predictors: tmhmm, tmpred, toppred, aligator (or whatever it is called).
  #    * for each predictor, give a spreadsheet containing:
  #
  #plasmoDB id
  #annotation
  #type I or II?
  #start tmd
  #end tmd
  #length tmd
  #number of residues c terminal
  #SignalP 3.0
  #exportpred
  #pexel
  #hts
  def florian_spreadsheet_yet_again
    # Headers
    headers = %w(
      plasmoDB_id
      annotation
      type_I_or_II?
      start_tmd
    end_tmd
    length_tmd
    number_of_residues_c_terminal
    SignalP_3.0
    exportpred
    pexel
    hts
    cruft
    )
    
    [
      :tmhmm, 
      #      :tmpred, 
      #      :toppred
    ].each do |predictor|
      FasterCSV.open("#{PHD_DIR}/yet_another_florian/#{predictor}.csv", "w", :col_sep => "\t") do |csv|
        csv << headers
        CodingRegion.falciparum.all.each do |code|
          next unless code.aaseq #everything must have a sequence to be considered
          predicted = code.send(predictor)
          if predicted.transmembrane_type_1? or predicted.transmembrane_type_2?
            csv << [
              code.string_id,
              code.annotation ? code.annotation.annotation : nil,
              predicted.transmembrane_type,
              predicted.transmembrane_domains[0].start,
              predicted.transmembrane_domains[0].stop,
              predicted.transmembrane_domains[0].length,
              code.sequence_without_signal_peptide.length - predicted.transmembrane_domains[0].stop,
              code.signalp_however.signal?,
              code.export_pred_however.predicted?,
              PlasmodbGeneList.find_by_description('pexelPlasmoDB5.5').coding_regions.all(:conditions => ["coding_regions.id = ?", code.id]).empty? ? 'no': 'yes',
              PlasmodbGeneList.find_by_description('htPlasmoDB5.5').coding_regions.all(:conditions => ["coding_regions.id = ?", code.id]).empty? ? 'no': 'yes',
              code.falciparum_cruft?
            ]
          end
        end
      end
    end
  end
  
  def apiloc_winzeler_bias
    array_constants = [
      WINZELER_2003_EARLY_RING_SORBITOL,
      WINZELER_2003_LATE_RING_SORBITOL,
      WINZELER_2003_EARLY_TROPHOZOITE_SORBITOL,
      WINZELER_2003_LATE_TROPHOZOITE_SORBITOL,
      WINZELER_2003_EARLY_SCHIZONT_SORBITOL,
      WINZELER_2003_LATE_SCHIZONT_SORBITOL,
      WINZELER_2003_MEROZOITE_SORBITOL,
      WINZELER_2003_EARLY_RING_TEMPERATURE,
      WINZELER_2003_LATE_RING_TEMPERATURE,
      WINZELER_2003_EARLY_TROPHOZOITE_TEMPERATURE,
      WINZELER_2003_LATE_TROPHOZOITE_TEMPERATURE,
      WINZELER_2003_EARLY_SCHIZONT_TEMPERATURE,
      WINZELER_2003_LATE_SCHIZONT_TEMPERATURE,
      WINZELER_2003_MEROZOITE_TEMPERATURE,

      WINZELER_2005_GAMETOCYTE_NF54_DAY_1,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_2,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_3,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_4,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_5,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_6,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_7,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_8,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_9,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_10,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_11,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_12,
      WINZELER_2005_GAMETOCYTE_NF54_DAY_13
    ]
    
    # Headers
    puts [
      'PlasmoDB ID',
      array_constants
    ].flatten.join("\t")
    
    # For each gene in the proteome list
    CodingRegion.falciparum.localised.all.each do |code|
      results = [code.string_id]
      
      array_constants.each do |timepoints|
        results.push code.microarray_measurements.timepoint_names([timepoints].flatten).all.reach.percentile.average
      end
      
      puts results.join("\t")
    end
  end

  def upload_neafsey_2008_snp_data
    hash_code_to_syn_snp = {}
    hash_code_to_non_syn_snp = {}
    hash_code_to_intronic_snp = {}
    
    FasterCSV.foreach("#{DATA_DIR}/falciparum/polymorphism/SNP/NeafseySchaffner2008-gb-2008-9-12-r171-s5.csv",
      :col_sep => "\t",
      :headers => true
    ) do |row|
      gene_id = row['Gene']
      gene_id.gsub!('_','.') if gene_id and gene_id.match(/^MAL/)
      case row['SNP Type']
      when 'Non-Synonymous'
        hash_code_to_non_syn_snp[gene_id] ||= 0
        hash_code_to_non_syn_snp[gene_id] += 1
      when 'Synonymous'
        hash_code_to_syn_snp[gene_id] ||= 0
        hash_code_to_syn_snp[gene_id] += 1
      when 'Intronic'
        hash_code_to_intronic_snp[gene_id] ||= 0
        hash_code_to_intronic_snp[gene_id] += 1
      when 'Intergenic'
      else
        raise Exception, "Parsing problem on line #{row.inspect}"
      end
    end
    
    # Now upload each
    hash_code_to_syn_snp.each do |gene_id, count|
      code = CodingRegion.f(gene_id)
      if code.nil?
        $stderr.puts "Couldn't find #{gene_id}"
        next
      end
      NeafseySynonymousSnp.find_or_create_by_coding_region_id_and_value(code.id, count)
    end
    hash_code_to_non_syn_snp.each do |gene_id, count|
      code = CodingRegion.f(gene_id)
      if code.nil?
        $stderr.puts "Couldn't find #{gene_id}"
        next
      end
      NeafseyNonSynonymousSnp.find_or_create_by_coding_region_id_and_value(code.id, count)
    end
    hash_code_to_intronic_snp.each do |gene_id, count|
      code = CodingRegion.f(gene_id)
      if code.nil?
        $stderr.puts "Couldn't find #{gene_id}"
        next
      end
      NeafseyIntronicSnp.find_or_create_by_coding_region_id_and_value(code.id, count)
    end
  end
  
  def orthomcl_redundancy_reduce_test
    PlasmodbGeneList.find_by_description(PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME).coding_regions.collect do |code|
      begin
        puts code.single_orthomcl.orthomcl_group.orthomcl_name
      rescue CodingRegion::UnexpectedOrthomclGeneCount
        $stderr.puts "No group found for: #{code.string_id} #{code.annotation.annotation}"
      end
    end
  end
  
  def apical_merozoite_surface_plasmoap_bonus_bonus_msa
    PlasmodbGeneList.find_by_description(PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME).coding_regions.collect do |code|
      next unless ['merozoite surface', 'apical'].include?(code.tops[0].name)
      next unless code.signal?
      puts ">#{code.string_id} #{code.tops[0].name} #{code.annotation.annotation}"
      puts code.sequence_without_signal_peptide
    end
  end
  
  def create_redundancy_reduced_apiloc_list
    upload_other_meta
    File.open("#{PHD_DIR}/gene lists/ApiLocLocalisedProteinsUniqTop.fa", 'w') do |f|
      f.print localisation_fasta_programmatic(true, true)
    end
    entries = []
    Dir.chdir("#{PHD_DIR}/gene lists") do
      system("blastclust -i ApiLocLocalisedProteinsUniqTop.fa -S 10 >ApiLocLocalisedProteinsUniqTop.fa.blastclust")
      
      File.open("ApiLocLocalisedProteinsUniqTop.fa.blastclust").each_line do |line|
        entries.push line.split(' ')[0]
      end
    end
    # Get rid of the previous ones because they just get in the way
    PlasmodbGeneList.all(:conditions => {:description => PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME}).reach.destroy
    
    # Upload the newest and best version
    PlasmodbGeneList.create_gene_list(PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME, Species.falciparum_name, entries)
  end
  
  def alanine_bias
    File.open('../alanine_bias/exported.csv','w') do |exported_file|
      File.open('../alanine_bias/localised.csv','w') do |localised_file|
        File.open('../alanine_bias/population.csv','w') do |population_file|
          CodingRegion.falciparum.all.each do |code|
            next unless code.aaseq
            #            p code.aaseq
            #            p code.amino_acid_sequence.to_bioruby_sequence.composition['A']
            
            alanines = code.amino_acid_sequence.to_bioruby_sequence.composition['A'].to_f / code.aaseq.length.to_f
            #            p alanines
            #            return
            
            population_file.puts [code.string_id, alanines].join("\t")
            if code.uniq_top?
              localised_file.puts [code.string_id, alanines].join("\t")
              if code.tops[0].name == 'exported'
                exported_file.puts [code.string_id, alanines].join("\t")
              end
            end
          end
        end
      end
    end
  end
  
  def kolmogorov_smirnov_amino_acids_bias
    populations = {}
    localiseds = {}
    exporteds = {}
    
    #    CodingRegion.falciparum.all(:include => :amino_acid_sequence).each do |code|
    CodingRegion.falciparum.all(:include => [
        {:expressed_localisations => :malaria_top_level_localisation},
        :amino_acid_sequence]
    ).each do |code|
      next unless code.aaseq
      
      localised = code.uniq_top?
      exported = (code.uniq_top? and code.tops[0].name == 'exported')
      
      composed = code.amino_acid_sequence.to_bioruby_sequence.composition
      AminoAcidSequence::AMINO_ACIDS.each do |amino_acid|
        count = composed[amino_acid]
        alanines = count.to_f / code.aaseq.length.to_f
        
        populations[amino_acid] ||= []
        populations[amino_acid].push alanines
        #        p populations
        #        p code.aaseq
        #        p code.aaseq.length
        #        p code.aaseq.scan(/V/)
        #        return
        if localised
          localiseds[amino_acid] ||= []
          localiseds[amino_acid].push alanines
        end
        if exported
          exporteds[amino_acid] ||= []
          exporteds[amino_acid].push alanines
        end
      end
    end
    
    r = RSRuby.instance
    puts AminoAcidSequence::AMINO_ACIDS.collect{|amino_acid| 
      e = exporteds[amino_acid]
      l = localiseds[amino_acid]
      p = populations[amino_acid]
      kep = r.ks_test(e,p)
      klp = r.ks_test(l,p)
      [
        amino_acid, 
        kep['statistic']['D']-klp['statistic']['D'], 
        kep['statistic']['D'], 
        klp['statistic']['D'],
        kep['p.value']-klp['p.value'], 
        kep['p.value'], 
        klp['p.value'],
      ]
    }.sort{|a,b| 
      b[1]<=>a[1]
    }.collect{|e|
      e.join("\t")
    }.join("\n")

    return [populations, localiseds, exporteds]
  end
  
  def kolmogorov_smirnov_challenge_arff
    all_data = []
    
    acids = AminoAcidSequence::AMINO_ACIDS
    headings = [
      'Localisation',
      acids
    ].flatten
    
    PlasmodbGeneList.find_by_description(
      PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME
    ).coding_regions.each do |code|
      next unless code.uniq_top?
      composition = code.amino_acid_composition
      
      result = []

      if code.single_top_level_localisation.name == 'exported'
        result.push 'exported'
        result.push composition
        all_data.push result.flatten
      else
        result.push 'not_exported'
        result.push composition
        all_data.push result.flatten
      end
      
      raise if result.flatten.length != headings.length
    end
    
    rarff_relation = Rarff::Relation.new('PfalciparumLocalisationExportedVsNotExported')
    rarff_relation.instances = all_data
    headings.each_with_index do |heading, index|
      rarff_relation.attributes[index].name = "\"#{heading}\""
    end
    
    # Make some attributes noiminal instead of String
    # Localisation
    rarff_relation.attributes[0].type = "{exported,not_exported}"
    
    puts rarff_relation.to_arff    
  end
  
  # Find all proteins that are contained in the ribosomes, for use in the
  # 2nd tier dataset
  def ribosomal_protein_search
    CodingRegion.falciparum.all(:include => :annotation, :conditions => ['annotation like ? or annotation like ?', "%ribosom%", "%Ribosom%"]).sort{|a,b| 
      a.annotation.annotation <=> b.annotation.annotation}.each do |code|
      if code.aaseq.nil?
        $stderr.puts "No amino acid sequence found for #{code.string_id}"
        next
      end
      puts [code.string_id, code.annotation.annotation, code.signal?, code.plasmo_a_p.predicted?].join("\t")
    end
  end
  
  def ribosome_falciparum_annotation
    codes = []
    FasterCSV.open("#{PHD_DIR}/ribosomes/PfalciparumAmigo.gene_association", :col_sep => "\t").each do |row|
      codes.push CodingRegion.f(row[1])
    end
    codes.uniq.each do |code|
      puts [code.string_id, code.annotation.annotation, code.signal?, code.plasmo_a_p.predicted?].join("\t")
    end
  end
  
  # Get out all the falciparum 
  def yeast_ribosomal_proteome_fasta
    codes = []
    FasterCSV.open("#{PHD_DIR}/ribosomes/Scerevisiae.gene_association", :col_sep => "\t").each do |row|
      names = row[10].split('|')
      found = false
      names.each do |name|
        code = CodingRegion.f(name)
        if code
          codes.push code
          found = true
          break
        end
      end
      unless found
        $stderr.puts "Couldn't find gene for #{row[10]} - #{names.inspect}"
      end
    end
    
    codes.uniq.each do |code|
      unless code.amino_acid_sequence
        $stderr.puts "Couldn't find amino acid sequence for #{code.string_id} #{code.annotation}"
        next
      end
      puts code.amino_acid_sequence.fasta
    end
  end
  
  # For all proteins in my list, which ones have been localised in Yeast
  # (inferred through IDA GO CC annotations)
  def yeast_localisation_to_apiloc_localisation
    PlasmodbGeneList.find_by_description(PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME).coding_regions.each do |code|
      yeasts = code.orthomcl_genes.code('sce').official.all
      if yeasts.empty?
        puts code.string_id
      else
        print "#{code.string_id}\t"
        yeasts.each do |og|
          og.single_code.each do |yc|
            print "#{yc.go_terms.pick(:term).join(" | ")}\t"
          end
        end
        puts
      end
    end
  end
  
  def upload_mu_et_al_snps
    FasterCSV.foreach("#{DATA_DIR}/falciparum/polymorphism/Mu2007/ng1924-S5.csv", :col_sep => "\t") do |row|
      next unless row[0] and row[0].length > 0 and row[0] != 'Gene ID' and row[2]
      
      code = CodingRegion.ff(row[0])
      unless code
        $stderr.puts "Couldn't find #{row[0]}"
        next
      end
      mu_bp_surveyed = row[2].to_i
      mu_synonymous_snp = row[5].to_i
      mu_non_synonymous_snp = row[6].to_i
      mu_non_coding_snp = row[8].to_i
      mu_pi = row[16]
      mu_theta = row[15]

      
      # There is probably some rails way that is cooler but I don't know it
      MuBpSurveyed.find_or_create_by_coding_region_id_and_value(
        code.id, mu_bp_surveyed
      ) or raise
      MuNonSynonymousSnp.find_or_create_by_coding_region_id_and_value(
        code.id, mu_non_synonymous_snp
      ) or raise
      MuSynonymousSnp.find_or_create_by_coding_region_id_and_value(
        code.id, mu_synonymous_snp
      ) or raise
      MuNonCodingSnp.find_or_create_by_coding_region_id_and_value(
        code.id, mu_non_coding_snp
      ) or raise
      MuPi.find_or_create_by_coding_region_id_and_value(
        code.id, mu_pi
      ) or raise
      MuTheta.find_or_create_by_coding_region_id_and_value(
        code.id, mu_theta
      ) or raise
    end
  end

  def add_lengths_to_scaffolds(species_name, gff_file_path=nil)
    require 'gff3_genes'
    sp = Species.find_or_create_by_name species_name
    GFF3ParserLight.new(File.open(gff_file_path)).each_feature('supercontig') do |feature|
      scaff = Scaffold.find_by_name_and_species_id(
        feature.seqname,
        sp.id
      )
      unless scaff
        $stderr.puts "Couldn't find scaffold #{feature.seqname} - ignoring"
        next
      end
      
      scaff.length = feature.end
      scaff.save!
    end
  end

  def apidb_species_to_database(species_name, gff_file_path=nil, iter=nil)


    sp = Species.find_or_create_by_name species_name
    #        sp.scaffolds.each do |scaff|
    #          scaff.destroy
    #        end

    # Create all the scaffolds, which are specified as supercontig
    # The length is needed so I can work out the length to the end
    # of the chromosome
    #    raise Exception, "needs updating to include scaffold length - see add_lengths_to_scaffolds for an example. I s half implemented already."
    GFF3ParserLight.new(File.open(gff_file_path)).each_feature('supercontig') do |feature|
      scaff = Scaffold.find_or_create_by_name_and_species_id_and_length(
        feature.seqname,
        sp.id,
        feature.end
      )
    end

    # recreate iter if it does not already exist
    iter ||= ApiDbGenes.new(gff_file_path)

    puts "Inserting..."

    gene = iter.next_gene

    while gene

      # Create scaffold if not done already
      if !gene.seqname
        raise Exception, "No seqname in gene: #{gene}"
      end
      scaff = Scaffold.find_by_name_and_species_id(
        gene.seqname,
        sp.id
      )

      g = Gene.find_or_create_by_scaffold_id_and_name(
        scaff.id,
        gene.name
      )

      code = CodingRegion.find_or_create_by_string_id_and_gene_id_and_orientation(
        gene.name,
        g.id,
        gene.strand
      )

      gene.cds.each {|cd|
        if cd.from.to_i < 1 or cd.to.to_i > scaff.length
          $stderr.puts "Unexpected placement of CDS on scaffold: #{cd.inspect}"
        end

        Cd.find_or_create_by_coding_region_id_and_start_and_stop(
          code.id,
          cd.from,
          cd.to
        )
      }

      Annotation.find_or_create_by_coding_region_id_and_annotation(
        code.id,
        gene.description
      )

      if gene.go_identifiers
        gene.go_identifiers.each do |goid|
          go = GoTerm.find_by_go_identifier_or_alternate goid
          if !go
            raise Exception, "No go term found for #{goid}"
          end

          # This should get rid of alternate+real GO term being attributed
          # to the same gene, and therefore causing a duplicate.
          if !CodingRegionGoTerm.find_by_go_term_id_and_coding_region_id(
              go.id, code.id)

            CodingRegionGoTerm.create!(
              :go_term_id => go.id,
              :coding_region_id => code.id
            )
          end
        end
      end


      if gene.alternate_ids
        gene.alternate_ids.each do |alt|

          if !code
            raise Exception, "No coding region still alive to attach an alternate to"
          end

          CodingRegionAlternateStringId.find_or_create_by_coding_region_id_and_name(
            code.id,
            alt
          )
        end
      end

      old_gene = gene
      begin
        gene = iter.next_gene
      rescue Exception => e
        $stderr.puts "Failed on the gene after #{old_gene}"
        raise e
      end
    end

    puts "finished."
  end

  def yeast_gene_ontology_to_database(filename = "#{DATA_DIR}/GO/cvs/go/gene-associations/gene_association.sgd")
    gene_ontology_to_database Species::YEAST_NAME, filename
  end

  def elegans_gene_ontology_to_database
    gene_ontology_to_database Species::ELEGANS_NAME, "#{DATA_DIR}/GO/cvs/go/gene-associations/gene_association.wb"
  end

  # Upload the GO annotations for a given species
  def gene_ontology_to_database(species_name, gene_association_filename)
    require 'gene_association'
    goods = 0
    bads = 0
    Bio::GeneAssociation.new(File.open(gene_association_filename).read).entries.each do |entry|
      names = [
        entry.primary_id,
        entry.gene_name,
        entry.alternate_gene_ids,
      ].flatten

      code = nil
      names.each do |name|
        code = CodingRegion.fs(
          name,
          species_name
        )
        break unless code.nil?
      end
      unless code
        puts "Couldn't find coding region called #{names.join(',')}"
        bads += 1
        next
      end

      # GO terms should already be there
      go_term = GoTerm.find_by_go_identifier_or_alternate(entry.go_identifier)

      unless go_term
        puts "Couldn't find GO term #{entry.go_identifier}"
        bads += 1
        next
      end

      raise unless CodingRegionGoTerm.find_or_create_by_coding_region_id_and_go_term_id_and_evidence_code(
        code.id, go_term.id, entry.evidence_code
      )
      goods += 1
    end

    puts "Uploaded #{goods}, failed to upload #{bads}."
  end

  # Attempting to improve the speed of the subsumer by using Hash#key? instead
  # of Array#include? - it didn't work very well. Meh.
  # However, using
  #     primaree = subsumer_go_id
  # instead of
  #    primaree = @go.primary_go_id(subsumer_go_id)
  # made things much faster
  def test_subsume_speed
    code = CodingRegion.first(:joins => :go_terms)

    id = code.go_terms.first.go_identifier

    @go = Bio::Go.new
    @master_go_id = @go.primary_go_id(id)
    @subsumer_offspring = @go.go_offspring(@master_go_id)
    @subsumer_offspring_hash = @go.go_offspring(@master_go_id).to_hash

    200.times do
      subsume?(id)
    end
  end

  def subsume?(subsumer_go_id)
    primaree = subsumer_go_id
    #    primaree = @go.primary_go_id(subsumer_go_id)
    return true if @master_go_id == primaree
    #    @subsumer_offspring_hash.key?.include?(primaree)
    @subsumer_offspring_hash.key?(primaree)
  end
  
  # For each GO term, work out how many genes associated with that go term
  # are lethal vs all genes with that go term. The idea is to find go terms that
  # are more lethal than others.
  def go_terms_predict_lethality
    go_terms = GoTerm.find_all_by_aspect('cellular_component')
    go_identifiers = go_terms.reach.go_identifier.retract
    
    [Species::YEAST_NAME, Species::ELEGANS_NAME].each do |name|
      coding_regions = CodingRegion.s(name).all(:include => :go_terms)
      go_identifiers.each do |go_identifier|
        lethal_total = 0
        all_total = 0
        
        # What does each coding region tell us?
        coding_regions.each do |code|
          classified = code.go_term?(go_identifier, true, false)
          next unless classified
          
          all_total += 1
          if code.lethal?
            lethal_total += 1
          end
        end
      
        puts [
          name,
          go_identifier,
          lethal_total,
          all_total
        ].join(",")
      end
    end
  end
  
  def upload_jiang_chromosomal_features
    bin_size = 10000 #10kb
    
    (1..14).each do |chromosome_number|
      start = 0
      stop = bin_size-1
      FasterCSV.foreach("#{DATA_DIR}/falciparum/polymorphism/Jiang2008/1471-2164-9-398-s8-chromosome#{chromosome_number}.csv") do |row|
        # "7G8","Dd2","FCR3","HB3"
        
        # ignore heading lines
        next if row[0].match(/^Additional file/) or row[0] == '7G8'
        
        raise Exception unless row.length == 4
        
        scaff = Scaffold.find_falciparum_chromosome(chromosome_number)
        raise unless scaff
        
        Jiang7G8TenKbBinSfpCount.find_or_create_by_scaffold_id_and_value_and_start_and_stop(scaff.id, row[0].to_f, start, stop)
        JiangDd2TenKbBinSfpCount.find_or_create_by_scaffold_id_and_value_and_start_and_stop(scaff.id, row[1].to_f, start, stop)
        JiangFCR3TenKbBinSfpCount.find_or_create_by_scaffold_id_and_value_and_start_and_stop(scaff.id, row[2].to_f, start, stop)
        JiangHB3TenKbBinSfpCount.find_or_create_by_scaffold_id_and_value_and_start_and_stop(scaff.id, row[3].to_f, start, stop)
        
        start += bin_size
        stop += bin_size
      end
    end
  end

  def winzeler_tiling_array_probes_to_database
    microarray = Microarray.find_or_create_by_description(Microarray::WINZELER_2009_TILING_NAME)
    FasterCSV.foreach("#{DATA_DIR}/falciparum/microarray/Winzeler2009/Pftiling_tile-3.bpmap.txt",
      :headers => true, :col_sep => "\t") do |row|

      probe = row[6]
      MicroarrayProbe.find_or_create_by_microarray_id_and_probe(microarray.id, probe)
    end
  end

  def trna_tiling_explore
    ['apicoplast','cytosol'].each do |loc|
      #seq = File.open("#{PHD_DIR}/tiling_array/cysteine tRNA synthetase/#{loc}.seq").read
      seq = File.open("#{PHD_DIR}/tiling_array/trna/#{loc}.seq").read
      #File.open("#{PHD_DIR}/tiling_array/cysteine tRNA synthetase/#{loc}.probes", 'w') do |f|
      File.open("#{PHD_DIR}/tiling_array/trna/#{loc}.probes", 'w') do |f|
        CodingRegion.new.winzeler_tiling_array_probes(seq).each do |probe|
          p = PfalciparumTilingArray.find_by_probe(probe.strip)
          unless p
            $stderr.puts "Couldn't find '#{probe}' from #{loc}"
            next
          end
          PfalciparumTilingArray::MEASUREMENT_COLUMNS.each do |col|
            f.puts [
              probe, p.sequence, p.send(col)
            ].join("\t")
          end
        end
      end
    end
  end

  # Generate the names of
  def generate_winzeler_purdom_tab
    # Probe_ID		X	Y	Probe_Sequence	Group_ID		Unit_ID
    #15	14	0	TCTCCAGTGAAGTGCACATTGCTCA	3029044	ENSG00000106144
    #17	16	0	TGATCGCCTGTCTGCAGATAGGGCA	2400195	ENSG00000090432

    # lines up with how the sequence names are created in sequenceNamer.pl
    index = 1

    map = ProbeMap.find_by_name 'Winzeler 2003 PlasmoDB 5.5'

    File.open("#{PHD_DIR}/winzeler/5.5/MalariaChipProbes.Purdom.tab",'w') do |f|

      f.puts %w(Probe_ID		X	Y	Probe_Sequence	Group_ID		Unit_ID).join("\t")
      
      #Gene,X,Y,ProbeSequence
      #AFFX-18SRNAMur/X00686_3_at,26,3,
      #AFFX-18SRNAMur/X00686_3_at,104,9,
      FasterCSV.foreach('/home/ben/phd/data/falciparum/microarray/Winzeler2003/MalariaChipProbes.csv',
        :headers => true
      ) do |row|
        x = row[1]
        y = row[2]
        sequence = row[3]

        probes = ProbeMapEntry.find_all_by_probe_map_id_and_probe_id(map.id, index)
        #ignore probes that have no genes or multiple transcripts
        if probes.length == 1
          probe = probes[0]

          f.puts [
            index,
            x,
            y,
            sequence,
            probe.coding_region.id,
            probe.coding_region.string_id
          ].join("\t")
        else
          f.puts [
            index,
            x,
            y,
            sequence,
            1,
            'nothn'
          ].join("\t")
        end

        index += 1 if sequence
      end
    end
  end

  def upload_conserved_domains
    ConservedDomain.new.upload_from_eupathdb("#{DATA_DIR}/falciparum/genome/plasmodb/5.5/PfalciparumInterpro_PlasmoDB-5.5.txt", Species::FALCIPARUM_NAME)
  end

  def conserved_domains_explore
    ConservedDomain::TYPES.each do |domain_type|
      collected = []
      domain_type.all(:select => 'distinct(identifier)', :joins => {:coding_region => :expressed_localisations}).each do |domain|
        d = domain_type.find_by_identifier(domain.identifier)
        block = [
          CodingRegion.falciparum.count(:select => 'distinct(coding_regions.id)',
            :joins => [:conserved_domains, :expressed_localisations],
            :conditions => {:conserved_domains => {:identifier => domain.identifier}}),
          CodingRegion.falciparum.count(:select => 'distinct(coding_regions.id)',
            :joins => :conserved_domains,
            :conditions => {:conserved_domains => {:identifier => domain.identifier}}),
          domain.identifier,
          d.name,
          CodingRegion.falciparum.all(:select => 'distinct(coding_regions.id)',
            :joins => [:conserved_domains, :expressed_localisations],
            :conditions => {:conserved_domains => {:identifier => domain.identifier}}
          ).collect{|c| "#{c.annotation.annotation}: #{c.tops.uniq.reach.name.join('|')}"},
        ]
        collected.push block
      end

      File.open("#{PHD_DIR}/domains/explore_#{domain_type}.csv",'w') do |f|
        f.puts collected.sort{|a,b| b[0].to_i <=> a[0].to_i}.collect{|a| a.join("\t")}.join("\n")
      end
    end
  end

  def food_vacuole_proteome_to_database
    exp = ProteomicExperiment.find_or_create_by_name(ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_NAME)

    FasterCSV.foreach("#{DATA_DIR}/falciparum/proteomics/FoodVacuole2008/FoodVacuoleProteome.csv",
      :col_sep => "\t"
    ) do |row|
      next unless row[0] and row[0].strip.length > 0

      plasmo = row[1].strip
      peptides = row[4].strip.to_i
      code = CodingRegion.ff(plasmo)
      if code
        ProteomicExperimentResult.find_or_create_by_coding_region_id_and_number_of_peptides_and_proteomic_experiment_id(
          code.id,
          peptides,
          exp.id
        )
      else
        $stderr.puts "Cmon #{plasmo} from #{row.inspect}"
      end
    end
  end

  def whole_cell_proteome_to_database
    header = true #still in the top crap?
    finished = false
    code = nil
    first = true
    skipping = false

    sp = ProteomicExperiment.find_or_create_by_name(ProteomicExperiment::FALCIPARUM_WHOLE_CELL_2002_SPOROZOITE_NAME)
    mero = ProteomicExperiment.find_or_create_by_name(ProteomicExperiment::FALCIPARUM_WHOLE_CELL_2002_MEROZOITE_NAME)
    troph = ProteomicExperiment.find_or_create_by_name(ProteomicExperiment::FALCIPARUM_WHOLE_CELL_2002_TROPHOZOITE_NAME)
    game = ProteomicExperiment.find_or_create_by_name(ProteomicExperiment::FALCIPARUM_WHOLE_CELL_2002_GAMETOCYTE_NAME)

    #how many peptides per coding region given
    sp_count = 0
    mero_count = 0
    troph_count = 0
    game_count = 0

    sp_percent = nil
    mero_percent = nil
    troph_percent = nil
    game_percent = nil
    
    FasterCSV.foreach("#{DATA_DIR}/falciparum/proteomics/WholeCell2002/nature01107-s1.csv",
      :col_sep => "\t"
    ) do |row|
      if header
        next unless row[0] == "Locus (a)"
        header = false
        next
      end

      # What is this rubbish?
      next if row[1] == 'X' or row[2] == 'X' or row[3] == 'X' or row[4] == 'X'
      break if row[0] == 'Summary'

      unless row[0] and row[0].strip.length > 0 #blank lines indicate the end of a protein block
        finished = true
        skipping = false
      else
        next if skipping
        
        if finished
          # start a new block of hits for a gene
          plasmo = row[0].strip
          # skip some
          if %w(PFD0845w PFD0965w PFD0510c).include?(plasmo)
            $stderr.puts "Ignoring #{plasmo} as expected."
            skipping = true
            next
          end
          code = CodingRegion.ff(plasmo) or raise Exception, "Couldn't find #{row[0].strip} in #{row.inspect}"

          if first
            first = false
          else
            # upload the coding region from last time
            ProteomicExperimentResult.find_or_create_by_coding_region_id_and_number_of_peptides_and_percentage_and_proteomic_experiment_id(code.id, sp_count, sp_percent, sp.id) if sp_count > 0
            ProteomicExperimentResult.find_or_create_by_coding_region_id_and_number_of_peptides_and_percentage_and_proteomic_experiment_id(code.id, mero_count, mero_percent, mero.id) if mero_count > 0
            ProteomicExperimentResult.find_or_create_by_coding_region_id_and_number_of_peptides_and_percentage_and_proteomic_experiment_id(code.id, troph_count, troph_percent, troph.id) if troph_count > 0
            ProteomicExperimentResult.find_or_create_by_coding_region_id_and_number_of_peptides_and_percentage_and_proteomic_experiment_id(code.id, game_count, game_percent, game.id) if game_count > 0
          end
          # reset the stuff
          sp_count = 0
          mero_count = 0
          troph_count = 0
          game_count = 0

          sp_percent = row[1]
          mero_percent = row[2]
          troph_percent = row[3]
          game_percent = row[4]

          finished = false
        else
          # a row containing info on 1 peptide
          sp_count += 1 if row[1] and row[1].strip.length > 0
          mero_count += 1 if row[2] and row[2].strip.length > 0
          troph_count += 1 if row[3] and row[3].strip.length > 0
          game_count += 1 if row[4] and row[4].strip.length > 0
        end
      end
      
    end
  end

  def bug_test
    #    Mscript.new.are_genes_enzymes_or_lethal?("#{PHD_DIR}/essentiality/bug/all_ortho_cel_genes_in_groups_first9000")
    #    Mscript.new.are_genes_enzymes_or_lethal?("#{PHD_DIR}/essentiality/bug/all_ortho_cel_genes_in_groups_last8411")
    Mscript.new.are_genes_enzymes_or_lethal?("#{PHD_DIR}/essentiality/bug/all_ortho_cel_genes_NOT_in_groups")
  end

  def yeast_mrna_decay_fasta
    File.open("#{PHD_DIR}/mRNA_degradation/yeast.GO0000184.txt").each do |line|
      line.strip!
      code = CodingRegion.fs(line, 'yeast')
      if code
        puts code.amino_acid_sequence.fasta
      else
        $stderr.puts "Couldn't find #{line}"
      end
    end
  end

  def lineage_specific_essentiality
    puts [
      "Species",
      'lethal',
      'total',
      'percent'
    ].join("\t")

    [
      Species::DROSOPHILA_NAME,
      Species::YEAST_NAME,
      Species::ELEGANS_NAME,
      Species::MOUSE_NAME
    ].each do |species_name|
      species = Species.find_by_name(species_name)
      lethal_count = 0
      total_count = 0

      OrthomclGene.official.no_group.code(species.orthomcl_three_letter).all.each do |og|
        begin
          lethal = og.single_code.lethal?
          if lethal
            lethal_count += 1
            total_count += 1
          elsif lethal.nil?
          else
            total_count += 1
          end
        
        rescue OrthomclGene::UnexpectedCodingRegionCount
        end
      end

      puts [
        species.name,
        lethal_count,
        total_count,
        lethal_count.to_f/total_count.to_f*100
      ].join("\t")
    end

  end

  # make a spreadsheet for florian so that we can compare the different
  # localisations.
  # manualXX.csv was created by copying from the spreadsheets florian gave me in
  # https://mail.google.com/mail/?zx=hbp8tycn7jiw&shva=1#inbox/1203ab991564fd7a
  def florian_manual_tmd_to_spreadsheet
    FasterCSV.foreach("#{PHD_DIR}/florian manual tmd/manual20090325.csv", :headers => true) do |row|
      localisation = row[0]
      plasmo_id = row[1]
      tmd_string = row[2]

      #parse the tmd bit
      tmds = tmd_string.split('-')
      raise unless tmd_string.length == 2
      tmd = Transmembrane.new
      tmd.start = tmds[0].strip.to_i
      tmd.stop = tmds[1].strip.to_i

      code = CodingRegion.ff(plasmo_id)
      raise unless code

      tmhmm = code.tmhmm_minus_signal_peptide
    end
  end

  # create a graph of the median expression of each localisation, so
  # the comparative ups and downs can be shown on a graph
  def median_expression_localisations
    derisi_timepoints = Microarray.find_by_description(Microarray.derisi_2006_3D7_default).microarray_timepoints(:select => 'distinct(name)').select do |t|
      t.name.match(/Timepoint/)
    end
    
    acceptibles = LocalisationMedianMicroarrayMeasurement::LOCALISATIONS
    
    # collect the coding regions and measurements
    codes = PlasmodbGeneList.find_by_description(
      PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME
    ).coding_regions.all().collect do |code|
      name = code.tops[0].name
      #      puts [name, MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(
      #          code.id,
      #          derisi_timepoints[0].id
      #        ).nil? ? nil : measurement
      #      ].join("\t")

      if acceptibles.include?(name)

        derisis = derisi_timepoints.collect do |timepoint|
          measures = MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(
            code.id,
            timepoint.id
          )
          if !measures.nil?
            measures.measurement
          else
            nil
          end
        end

        [name, derisis].flatten
      else
        nil
      end
    end

    # process the coding regions into localisations
    # {localisation => [timepoint][measurement]}
    locs = {}

    codes.each do |arr|
      next if arr.nil?
      locs[arr[0]] ||= []

      # push each measurement into the hash if it isn't nil
      arr[1..arr.length-1].each_with_index do |measurement, index|
        next if measurement.nil?
        locs[arr[0]][index] ||= []
        locs[arr[0]][index].push measurement
      end
    end
    return locs
  end

  def median_expression_localisation_graphs
    locs = median_expression_localisations
    # for each localisation at each timepoint, print the median value
    puts ['localisation', derisi_timepoints.reach.name.retract].flatten.join("\t")
    locs.each do |loc, values|
      puts [
        loc,
        values.collect{|t| t.median}
      ].flatten.join("\t")
    end
  end

  # Generate the median localisations for each localisation
  def generate_median_microarray_timepoints
    locs = median_expression_localisations

    microarray = Microarray.find_or_create_by_description(Microarray::DERISI_3D7_LOCALISATION_MEDIAN_TIMEPOINTS)

    locs.each do |loc, values|
      values.each_with_index do |individuals, index|
        timepoint = MicroarrayTimepoint.find_or_create_by_name_and_microarray_id(
          MicroarrayTimepoint.get_derisi_3d7_localisation_median_name(loc, index+1),
          microarray.id
        )
        median = individuals.median
        unless timepoint.localisation_median_microarray_measurements.empty?
          raise Exception unless timepoint.localisation_median_microarray_measurements.length == 1 and
            timepoint.localisation_median_microarray_measurements[0].measurement == median
        else
          LocalisationMedianMicroarrayMeasurement.find_or_create_by_microarray_timepoint_id_and_measurement(
            timepoint.id, median
          ) or raise
        end
      end
    end
  end

  def exported_derisi_measurements
    derisi_timepoints = Microarray.find_by_description(Microarray.derisi_2006_3D7_default).microarray_timepoints.all(
      :conditions => ['name like ?','%Timepoint%']
    )

    # Headings
    puts derisi_timepoints.reach.name.join("\t")

    PlasmodbGeneList.find_by_description(
      PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME
    ).coding_regions.each do |code|
      next unless code.uniq_top? and code.tops[0].name == 'exported'

      puts derisi_timepoints.collect{|dt|
        m = MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(code.id, dt)
        m.nil? ? 'NA' : m.measurement
      }.join("\t")
    end
  end

  def iterate_weka_to_choose_localisations
    require 'gsl'
    
    total_number_of_classes = 15
    (2..total_number_of_classes).each do |nclasses|
      c = GSL::Combination(total_number_of_classes, nclasses)
      indices = (1..nclasses).collect{|i| c[i]}

      # test out these combinations - how well does it predict?
    end
  end

  def upload_lacount_yeast_two_hybrid
    net = Network.find_or_create_by_name(
      Network::LACOUNT_2005_NAME
    )
    bads = 0
    goods = 0

    FasterCSV.foreach("#{DATA_DIR}/falciparum/interaction/LaCount2005/nature04104-s6.txt",
      :col_sep => "\t", :headers => true) do |row|

      code1 = CodingRegion.ff(row[0])
      code2 = CodingRegion.ff(row[4])

      if code1.nil? or code2.nil?
        bads += 1
        next
      end

      CodingRegionNetworkEdge.find_or_create_by_network_id_and_coding_region_id_first_and_coding_region_id_second(
        net.id, code1.id, code2.id
      ) or raise
      goods += 1
    end

    puts "#{goods} good, #{bads} bad."
  end

  def upload_wuchty_gene_network
    net = Network.find_or_create_by_name(
      Network::WUCHTY_2009_NAME
    )
    bads = 0
    goods = 0

    first = true
    FasterCSV.foreach("#{DATA_DIR}/falciparum/interaction/Wuchty2009/sm002.csv",
      :col_sep => "\t", :headers => true) do |row|

      if first # skip the first 2 lines
        first = false
        next
      end

      code1 = CodingRegion.ff(row[0])
      code2 = CodingRegion.ff(row[2])

      if code1.nil? or code2.nil?
        bads += 1
        next
      end

      CodingRegionNetworkEdge.find_or_create_by_network_id_and_coding_region_id_first_and_coding_region_id_second(
        net.id, code1.id, code2.id
      ) or raise
      goods += 1
    end

    puts "#{goods} good, #{bads} bad."
  end
  
  def falciparum_apiloc_counts
    File.open("#{PHD_DIR}/gene lists/counts/falciparum.tab",'w') do |f|
      f.puts ['Localisation', 'Count'].join("\t")
      TopLevelLocalisation.all.sort{|a,b| a.name <=> b.name}.each do |t| 
        f.puts [
          t.name, 
          CodingRegion.falciparum.top(t.name).count(:select =>'distinct(coding_regions.id)')
        ].join("\t")
      end
    end
  end

  # Find all the orthomcl groups that are specific to alveolates in OrthoMCL,
  # and then retrieve the falciparum sequence from that.
  def apicomplexa_specific_example_sequences
    # The list of groups has been compiled by copy and pasting the whole
    # web pages and then grepping the text versions of them.
    File.foreach("#{PHD_DIR}/algae_search/apicomplexa_specific/specific.orthomcl_groups.txt") do |line|
      puts OrthomclGroup.official.find_by_orthomcl_name(line.strip).orthomcl_genes.code('pfa').first.orthomcl_gene_official_data.fasta
    end
  end

  # Find all the orthomcl groups that are specific to alveolates in OrthoMCL,
  # and then retrieve the tth sequence from that.
  def teaching_apicomplexa_specific_example_sequences
    # The list of groups has been compiled by copy and pasting the whole
    # web pages and then grepping the text versions of them.
    File.foreach("#{PHD_DIR}/algae_search/teaching/TthTpsPossiblyApi.orthomcl.txt") do |line|
      puts OrthomclGroup.official.find_by_orthomcl_name(line.strip).orthomcl_genes.code('tth').all.reach.orthomcl_gene_official_data.fasta.join("\n")
    end
  end

  # Given a file of -m 8 blast results, find queries and hits where the
  # query gene hits against 2 genes that have actually been split according
  # to the genome annotation
  def babesia_split_genes(filename="#{PHD_DIR}/babesiaApicoplastReAnnotation/babesia_split_genes/PfaVBbo.blastp.blast.tab")
    hash = {}
    
    # read in the hit groups
    FasterCSV.foreach(filename, :col_sep => "\t") do |row|
      query = row[0]
      hit = row[1]

      hash[query] ||= []
      hash[query].push hit
    end

    hash.each do |query, hits|
      consecutives = []
      hits.each do |hit|
        code = CodingRegion.find_by_name_or_alternate_and_organism(hit, Species::BABESIA_BOVIS_NAME)
        upstream = code.upstream_coding_region

        # if an upstream gene exists and this query also hits that upstream
        # gene, we've found something
        if upstream and hits.include?(upstream.string_id)
          consecutives.push upstream.string_id, code.string_id
        end
      end

      unless consecutives.empty?
        puts [query, consecutives.sort.uniq].flatten.join("\t")
      end
    end
  end
end
