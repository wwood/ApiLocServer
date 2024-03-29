require 'rarff'
require 'b_script'

# A class to export data from the database to a format of choice. Originally
# taken out of Script because it was getting big and unweildy and in need
# of some object orientation with the checking of headings
class SpreadsheetGenerator
  require 'microarray_timepoint' #include the constants for less typing
  include MicroarrayTimepointNames
  
  def prepare
    s = BScript.new
    OrthomclGene.new.link_orthomcl_and_coding_regions(['pfa'])
    s.seven_species_orthomcl_upload
    s.upload_snp_data_jeffares
    s.upload_neafsey_2008_snp_data
    s.upload_mu_et_al_snps
    s.upload_jiang_chromosomal_features
    s.derisi_microarray_to_database2
  end

  # Generate the full ARFF for all known localisations in P. falciparum. This
  # is a 10 class problem or something.
  def arff
    data = generate_spreadsheet(
      PlasmodbGeneList.find_by_description(
        PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME
      ).coding_regions
    ) do |code|

      yield code if block_given?

      @headings.push 'Localisation' if @first
      @current_row.push code.tops[0].name.gsub(' ','_')  # Top level localisations
      check_headings
    end

    rarff_relation = Rarff::Relation.new('PfalciparumLocalisation')
    rarff_relation.instances = data
    @headings.each_with_index do |heading, index|
      rarff_relation.attributes[index].name = "\"#{heading}\""
    end

    # Make some attributes noiminal instead of String
    rarff_relation.set_string_attributes_to_nominal

    puts rarff_relation.to_arff
  end

  def arff_falciparum
    data = generate_spreadsheet(
      CodingRegion.falciparum_nuclear_encoded.all(
        :joins => :amino_acid_sequence,
        :conditions => 'sequences.sequence is not null',
        :include => [
          :wolf_psort_predictions,
          {:orthomcl_genes => [:orthomcl_groups, :orthomcl_run]}
        ]
#        :limit => 20
      )
    ) do |code|
      @headings.push 'Localisation' if @first
      @current_row.push nil
      check_headings
    end

    rarff_relation = Rarff::Relation.new('PfalciparumLocalisationPredictions')
    rarff_relation.instances = data
    @headings.each_with_index do |heading, index|
      rarff_relation.attributes[index].name = "\"#{heading}\""
    end

    # Make some attributes noiminal instead of String
    rarff_relation.set_string_attributes_to_nominal((0..(data[0].length)).reject{|a| a==@identifier_column_index})

    puts rarff_relation.to_arff
  end

  def arff_eight_class
    puts arff_eight_class_plumbing.to_arff
  end

  def arff_eight_class_csv
    puts arff_eight_class_plumbing.to_csv
  end

  def arff_eight_class_plumbing
    eight_classes = [
      'exported',
      'mitochondrion',
      'apicoplast',
      'cytoplasm',
      'nucleus',
      'endoplasmic reticulum',
#      'merozoite surface',
      #      'inner membrane complex',
      'apical'
    ]
    
    #    codes = PlasmodbGeneList.find_by_description(
    #      PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME
    #    ).coding_regions.select do |code|
    codes = CodingRegion.falciparum.all(
      :joins => [
        :expressed_localisations,
        :amino_acid_sequence
      ],
      :select => 'distinct(coding_regions.*)'
    ).select do |code|
      code.apilocalisations.length == 1 and eight_classes.include?(code.apilocalisations[0].name)
    end
    #    codes = [codes[0],codes[1]]

    data = generate_spreadsheet(codes) do |code|
      @headings.push 'Localisation' if @first
      @current_row.push code.apilocalisations[0].name.gsub(' ','_')  # Top level localisations
      check_headings
    end

    rarff_relation = Rarff::Relation.new('PfalciparumLocalisation')
    rarff_relation.instances = data
    @headings.each_with_index do |heading, index|
      rarff_relation.attributes[index].name = "\"#{heading}\""
    end

    # Make some attributes noiminal instead of String
    rarff_relation.set_string_attributes_to_nominal((0..(data[0].length)).reject{|a| a==@identifier_column_index})

    rarff_relation
  end

  # Write out an ARFF file for each of the top level localisations
  def each_localisation_arff
    MalariaLocalisationTopLevelLocalisation.all.reach.top_level_localisation.uniq.each do |top|
      positives = CodingRegion.top(top.name).all.uniq
      negatives = CodingRegion.topped.all.uniq

      # if it is in both positive and negative set, it is positive
      negatives.reject! do |neg|
        positives.include?(neg)
      end

      name = top.name.gsub(' ','_').camelize
      puts "Writing #{name}, found #{positives.length} positive and #{negatives.length} negatives."

      File.open("#{BScript::PHD_DIR}/weka/each/#{name}.arff", 'w') do |f|
        data = generate_spreadsheet([positives, negatives].flatten) do |code|
          @headings.push 'Localisation' if @first
          #          p code
          #          p code.tops.include?(top)
          if code.tops.include?(top)
            @current_row.push name
          else
            @current_row.push 'negative'
          end
        end

        rarff_relation = Rarff::Relation.new("Pfalciparum#{name}")
        rarff_relation.instances = data
        @headings.each_with_index do |heading, index|
          rarff_relation.attributes[index].name = "\"#{heading}\""
        end

        # Make some attributes noiminal instead of String
        rarff_relation.set_string_attributes_to_nominal

        f.puts rarff_relation.to_arff
      end
    end
  end

  def generate_spreadsheet(coding_regions)
    # headings
    @headings = []

    all_data = []
    @first = true
    #String attributes aren't useful in arff files, because many classifiers and visualisations don't handle them
    # So make a list of outputs so they can be made nominal in the end.
