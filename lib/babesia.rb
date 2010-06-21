#require 'b_script'

class Babesia
  def seven_species_orthomcl_upload
    run = OrthomclRun.find_or_create_by_name(OrthomclRun.seven_species_filtering_name)

    #Setup babesia and TANN genes and scaffs
    #    babSpecies = Species.find_or_create_by_name('Babesia bovis')
    #    #babScaff might not be used in the end, because babesia has been uploaded properly.
    #    babScaff = Scaffold.find_or_create_by_name_and_species_id("Babesia dummy", babSpecies.id)
    tannSpecies = Species.find_or_create_by_name('Theileria annulata')
    tannScaff = Scaffold.find_or_create_by_name_and_species_id("Theileria annulata dummy", tannSpecies.id)
    parvSpecies = Species.find_or_create_by_name('Cryptosporidium parvum')
    parvScaff = Scaffold.find_or_create_by_name_and_species_id("Cryptosporidium parvum dummy", parvSpecies.id)
    chomSpecies = Species.find_or_create_by_name('Cryptosporidium hominis')
    chomScaff = Scaffold.find_or_create_by_name_and_species_id("Cryptosporidium hominis dummy", chomSpecies.id)

    File.open("#{BScript::PHD_DIR}/babesiaApicoplastReAnnotation/Apr_17/all_orthomcl.out").each do |groupline|
      splits = groupline.split("\t")

      if splits.length != 2
        raise Exception, "Badly parsed line"
      end

      # eg. 'ORTHOMCL0(161 genes,1 taxa):\t'
      matches = splits[0].match('(ORTHOMCL\d+)\(.*')
      group = OrthomclGroup.find_or_create_by_orthomcl_name(
        matches[1],
        run.id
      )

      splits[1].split(' ').each do |ogene|
        # eg. TA02955(TANN.GeneDB.pep)
        matches = ogene.match('^(.+)\((.*)\)$')
        if !matches
          raise Exception, "Badly parsed gene: '#{ogene}'"
        end

        # Create the gene and link it in
        orthomcl_gene = OrthomclGene.find_or_create_by_orthomcl_name(
          matches[1]
        )
        raise unless OrthomclGeneOrthomclGroupOrthomclRun.find_or_create_me(
          orthomcl_gene.id, group.id, run.id
        )

        # Join it up with the rest of the database
        code = nil

        case matches[2]
        when 'BabesiaWGS'
          # Only create the new gene and database if the coding region doesn't already exist
          raise if !code = CodingRegion.fs(matches[1], Species.babesia_bovis_name)
        when 'TANN.GeneDB.pep'
          # gene won't exist in database. Have to create it
          g = Gene.find_or_create_by_name_and_scaffold_id(
            matches[1],
            tannScaff.id
          )
          code = CodingRegion.find_or_create_by_string_id_and_gene_id(
            matches[1],
            g.id
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
          ems = matches[1].match('Cryptosporidium_parvum\|.*?\|(.+?)\|Annotation\|.+\|\(protein')
          if !ems
            raise Exception, "Badly handled crypto: #{matches[1]}"
          end

          if !code = CodingRegion.fs(ems[1], Species.cryptosporidium_parvum_name)

            # gene won't exist in database. Have to create it
            g = Gene.find_or_create_by_name_and_scaffold_id(
              ems[1],
              parvScaff.id
            )
            code = CodingRegion.find_or_create_by_string_id_and_gene_id(
              ems[1],
              g.id
            )
          end
        when 'PvivaxAnnotatedProteins_plasmoDB-5.2'
          #          p 'found a vivax'
          ems = matches[1].match('Plasmodium_vivax.*?\|.*?\|(.*)\|Pv')
          # As of March 25, 2009, there is a bug in PlasmoDB vivax where the
          # gene aliases file is effectively empty, and all of the 5.5 names
          # are changed relative to 5.4 names.
          # However, according to
          # personal communication with Omar Harb, most of them will just
          # be a simple conversion, for instance
          # Pv002715 -> Pv002715
          name = ems[1].gsub(/^Pv/, 'PVX_')
          code = CodingRegion.fs(name, Species.vivax_name)
        when 'TPA1.pep'
          code = CodingRegion.fs(matches[1], Species.theileria_parva_name)
        else
          if matches[1].match('^Plasmodium_falciparum_3D7')
            ems = matches[1].match('Plasmodium_falciparum_3D7\|.*?\|(.*)\|Pf')
            code = CodingRegion.ff(ems[1])
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

  # Find all the genes where there is a 5 prime extension (but without the need of an upstream exon) relative to the
  # official genome. Assumes Script.new.babesia_bovis_cds and verification
  def babesia_five_prime_extensions
    # for each of the generated coding regions
    require 'orf_finder'
    finder = Orf::OrfFinder.new
    Bio::FlatFile.auto("#{BScript::DATA_DIR}/bovis/genome/NCBI/BabesiaWGS-96909.fasta").each do |seq|
      genbank_id = seq.definition.match(/^Babesia bovis .*, whole genome shotgun sequence. \| (\S+)$/)[1]
      scaff = Scaffold.find_by_name "#{genbank_id}.gb"
      raise if !scaff
      next unless genbank_id == 'AAXT01000003'
      puts 'yey'

      #      # forward direction
      #      orf_threads = finder.generate_longest_orfs(seq.seq)
      #      orf_threads.each do |orfs|
      #        orfs.each do |orf|
      #          if orf.length > 1
      #            # Does this orf encompass another one that is already in the genome?
      #            codes = CodingRegion.all(
      #              :include => [
      #                :cds,
      #                {:gene => {:scaffold => :species}}
      #              ],
      #              :conditions =>
      #                "species.name = '#{Species::BABESIA_BOVIS_NAME}' and "+ # must be babesia
      #                "coding_regions.orientation = '#{CodingRegion.positive_orientation}' and "+ # Coding regions must be positive
      #              "genes.scaffold_id = #{scaff.id} and "+ #has to be on the same stretch
      #              "cds.start-1 > #{orf.start} and cds.stop-1 <= #{orf.stop} and "+# start must be before and end same or after
      #              "(cds.start - #{orf.start}) % 3 = 1" #must be in frame. 1 is somewhat of a hack, but seems to be true for BBOV_III000190
      #            )
      #            codes.each do |code|
      #              puts [
      #                code.string_id,
      #                code.cds[0].start,
      #                orf.start,
      #                code.orientation,
      #                orf.aa_sequence,
      #                code.amino_acid_sequence.sequence
      #              ].join("\t")
      #            end
      #          end
      #        end
      #      end

      # reverse direction
      orf_threads = finder.generate_longest_orfs(Bio::Sequence::NA.new(seq.seq).reverse_complement)
      orf_threads.each do |orfs|
        orfs.each do |orf|
          if orf.length > 1
            # Does this orf encompass another one that is already in the genome?
            p orf.inspect
            orf = Orf::Orf.new
            orf.start = 0
            orf.stop = 727085

            codes = CodingRegion.all(
              :include => [
                :cds,
                {:gene => {:scaffold => :species}}
              ],
              :conditions =>
                "species.name = '#{Species::BABESIA_BOVIS_NAME}' and "+ # must be babesia
              "coding_regions.orientation = '#{CodingRegion.negative_orientation}' and "+ # Coding regions must be positive
              "genes.scaffold_id = #{scaff.id} and "+ #has to be on the same stretch
              "cds.stop < #{seq.length-orf.stop-1} and cds.start >= #{seq.length-orf.start-1} and "+ # start must be before and end same or after
              "(#{seq.length-orf.stop-1} - cds.stop) % 3 = 0 and "+ #must be in frame. 1 is somewhat of a hack, but seems to be true for BBOV_III000190
              "cds.order = 1" # must be the first exon
            )
            codes.each do |code|
              puts [
                code.string_id,
                code.cds.first.stop,
                orf.stop,
                code.orientation,
                orf.aa_sequence,
                code.amino_acid_sequence.sequence,
                orf.inspect
              ].join("\t")
              return
            end
#            return
          end
        end
      end
    end
  end

  # add a new order column to cds so that I can filter it so only the first
  # exon in the gene is counted
  def babesia_cds_order
    CodingRegion.s(Species::BABESIA_BOVIS_NAME).all.each do |code|
      count = 1
      if code.positive_orientation?
        code.cds.all(:order => 'start asc').each do |cd|
          cd.order = count
          cd.save!
          count += 1
        end
      elsif code.negative_orientation?
        code.cds.all(:order => 'start desc').each do |cd|
          cd.order = count
          cd.save!
          count += 1
        end
      end
    end
  end

  # Given a file of -m 8 blast results, find queries and hits where the
  # query gene hits against 2 genes that have actually been split according
  # to the genome annotation.
  def babesia_split_genes(filename="#{BScript::PHD_DIR}/babesiaApicoplastReAnnotation/babesia_split_genes/PfaVBbo.blastp.blast.tab")
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

  #  # I hate this s
  #  def babesia_five_prime_extensions2
  #
  #  end
end
