require 'jgi_genes'
require 'simple_go'
require 'rio'
require 'api_db_genes'
require 'yeast_genome_genes'
require 'signalp'
require 'api_db_fasta'
require 'tm_hmm_wrapper'
require 'rubygems'
require 'csv'
require 'bio'
require 'mscript'

MOLECULAR_FUNCTION = 'molecular_function'
YEAST = 'yeast'


WORK_DIR = "#{ENV['HOME']}/Workspace"

PHD_DIR = "#{ENV['HOME']}/phd"
DATA_DIR = "#{ENV['HOME']}/phd/data"

class Script < ActiveRecord::Base
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
    require 'lib/simple_go'
    
    GoAlternate.destroy_all
    GoTerm.destroy_all
    

    sg = SimpleGo.new("#{DATA_DIR}/GO/20080321/gene_ontology_edit.obo")
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
  
  def apidb_species_to_database(species_name, gff_file_path)
    
    sp = Species.find_or_create_by_name species_name
    #        sp.scaffolds.each do |scaff|
    #          scaff.destroy
    #        end
    
    iter = ApiDbGenes.new(gff_file_path)

    puts "Inserting..."
    
    gene = iter.next_gene
    
    while gene
      
      # Create scaffold if not done already
      if !gene.seqname
        raise Exception, "No seqname in gene: #{gene}"
      end
      scaff = Scaffold.find_or_create_by_name_and_species_id(
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
      
      gene = iter.next_gene
    end

    puts "finished."
  end
  
  def falciparum_to_database
    # abstraction!
    apidb_species_to_database Species.falciparum_name, "#{DATA_DIR}/falciparum/genome/plasmodb/5.4/Pfalciparum_3D7_plasmoDB-5.4.gff"
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
      "#{PHD_DIR}/babesiaApicoplastReAnnotation/annotation1/Pvi_Pfa_Tpa_HIGH_confid_set3",
      "#{PHD_DIR}/babesiaApicoplastReAnnotation/annotation1/Pvi_Pfa_Tpa_LOWER_confid_set"
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
      scaff.destroy
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
          end
        end
      end
    end
  end
  
  # Count each group 
  def localisation_counts
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
  end  
  
  # Assumes that the vulgar file has already been created as per 
  # tiddlywiki:[[Re-annotating Winzeler]]
  def generate_winzeler_probe_map
    #Read in a single line of the file
    f = File.open("#{ENV['HOME']}/phd/winzeler/probesVtranscripts.vulgar")
    
    map_name = 'Winzeler 2003 PlasmoDB 5.4'
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
      splits = line.split ' '
      if splits[0] != 'vulgar:'
        raise Exception, "Unexpected line: #{line}"
      end
      
      seqname = splits[1]
      transcript_name = splits[5]
      
      seqname = seqname.sub 'seq',''
      tsplits = transcript_name.split '|'
      plasmodbid = tsplits[2]
      
      code = CodingRegion.find_by_name_or_alternate(plasmodbid)
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
  
  
  # Load the data from the groups file alone - upload all genes and groups
  # in the process
  def orthomcl_groups_to_database(filename="#{DATA_DIR}/orthomcl/groups_orthomcl-2.txt")
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
      
      g = OrthomclGroup.find_or_create_by_orthomcl_run_id_and_orthomcl_name(run.id, splits1[0])
      
      splits2 = splits1[1].split(' ')
      if splits2.length < 1
        raise Exception, "Bad line (2): #{line}"
      end
      splits2.each do |name|
        OrthomclGene.find_or_create_by_orthomcl_group_id_and_orthomcl_name(g.id, name)
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
  
  # A generic method for uploading a bunch of genes using stdin
  # description - the name of the list
  # organism - the common name for the organism the gene is for. nil means organism isn't considered when uploading the data
  def create_gene_list(description, organism=nil)
    if !description or description ===''
      raise Exception, "Bad gene list description: '#{description}'"
    end
    
    list = PlasmodbGeneList.create(
      :description => description
    )
    
    $stdin.each do |line|
      line.strip!
      
      if organism
        code = CodingRegion.find_by_name_or_alternate_and_organism(line, organism)
      else
        code = CodingRegion.find_by_name_or_alternate(line)
      end
      
      if !code
        $stderr.puts "Warning no coding region found for #{line}"
      else
        PlasmodbGeneListEntry.find_or_create_by_plasmodb_gene_list_id_and_coding_region_id(
          list.id,
          code.id
        )
      end
    end
    
    hits = PlasmodbGeneListEntry.count(:conditions => "plasmodb_gene_list_id=#{list.id}")
    
    puts "Uploaded #{hits} different coding regions"
  end
  
  # Basically fill out the orthomcl_gene_coding_regions table appropriately
  # for only the official one
  def link_orthomcl_and_coding_regions(*interesting_orgs)
    goods = 0
    if !interesting_orgs
      #    interesting_orgs = ['pfa','pvi','the','tan','cpa','cho','ath']
      #    interesting_orgs = ['pfa','pvi','the','tan','cpa','cho']
      #    interesting_orgs = ['ath']
      interesting_orgs = ['cel']
    end
    thing = "orthomcl_genes.orthomcl_name like '"+
      interesting_orgs.join("%' or orthomcl_genes.orthomcl_name like '")+
      "%'"
    
    puts "linking genes for species: #{interesting_orgs.inspect}: #{thing}"
    
    # Maybe a bit heavy handed but ah well.
    OrthomclGene.all(
      :joins => {:orthomcl_group => :orthomcl_run},
      :conditions => "orthomcl_runs.name='#{OrthomclRun.official_run_v2_name}'"+
        " and (#{thing})").each do |orthomcl_gene|
    
      code = orthomcl_gene.compute_coding_region
      if !code
        #        next #ignore for the moment
        #        raise Exception, "No coding region found for #{orthomcl_gene.inspect}"
        #        $stderr.puts "No coding region found for #{orthomcl_gene.inspect}"
        next
      else
        goods += 1
      end
      
      OrthomclGeneCodingRegion.find_or_create_by_orthomcl_gene_id_and_coding_region_id(
        orthomcl_gene.id,
        code.id
      )
    end
    
    puts "Properly linked #{goods} coding regions"
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
    apidb_species_to_database(Species.vivax_name, "#{DATA_DIR}/vivax/genome/plasmodb/5.4/Pvivax_Salvador1_plasmoDB-5.4.gff")
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
    run = OrthomclRun.find_or_create_by_name("Seven species for Babesia")
    
    #Setup babesia and TANN genes and scaffs
    babSpecies = Species.find_or_create_by_name('Babesia bovis')
    babScaff = Scaffold.find_or_create_by_name_and_species_id("Babesia dummy", babSpecies.id)
    tannSpecies = Species.find_or_create_by_name('Theileria annulata')
    tannScaff = Scaffold.find_or_create_by_name_and_species_id("Theileria annulata dummy", tannSpecies.id)
    parvSpecies = Species.find_or_create_by_name('Cryptosporidium parvum')
    parvScaff = Scaffold.find_or_create_by_name_and_species_id("Cryptosporidium parvum dummy", parvSpecies.id)
    chomSpecies = Species.find_or_create_by_name('Cryptosporidium hominis')
    chomScaff = Scaffold.find_or_create_by_name_and_species_id("Cryptosporidium hominis dummy", chomSpecies.id)
    
    File.open("#{PHD_DIR}/babesiaApicoplastReAnnotation/Apr_17/all_orthomcl.out").each do |groupline|
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
        code = nil
        
        case matches[2]
        when 'BabesiaWGS'
          # gene won't exist in database. Have to create it
          g = Gene.find_or_create_by_name_and_scaffold_id(
            matches[1],
            babScaff.id
          )
          code = CodingRegion.find_or_create_by_string_id_and_gene_id_and_orientation(
            matches[1],
            g.id,
            CodingRegion.unknown_orientation_char
          )
        when 'TANN.GeneDB.pep'
          # gene won't exist in database. Have to create it
          g = Gene.find_or_create_by_name_and_scaffold_id(
            matches[1],
            tannScaff.id
          )
          code = CodingRegion.find_or_create_by_string_id_and_gene_id_and_orientation(
            matches[1],
            g.id,
            CodingRegion.unknown_orientation_char
          )
        when 'ChominisAnnotatedProtein.fsa'
          # gene won't exist in database. Have to create it
          
          ems = matches[1].match('Cryptosporidium_.*?\|.*?\|(.*)\|Annotation\|GenBank|\(protein')
          if !ems
            raise Exception, "Unexpected gene name: #{code.string_id}"
          end
          
          g = Gene.find_or_create_by_name_and_scaffold_id(
            ems[1],
            chomScaff.id
          )
          code = CodingRegion.find_or_create_by_string_id_and_gene_id_and_orientation(
            ems[1],
            g.id,
            CodingRegion.unknown_orientation_char
          )
          
        when 'CparvumAnnotatedProtein.fsa'
          # gene won't exist in database. Have to create it
          g = Gene.find_or_create_by_name_and_scaffold_id(
            matches[1],
            parvScaff.id
          )
          code = CodingRegion.find_or_create_by_string_id_and_gene_id_and_orientation(
            matches[1],
            g.id,
            CodingRegion.unknown_orientation_char
          )
        when 'PvivaxAnnotatedProteins_plasmoDB-5.2'
          #          p 'found a vivax'
          ems = matches[1].match('Plasmodium_vivax.*?\|.*?\|(.*)\|Pv')
          code = CodingRegion.find_by_name_or_alternate(ems[1])
        when 'TPA1.pep'
          code = CodingRegion.find_by_name_or_alternate(matches[1])
        else
          if matches[1].match('^Plasmodium_falciparum_3D7')
            ems = matches[1].match('Plasmodium_falciparum_3D7\|.*?\|(.*)\|Pf')
            code = CodingRegion.find_by_name_or_alternate(ems[1])
          else
            raise Exception, "Didn't recognize source: '#{matches[2]}', #{matches}"
          end
        end
        
        if !code
          # This can be legit, if a model is present in 5.2 but not 5.4 of orthoMCL
          $stderr.puts "Couldn't find gene model model #{matches[0]}"
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
    #    puts "GO"
    #    go_to_database
    #    puts "Falciparum"
    #    falciparum_to_database
    #    puts "Vivax"
    #    vivax_to_database # this fails with exception because of a known bug in my genes gff parser. It is OK, though - it should validate at least
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

    puts "Big orthomcl linking"
    link_orthomcl_and_coding_regions
  end
  
  
  # upload the fasta sequences from falciparum file to the database
  def falciparum_fasta_to_database
    fa = ApiDbFasta.new.load("#{DATA_DIR}/falciparum/genome/plasmodb/5.4/PfalciparumAnnotatedProteins_plasmoDB-5.4.fasta")
    sp = Species.find_by_name(Species.falciparum_name)
    upload_fasta_general(fa, sp)
  end
  
  # upload the fasta sequences from falciparum file to the database
  def vivax_fasta_to_database
    fa = ApiDbFasta.new.load("#{DATA_DIR}/vivax/genome/plasmodb/5.4/PvivaxAnnotatedProteins_plasmoDB-5.4.fasta")
    sp = Species.find_by_name(Species.vivax_name)
    upload_fasta_general(fa, sp)
  end
  
  
  def crypto_fasta_to_database
    fa = ApiDbFasta.new.load("#{DATA_DIR}/Cryptosporidium parvum/genome/cryptoDB/3.4/CparvumAnnotatedProtein.fsa")
    sp = Species.find_by_name(Species.cryptosporidium_parvum_name)
    upload_fasta_general(fa, sp)
    
    fa = ApiDbFasta.new.load("#{DATA_DIR}/Cryptosporidium hominis/genome/cryptoDB/3.4/ChominisAnnotatedProtein.fsa")
    sp = Species.find_by_name(Species.cryptosporidium_parvum_name)
    upload_fasta_general(fa, sp)
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
    fa = TigrFasta.new("#{DATA_DIR}/Theileria annulata/TANN.GeneDB.pep")
    scaff = Scaffold.find(:first,
      :include => :species,
      :conditions => "species.name='Theileria annulata'"
    )
    upload_fasta_simplistic(fa, scaff)

    fa = TigrFasta.new("#{DATA_DIR}/Theileria parva/TPA1.pep")
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
  def upload_fasta_general(fa, species)
    while f = fa.next_entry
      code = CodingRegion.find_by_name_or_alternate(f.name)
      if !code
        scaff = Scaffold.find_or_create_by_species_id_and_name(
          species.id,
          f.scaffold
        )
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
  
  def upload_orthomcl_official_sequences
    flat = Bio::FlatFile.open(Bio::FastaFormat, "#{WORK_DIR}/Orthomcl/seqs_orthomcl-2.fasta")
    
    run = OrthomclRun.official_run_v2
    
    flat.each do |seq|
      
      # Parse out the official ID
      line = seq.definition
      splits_space = line.split(' ')
      if splits_space.length < 3
        raise Exception, "Badly handled line because of spaces: #{line}"
      end
      orthomcl_id = splits_space[0] 
      
      ogenes = OrthomclGene.find(:all,
        :include => :orthomcl_group,
        :conditions => "orthomcl_groups.orthomcl_run_id=#{run.id} and "+
          "orthomcl_genes.orthomcl_name='#{orthomcl_id}'"
      )
        
      if ogenes.length != 1
        if ogenes.length == 0
          #          raise Exception, "No gene found for #{line}"
          next
          # bleh - I didn't upload singlets to my database, so this is expected
        else
          raise Exception, "Too many genes found for #{orthomcl_id}"
        end
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
        ogenes[0].id,
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
    
    net = GeneNetwork.find_or_create_by_name(
      GeneNetwork.wormnet_name
    )
    first = true
    CSV.open("#{DATA_DIR}/elegans/lee/ng.2007.70-S3.txt", 'r', "\t") do |row|
      
      if first #skip the header line
        first = false
        next
      end
      
      # Wormnet finds genes and not coding regions, which is kind of confusing.
      # find gene if it exists
      g1 = Gene.find_by_name_or_alternate_and_organism(row[0], Species.elegans_name)
      g2 = Gene.find_by_name_or_alternate_and_organism(row[1], Species.elegans_name)

      
      if !g1 or !g2
        $stderr.puts "Couldn't find gene #{row[0]} or #{row[1]}"
        next
      end
      
      GeneNetworkEdge.find_or_create_by_gene_network_id_and_gene_id_first_and_gene_id_second_and_strength(
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
    Mscript.new.celegans_phenotype_information_to_database("#{DATA_DIR}/elegans/essentiality/cel_wormbase_pheno.tsv")
  end
  
  def ben_celegans_phenotype_observed_to_database
    Mscript.new.celegans_phenotype_observed_to_database("#{DATA_DIR}/elegans/essentiality/cel_wormbase_pheno.tsv")
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
      
          c = Cd.find_or_create_by_coding_region_id_and_start_and_stop(
            code.id,
            feature.locations.first.from,
            feature.locations.first.to
          )
          if !c
            raise Exception, "Failed to upload Cd: #{c.inspect}"
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
    Localisation.new.upload_other_falciparum_list
  end
end