#    amino_acids = Bio::AminoAcid.names.keys.select{|code| code.length == 1}
#    derisi_timepoints = Microarray.find_by_description(
#      Microarray.derisi_2006_3D7_default
#    ).microarray_timepoints.all(
#      :select => 'distinct(name)').select do |timepoint|
#      %w(22 23 47 49).include?(timepoint.name.gsub(/^Timepoint /,''))
#    end
    
    # For all genes that only have 1 localisation and that are non-redundant
    coding_regions.each do |code|
      @finished = false
      @current_row = []

      if @first
        @headings.push 'PlasmoDB ID'
        @identifier_column_index = @headings.length - 1
      end
      @current_row.push "'#{code.string_id}'"
      check_headings
      
      #      results.push code.amino_acid_sequence.sequence,
      
      
#      #      SignalP
#      @headings.push 'SignalP Prediction' if @first
#      @current_row.push(code.signal?)
#      check_headings

      # PlasmoAP
      @headings.push 'PlasmoAP Score' if @first
      @current_row.push code.amino_acid_sequence.plasmo_a_p.points
      check_headings
#
#      # ExportPred
#      @headings.push 'ExportPred?' if @first
#      @current_row.push code.export_pred_however.predicted?
#      check_headings
#
#      #WoLF_PSORT
#      @headings.push ['WoLF_PSORT prediction Plant',
#        'WoLF_PSORT prediction Animal',
#        'WoLF_PSORT prediction Fungi'] if @first
#      ['plant','animal','fungi'].each do |organism|
#        c = code.wolf_psort_localisation!(organism)
#        @current_row.push c
#      end
#      check_headings
#
#      @headings.push 'Plasmit' if @first
#      @current_row.push code.plasmit?  # Top level localisations
#      check_headings
#
#      # official orthomcl
#      @headings.push [
#        #        'Number of P. falciparum Genes in Official Orthomcl Group',
#        #        'Number of P. vivax Genes in Official Orthomcl Group',
#        #        'Number of C. parvum Genes in Official Orthomcl Group',
#        'Number of C. homonis Genes in Official Orthomcl Group',
#        #        'Number of T. parva Genes in Official Orthomcl Group',
#        #        'Number of T. annulata Genes in Official Orthomcl Group',
#        #        'Number of T. gondii Genes in Official Orthomcl Group',
#        #        'Number of Tetrahymena thermophila Genes in Official Orthomcl Group',
#        #        'Number of Arabidopsis Genes in Official Orthomcl Group',
#        #        'Number of Yeast Genes in Official Orthomcl Group',
#        #        'Number of Mouse Genes in Official Orthomcl Group'
#      ] if @first
#      interestings = [
#        #        'pfa',
#        #        'pvi',
#        #        'cpa',
#        'chom',
#        #        'the',
#        #        'tan',
#        #        'tgo',
#        #        'tth',
#        #        'ath',
#        #        'sce',
#        #        'mmu'
#      ]
#
#      ogene = code.single_orthomcl!
#      if ogene.nil?
#        1..interestings.length.times do
#          @current_row.push nil
#        end
#      else
#        group = ogene.official_group
#        interestings.each do |three|
#          @current_row.push group.orthomcl_genes.code(three).length
#        end
#      end
#      check_headings
      
      #      # 7species orthomcl
      #      @headings.push [      'Number of P. falciparum Genes in 7species Orthomcl Group', #7species orthomcl
      #        'Number of P. vivax Genes in 7species Orthomcl Group',
      #        'Number of Babesia Genes in 7species Orthomcl Group'] if @first
      #      seven_name_hash = {}
      #      begin
      #        if !fivepfour.include?(code.string_id) #Used 5.2 for 7species too, so ignore new genes
      #          og = code.single_orthomcl(OrthomclRun.seven_species_filtering_name)
      #          raise Exception, "7species falciparum not found for #{code.inspect}" if !og
      #          og.orthomcl_group.orthomcl_genes.all.each do |gene|
      #            begin
      #              species_name = gene.single_code.gene.scaffold.species.name
      #              if seven_name_hash[species_name]
      #                seven_name_hash[species_name] += 1
      #              else
      #                seven_name_hash[species_name] = 1
      #              end
      #            rescue OrthomclGene::UnexpectedCodingRegionCount => e
      #              # ignore vivax because of current linking errors
      #              raise e unless gene.orthomcl_name.match(/^Plasmodium_vivax_/)
      #            end
      #          end
      #        end
      #      rescue CodingRegion::UnexpectedOrthomclGeneCount => e
      #        # This happens for singlet genes
      #      rescue OrthomclGene::UnexpectedCodingRegionCount => e
      #        raise e
      #      end
      #      [Species.falciparum_name,
      #        Species.vivax_name,
      #        Species.babesia_bovis_name].each do |name|
      #        @current_row.push seven_name_hash[name] ? seven_name_hash[name] : 0
      #      end
      #      check_headings
      #
      #      @headings.push [
      #        'Number of Synonymous IT SNPs according to Jeffares et al',
      #        'Number of Non-Synonymous IT SNPs according to Jeffares et al',
      #        'Number of Synonymous Clinical SNPs according to Jeffares et al',
      #        'Number of Non-Synonymous Clinical SNPs according to Jeffares et al',
      #        'dNdS for Reichenowi SNPs according to Jeffares et al',
      #        'Number of Synonymous Reichenowi SNPs according to Jeffares et al',
      #        'Number of Non-Synonymous Reichenowi SNPs according to Jeffares et al',
      #        'Number of Synonymous SNPs according to Neafsey et al',
      #        'Number of Non-Synonymous SNPs according to Neafsey et al',
      #        'Number of Intronic SNPs according to Neafsey et al',
      #        'Number of Synonymous SNPs according to Mu et al',
      #        'Number of Non-Synonymous SNPs according to Mu et al',
      #        'Number of Non-coding SNPs according to Mu et al',
      #        'Number of Surveyed by to Mu et al',
      #        'SNP Theta by to Mu et al',
      #        'SNP Pi by to Mu et al'] if @first
      #      [:it_synonymous_snp,
      #        :it_non_synonymous_snp,
      #        :pf_clin_synonymous_snp,
      #        :pf_clin_non_synonymous_snp,
      #        :reichenowi_dnds,
      #        :reichenowi_synonymous_snp,
      #        :reichenowi_non_synonymous_snp,
      #        :neafsey_synonymous_snp,
      #        :neafsey_non_synonymous_snp,
      #        :neafsey_intronic_snp,
      #        :mu_synonymous_snp,
      #        :mu_non_synonymous_snp,
      #        :mu_non_coding_snp,
      #        :mu_bp_surveyed,
      #        :mu_theta,
      #        :mu_pi,
      #      ].each do |method|
      #        if s = code.send(method)
      #          @current_row.push s.value
      #        else
      #          @current_row.push nil
      #        end
      #      end
      #      check_headings
      #
      #
      #      # Segmasker
      #      @headings.push 'Percentage of Amino Acid Sequence Low Complexity according to NCBI Segmasker' if @first
      #      @current_row.push code.segmasker_low_complexity_percentage_however
      #      check_headings
      #
      #      # Number of Acidic and basic Residues in the protein
      #      @headings.push 'Number of Acidic Residues' if @first
      #      @headings.push 'Number of Basic Residues' if @first
      #      b = code.amino_acid_sequence.to_bioruby_sequence
      #      @current_row.push b.acidic_count
      #      @current_row.push b.basic_count
      #      check_headings
      #
      #      # Length of protein
      #      @headings.push 'Length of Protein' if @first
      #      @current_row.push code.amino_acid_sequence.sequence.length
      #      check_headings
      
