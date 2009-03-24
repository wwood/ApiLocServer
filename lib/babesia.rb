require 'script_constants'

class Babesia
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

  File.open("#{Script::PHD_DIR}/babesiaApicoplastReAnnotation/Apr_17/all_orthomcl.out").each do |groupline|
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
      orthomcl_gene = OrthomclGene.find_or_create_by_orthomcl_name_and_orthomcl_group_id(
        matches[1],
        group.id
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
        code = CodingRegion.fs(ems[1], Species.vivax_name)
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
