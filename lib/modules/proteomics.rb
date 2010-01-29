
class BScript

  def proteomics_to_database
    food_vacuole_proteome_to_database
    whole_cell_proteome_to_database
    maurers_cleft_proteome_to_database
    sumoylation2008_proteome_to_database
  end

  def food_vacuole_proteome_to_database
    pub = Publication.find_or_create_by_url_and_authors_and_date_and_title_and_abstract(
      ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_PUBLICATION_DETAILS[:url],
      ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_PUBLICATION_DETAILS[:authors],
      ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_PUBLICATION_DETAILS[:date],
      ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_PUBLICATION_DETAILS[:title],
      ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_PUBLICATION_DETAILS[:abstract]
    )
    exp = ProteomicExperiment.find_or_create_by_name_and_publication_id(
      ProteomicExperiment::FALCIPARUM_FOOD_VACUOLE_2008_NAME,
      pub.id
    )

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
    $stderr.puts "WARNING! PlasmoDB 6.0 has problems with aliases, and so many old gene names are not mapped, when perhaps they should be! You have been warned."

    header = true #still in the top crap?
    finished = false
    code = nil
    first = true
    skipping = false

    pub = Publication.find_or_create_by_pubmed_id(
      ProteomicExperiment::FALCIPARUM_WHOLE_CELL_2002_PUBMED_ID
    )

    sp = ProteomicExperiment.find_or_create_by_name_and_publication_id(
      ProteomicExperiment::FALCIPARUM_WHOLE_CELL_2002_SPOROZOITE_NAME, pub.id)
    mero = ProteomicExperiment.find_or_create_by_name_and_publication_id(
      ProteomicExperiment::FALCIPARUM_WHOLE_CELL_2002_MEROZOITE_NAME, pub.id)
    troph = ProteomicExperiment.find_or_create_by_name_and_publication_id(
      ProteomicExperiment::FALCIPARUM_WHOLE_CELL_2002_TROPHOZOITE_NAME, pub.id)
    game = ProteomicExperiment.find_or_create_by_name_and_publication_id(
      ProteomicExperiment::FALCIPARUM_WHOLE_CELL_2002_GAMETOCYTE_NAME, pub.id)

    #how many peptides per coding region given
    sp_count = 0
    mero_count = 0
    troph_count = 0
    game_count = 0
    peptides = []
    charges = []
    stages = []

    sp_percent = nil
    mero_percent = nil
    troph_percent = nil
    game_percent = nil

    line_number = 0

    plasmodb_line_next = true

    FasterCSV.foreach("#{DATA_DIR}/falciparum/proteomics/WholeCell2002/nature01107-s1.modified.csv",
      :col_sep => "\t"
    ) do |row|
      line_number += 1
      #      next unless line_number > 10313

      if header
        next unless row[0] == "Locus (a)"
        header = false
        next
      end


      # What is this rubbish?
      next if row[1] == 'X' or row[2] == 'X' or row[3] == 'X' or row[4] == 'X'
      break if row[0] == 'Summary'

      if row[0].nil? or row[0].strip.length == 0 #blank lines indicate the end of a protein block
        skipping = false

        # upload the coding region from last time
        ProteomicExperimentResult.find_or_create_by_coding_region_id_and_number_of_peptides_and_percentage_and_proteomic_experiment_id(code.id, sp_count, sp_percent, sp.id) if sp_count > 0
        ProteomicExperimentResult.find_or_create_by_coding_region_id_and_number_of_peptides_and_percentage_and_proteomic_experiment_id(code.id, mero_count, mero_percent, mero.id) if mero_count > 0
        ProteomicExperimentResult.find_or_create_by_coding_region_id_and_number_of_peptides_and_percentage_and_proteomic_experiment_id(code.id, troph_count, troph_percent, troph.id) if troph_count > 0
        ProteomicExperimentResult.find_or_create_by_coding_region_id_and_number_of_peptides_and_percentage_and_proteomic_experiment_id(code.id, game_count, game_percent, game.id) if game_count > 0

        peptides.each_with_index do |e, i|
          stages[i].each do |stage_id|
            ProteomicExperimentPeptide.find_or_create_by_peptide_and_charge_and_proteomic_experiment_id_and_coding_region_id(
              e, charges[i], stage_id, code.id
            )
          end
        end

        # reset the stuff
        sp_count = 0
        mero_count = 0
        troph_count = 0
        game_count = 0
        peptides = []
        charges = []
        stages = []

        plasmodb_line_next = true
      else
        next if skipping #ignore problematic plasmodb ids

        if plasmodb_line_next
          plasmo = row[0]
          # skip some
          # these gene models are now multiple gene models
          # or have been removed or there is a gene name duplication
          if %w(PFD0845w PFD0965w).push %w(
            PF11_0405
            PF11_0377
            PF10_0014
            PFC0710w
            PF10_0349
            PF10_0212
            PFD0510c
            PF10_0251
            PF10_0387
            ).include?(plasmo)
            $stderr.puts "Ignoring #{plasmo} as expected."
            skipping = true
            next
          end

          manual_mappings = { # these are merged genes. Probably could have
            # achieved the same thing by using the _v5.5 names as aliases
            # too, but it's done now.
            'PFA0215w' => 'PFA0220w',
            'PF14_0436' => 'PF14_0437',
            'PF14_0091' => 'PF14_0092',
            'PF14_0445' => 'PF14_0444',
            'PF10_0247' => 'PF10_0248',
            'PF11_0525' => 'PF11_0535',
            'PFE0325w' => 'PFE0320w',
            'PFE0685w' => 'PFE0680w',
            'PF10_0256' => 'PF10_0254',
            'PF14_0263' => 'PF14_0262',
            'MAL8P1.94' => 'PF08_0081',
            'PF14_0172' => 'PF14_0173',
            'PF11_0387' => 'PF11_0388',
            'MAL13P1.123' => 'MAL13P1.124',
            'PF10_0255' => 'PF10_0254',
            'PF14_0687' => 'PF14_0686',
          }
          plasmo = manual_mappings[plasmo] if manual_mappings[plasmo]

          code = CodingRegion.ff(plasmo)
          if code.nil?
            $stderr.puts "Couldn't find #{plasmo} from #{row.inspect}"
            skipping = true
            next
          end

          sp_percent = row[1]
          mero_percent = row[2]
          troph_percent = row[3]
          game_percent = row[4]

          plasmodb_line_next = false
        else
          # a row containing info on 1 peptide

          my_sp = row[1] and row[1].strip.length > 0
          my_mero = row[2] and row[2].strip.length > 0
          my_troph = row[3] and row[3].strip.length > 0
          my_game = row[4] and row[4].strip.length > 0

          sp_count += 1 if my_sp
          mero_count += 1 if my_mero
          troph_count += 1 if my_troph
          game_count += 1 if my_game

          # record the peptide that they have apparently found
          unless plasmodb_line_next
            matches = row[0].match(/^(.+) (\+\d)/)
            raise Exception, row[0] if matches.nil? or matches.length != 3
            peptides.push matches[1]
            charges.push matches[2]

            my_stages = []
            my_stages.push sp.id if my_sp
            my_stages.push mero.id if my_mero
            my_stages.push troph.id if my_troph
            my_stages.push game.id if my_game
            stages.push my_stages
          end
        end
      end
    end
  end
  
  def maurers_cleft_proteome_to_database
    pub = Publication.find_or_create_by_pubmed_id(
      ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_PUBMED_ID)
    experiment = ProteomicExperiment.find_or_create_by_name_and_publication_id(
      ProteomicExperiment::FALCIPARUM_MAURERS_CLEFT_2005_NAME, pub.id)

    FasterCSV.foreach("#{DATA_DIR}/falciparum/proteomics/MaurersCleft2005/table2.csv",
      :col_sep => "\t"
    ) do |row|
      next if row.no_nils.length == 1
      raise unless row.length == 8

      plasmo = row[0].gsub(/[^01-9a-zA-Z\.\_]/,'')
      plasmo = 'PF10_0323' if plasmo == 'PF10_0323b' #annotation has changed

      code = CodingRegion.ff(plasmo)
      if code.nil?
        $stderr.puts "Couldn't find '#{plasmo.inspect}'"
        next
      end

      ProteomicExperimentResult.find_or_create_by_coding_region_id_and_proteomic_experiment_id(
        code.id, experiment.id
      ) or raise
    end
  end

  def sumoylation2008_proteome_to_database
    pub = Publication.find_or_create_by_pubmed_id(
      ProteomicExperiment::FALCIPARUM_SUMOYLATION_2008_PUBMED_ID)
    experiment = ProteomicExperiment.find_or_create_by_name_and_publication_id(
      ProteomicExperiment::FALCIPARUM_SUMOYLATION_2008_NAME, pub.id)

    FasterCSV.foreach(
      "#{DATA_DIR}/falciparum/proteomics/Sumoylation2008/table1_modified.csv"
    ) do |row|
      plasmo = row[0].gsub('*','')
      code = CodingRegion.ff(plasmo)
      if code.nil?
        $stderr.puts "Couldn't find '#{plasmo.inspect}'"
        next
      end
      ProteomicExperimentResult.find_or_create_by_coding_region_id_and_proteomic_experiment_id(
        code.id, experiment.id
      ) or raise
    end
  end
end