#      @headings.push 'Chromosome' if @first
#      name = code.chromosome_name
#      @current_row.push name
#      check_headings
      #
      #      @headings.push 'Distance from chromosome end' if @first
      #      @current_row.push code.length_from_chromosome_end
      #      check_headings
      #
      #      @headings.push 'Percentage from chromosome end' if @first
      #      @current_row.push code.length_from_chromosome_end_percent
      #      check_headings
      #
      #      @headings.push 'Number of Exons' if @first
      #      @current_row.push code.cds.count
      #      check_headings
      #
      #      @headings.push 'Offset of 2nd Exon' if @first
      #      @current_row.push code.second_exon_splice_offset
      #      check_headings
      #
      #      @headings.push 'Orientation' if @first
      #      # pretty stupid really
      #      @current_row.push code.positive_orientation? ? '+' : '-'
      #      check_headings
      #
      #      # predicted = code.send(predictor)
      #      #          if predicted.transmembrane_type_1? or predicted.transmembrane_type_2?
      #      @headings.push 'Number of transmembrane domains' if @first
      #      @headings.push 'Type 1 transmembrane domain?' if @first
      #      # pretty stupid really
      #      tmhmm = code.tmhmm
      #      @current_row.push [
      #        tmhmm.transmembrane_domains.length,
      #        tmhmm.transmembrane_type_1?
      #      ]
      #      check_headings
      #
      #      @headings.push 'Random number as noise cutoff' if @first
      #      # pretty stupid really
      #      @current_row.push rand
      #      check_headings
      #
#      # Microarray DeRisi
#      if @first
#        @headings.push derisi_timepoints.collect{|t|
#          'DeRisi 2006 3D7 '+t.name
#        }
#      end
#      derisi_timepoints.each do |timepoint|
#        measures = MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(
#          code.id,
#          timepoint.id
#        )
#        if !measures.nil?
#          @current_row.push measures.measurement
#        else
#          @current_row.push nil
#        end
#      end
#      check_headings
      #
      #      # Amino Acid Composition
      #      if @first
      #        amino_acids.each do |one|
      #          @headings.push "Number of AA: #{one}"
      #        end
      #      end
      #      composition = code.amino_acid_sequence.to_bioruby_sequence.composition
      #      amino_acids.each do |one|
      #        @current_row.push(composition[one].nil? ? 0 : composition[one])
      #      end
      #      check_headings
      #
      #      # Normalised AA Composition
      #      if @first
      #        amino_acids.each do |one|
      #          @headings.push "Normalised number of AA: #{one}"
      #        end
      #      end
      #      amino_acids.each do |one|
      #        @current_row.push(composition[one].nil? ? 0.0 : composition[one].to_f/code.amino_acid_sequence.sequence.length.to_f)
      #      end
      #      check_headings
      #
            # Winzeler Timepoints
            @headings.push WINZELER_TIMEPOINTS if @first
            WINZELER_TIMEPOINTS.each do |timepoint|
              t = code.microarray_measurements.timepoint_name(timepoint).first
              @current_row.push t ? t.measurement : nil
            end
            check_headings
      
            # Winzeler Timepoints percentiles
            if @first
              WINZELER_TIMEPOINTS.each do |name|
                name += ' percentile'
                @headings.push name
              end
            end
            WINZELER_TIMEPOINTS.each do |timepoint|
              t = code.microarray_measurements.timepoint_name(timepoint).first
              @current_row.push t ? t.percentile : nil
            end
            check_headings
      #
      #      #      #             gMARS and other headings
      #      #      code.gmars_vector(3).each do |node|
      #      #        # Push the headings on the fly - easier this way
      #      #        @headings.push node.name if @first
      #      #        @current_row.push node.normalised_value
      #      #        check_headings
      #      #      end
      #
      #      @headings.push Scaffold::JIANG_SFP_COUNT_STRAINS.collect{|s| "Jiang et al #{s} 10kb SFP Count"} if @first
      #      @current_row.push code.jiangs
      #      check_headings
      #
      #      @headings.push Scaffold::JIANG_SFP_COUNT_STRAINS.collect{|s| "log of Jiang et al #{s} 10kb SFP Count"} if @first
      #      @current_row.push code.jiangs.collect{|j| j == 0.0 ? -1 : Math.log(j)}
      #      check_headings
      #
      #      @headings.push 'AT content' if @first
      #      @current_row.push code.at_content
      #      check_headings
      #
      #      @headings.push 'Nucleotide Tandem Repeats: Number of tandem repeats' if @first
      #      @headings.push 'Nucleotide Tandem Repeats: Nucleotides covered length' if @first
      #      repeats = code.transcript_sequence.tandem_repeats
      #      @current_row.push repeats.length
      #      @current_row.push repeats.length_covered
      #      check_headings
      #
      #      #      @headings.push 'Number of repeats (by radar)' if @first
      #      #      @current_row.push code.amino_acid_sequence.radar_repeats.length
      #      #      check_headings
      #
      #      if @first
      #        LocalisationMedianMicroarrayMeasurement::LOCALISATIONS.each do |loc|
      #          @headings.push "Pearson Distance from Median Localisation #{loc}"
      #        end
      #      end
      #      @current_row.push LocalisationMedianMicroarrayMeasurement.pearson_distance_from_localisation_medians(code)
      #      check_headings
      #
      #      if @first
      #        LocalisationMedianMicroarrayMeasurement::LOCALISATIONS.each do |loc|
      #          @headings.push "Euclidean Distance from Median Localisation #{loc}"
      #        end
      #      end
      #      @current_row.push LocalisationMedianMicroarrayMeasurement.euclidean_distance_from_localisation_medians(code)
      #      check_headings
      #
      #      @headings.push [
      #        'LaCount Interaction Partner Localisation',
      #        'Wuchty Interaction Partner Localisation'
      #      ] if @first
      #      [Network::LACOUNT_2005_NAME, Network::WUCHTY_2009_NAME].each do |network_name|
      #        interlocs = code.interaction_partners(network_name).collect do |c|
      #          tops = c.tops
      #          if c.tops.length == 1
      #            tops[0].name
      #          else
      #            nil
      #          end
      #        end
      #        interlocs.reject!{|i| i.nil?}
      #        iis = interlocs.uniq
      #        if iis.length > 1
      #          $stderr.puts "In network #{network_name}, #{code.string_id}: #{interlocs.join(', ')}"
      #        end
      #
      #        if interlocs.empty?
      #          @current_row.push nil
      #        else
      #          hash = {}
      #          interlocs.each do |loc|
      #            hash[loc] ||= 0
      #            hash[loc] += 1
      #          end
      #          winning_count = 0
      #          winning_loc = 'bug'
      #          hash.each do |loc,count|
      #            if count > winning_count
      #              winning_count = count
      #              winning_loc = loc
      #            end
      #          end
      #          $stderr.puts winning_loc
      #          @current_row.push winning_loc.gsub(' ','_')
      #        end
      #      end
      #      check_headings

      # Run any additional code as per caller's block
      yield code if block_given?
      check_headings
      
      all_data.push(@current_row.flatten)
      
      #      break unless @first
      @first = false if @first
      @finished = true
      check_headings
    end
    return all_data
  end

  def ciliate_investigation
    arff do |code|
      @headings.push "PlasmoDB" if @first
      @current_row.push code.string_id
      #      @headings.push "Annotation" if @first
      #      @current_row.push code.annotation.annotation
      check_headings
    end
  end
  
  private
  def check_headings
    if @first
      @headings.flatten!
      @current_row.flatten!
      unless @current_row.length == @headings.length
        raise Exception, "Bad number of entries in the row for code #{@current_row[0].inspect}: headings #{@headings.length} results #{@current_row.length}"
      end
      @expected_row_entries = @current_row.length
    elsif @finished
      @current_row.flatten!
      unless @current_row.length == @expected_row_entries
        raise Exception, "Bad number of entries in the row for code #{@current_row[0].inspect}: headings #{@headings.length} results #{@current_row.length}"
      end
    end
  end
end
