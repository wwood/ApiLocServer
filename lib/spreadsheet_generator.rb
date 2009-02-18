require 'rarff'

# A class to export data from the database to a format of choice. Originally
# taken out of Script because it was getting big and unweildy and in need
# of some object orientation with the checking of headings
class SpreadsheetGenerator
  require 'microarray_timepoint' #include the constants for less typing
  include MicroarrayTimepointNames
  
  def arff
    # headings
    @headings = []

    all_data = []
    @first = true
    #String attributes aren't useful in arff files, because many classifiers and visualisations don't handle them
    # So make a list of outputs so they can be made nominal in the end.
    wolf_psort_outputs = {} 
    amino_acids = Bio::AminoAcid.names.keys.select{|code| code.length == 1}
    derisi_timepoints = Microarray.find_by_description(Microarray.derisi_2006_3D7_default).microarray_timepoints(:select => 'distinct(name)')
    
    # genes that are understandably not in the orthomcl databases, because
    # they were invented in plasmodb 5.4 and weren't present in 5.2. Might be worth investigating
    # if any of them has any old names that were included, but meh for the moment.
    fivepfour = ['PFL0040c', 'PF14_0078', 'PF14_0744','PF10_0344','PFD1150c','PFD1145c','PFD0110w','PFI1780w','PFI1740c','PFI0105c','PFI0100c','MAL7P1.231']
    # Genes that have 2 orthomcl entries but only 1 plasmoDB entry
    merged_genes = ['PFD0100c']
    
    # For all genes that only have 1 localisation and that are non-redundant
    PlasmodbGeneList.find_by_description(
      PlasmodbGeneList::CONFIRMATION_APILOC_LIST_NAME
    ).coding_regions.each do |code|
      #    CodingRegion.species_name(Species.falciparum_name).all(
      #      :select => 'distinct(coding_regions.*)',
      #      :joins => {:expressed_localisations => :malaria_top_level_localisation}
      #    ).each do |code|
      next unless code.uniq_top?
      
      @headings.push 'PlasmoDB ID' if @first
      #      'Annotation',
      @current_row = [
        code.string_id,
        #        code.annotation.annotation
      ]
      check_headings
      
      @headings.push 'Top Level Localisations' if @first
      #      'Amino Acid Sequence',
      #      if code.tops[0].name == 'exported'
      #        results.push 'exported'
      #      else
      #        results.push 'not_exported'
      #      end
      @current_row.push code.tops[0].name.gsub(' ','_')  # Top level localisations
      check_headings

      #      results.push code.amino_acid_sequence.sequence,
      
      
      #      SignalP
      @headings.push 'SignalP Prediction' if @first
      @current_row.push(code.signal?)
      check_headings
      
      # PlasmoAP
      @headings.push 'PlasmoAP Score' if @first
      @current_row.push code.amino_acid_sequence.plasmo_a_p.points
      check_headings
      
      #WoLF_PSORT
      @headings.push ['WoLF_PSORT prediction Plant',
        'WoLF_PSORT prediction Animal',
        'WoLF_PSORT prediction Fungi'] if @first
      ['plant','animal','fungi'].each do |organism|
        c = code.wolf_psort_localisation(organism)
        @current_row.push c
        wolf_psort_outputs[c] ||= true
      end
      check_headings
      
      # official orthomcl
      @headings.push [
        'Number of P. falciparum Genes in Official Orthomcl Group',
        'Number of P. vivax Genes in Official Orthomcl Group',
        'Number of C. parvum Genes in Official Orthomcl Group',
        'Number of C. homonis Genes in Official Orthomcl Group',
        'Number of T. parva Genes in Official Orthomcl Group',
        'Number of T. annulata Genes in Official Orthomcl Group',
        'Number of Arabidopsis Genes in Official Orthomcl Group',
        'Number of Yeast Genes in Official Orthomcl Group',
        'Number of Mouse Genes in Official Orthomcl Group'] if @first
      interestings = ['pfa','pvi','cpa','cho','the','tan','ath','sce','mmu']
      
      # Some genes have 2 entries in orthomcl, but only 1 in plasmodb 5.4
      if merged_genes.include?(code.string_id)
        # Fill with non-empty cells
        group = code.orthomcl_genes[0].orthomcl_group
        interestings.each do |three|
          @current_row.push group.orthomcl_genes.code(three).length
        end        
      elsif !fivepfour.include?(code.string_id) and single = code.single_orthomcl 
        # Fill with non-empty cells
        group = single.orthomcl_group
        interestings.each do |three|
          @current_row.push group.orthomcl_genes.code(three).length
        end
      else
        # fill with empty cells
        1..interestings.length.times do
          @current_row.push nil 
        end
      end
      check_headings
      
      # 7species orthomcl
      @headings.push [      'Number of P. falciparum Genes in 7species Orthomcl Group', #7species orthomcl
        #      'Number of P. vivax Genes in 7species Orthomcl Group',
        'Number of Babesia Genes in 7species Orthomcl Group'] if @first
      seven_name_hash = {}
      begin
        if !fivepfour.include?(code.string_id) #Used 5.2 for 7species too, so ignore new genes
          og = code.single_orthomcl(OrthomclRun.seven_species_filtering_name)
          raise Exception, "7species falciparum not found for #{code.inspect}" if !og
          og.orthomcl_group.orthomcl_genes.all.each do |gene|
            begin
              species_name = gene.single_code.gene.scaffold.species.name
              if seven_name_hash[species_name]
                seven_name_hash[species_name] += 1
              else
                seven_name_hash[species_name] = 1
              end
            rescue OrthomclGene::UnexpectedCodingRegionCount => e
              # ignore vivax because of current linking errors
              raise e unless gene.orthomcl_name.match(/^Plasmodium_vivax_/)
            end
          end
        end
      rescue CodingRegion::UnexpectedOrthomclGeneCount => e
        # This happens for singlet genes
      rescue OrthomclGene::UnexpectedCodingRegionCount => e
        raise e unless code.species==Species::VIVAX_NAME
      end
      [Species.falciparum_name, 
        #        Species.vivax_name, 
        Species.babesia_bovis_name].each do |name|
        @current_row.push seven_name_hash[name] ? seven_name_hash[name] : 0
      end
      check_headings
      
      @headings.push [      
        'Number of Synonymous IT SNPs according to Jeffares et al',
        'Number of Non-Synonymous IT SNPs according to Jeffares et al',
        'Number of Synonymous Clinical SNPs according to Jeffares et al',
        'Number of Non-Synonymous Clinical SNPs according to Jeffares et al',
        'dNdS for Reichenowi SNPs according to Jeffares et al',
        'Number of Synonymous Reichenowi SNPs according to Jeffares et al',
        'Number of Non-Synonymous Reichenowi SNPs according to Jeffares et al',
        'Number of Synonymous SNPs according to Neafsey et al',
        'Number of Non-Synonymous SNPs according to Neafsey et al',
        'Number of Intronic SNPs according to Neafsey et al',
        'Number of Synonymous SNPs according to Mu et al',
        'Number of Non-Synonymous SNPs according to Mu et al',
        'Number of Non-coding SNPs according to Mu et al',
        'Number of Surveyed by to Mu et al',
        'SNP Theta by to Mu et al',
        'SNP Pi by to Mu et al'] if @first
      [:it_synonymous_snp, 
        :it_non_synonymous_snp, 
        :pf_clin_synonymous_snp, 
        :pf_clin_non_synonymous_snp,
        :reichenowi_dnds,
        :reichenowi_synonymous_snp,
        :reichenowi_non_synonymous_snp,
        :neafsey_synonymous_snp,
        :neafsey_non_synonymous_snp,
        :neafsey_intronic_snp,
        :mu_synonymous_snp,
        :mu_non_synonymous_snp,
        :mu_non_coding_snp,
        :mu_bp_surveyed,
        :mu_theta,
        :mu_pi,
      ].each do |method|
        if s = code.send(method)
          @current_row.push s.value
        else
          @current_row.push nil
        end
      end
      check_headings
      
      
      # Segmasker
      @headings.push 'Percentage of Amino Acid Sequence Low Complexity according to NCBI Segmasker' if @first
      @current_row.push code.segmasker_low_complexity_percentage_however
      check_headings

      # Number of Acidic and basic Residues in the protein
      @headings.push 'Number of Acidic Residues' if @first
      @headings.push 'Number of Basic Residues' if @first
      b = code.amino_acid_sequence.to_bioruby_sequence
      @current_row.push b.acidic_count
      @current_row.push b.basic_count
      check_headings
      
      # Length of protein
      @headings.push 'Length of Protein' if @first
      @current_row.push code.amino_acid_sequence.sequence.length
      check_headings
      
      
      # Microarray DeRisi
      if @first
        @headings.push derisi_timepoints.collect{|t| 
          'DeRisi 2006 3D7 '+t.name
        }
      end
      derisi_timepoints.each do |timepoint|
        measures = MicroarrayMeasurement.find_by_coding_region_id_and_microarray_timepoint_id(
          code.id,
          timepoint.id
        )
        if !measures.nil?
          @current_row.push measures.measurement
        else
          @current_row.push nil
        end
      end
      check_headings
      
      # Amino Acid Composition
      if @first
        amino_acids.each do |one|
          @headings.push "Number of AA: #{one}"
        end
      end      
      composition = code.amino_acid_sequence.to_bioruby_sequence.composition
      amino_acids.each do |one|
        @current_row.push(composition[one].nil? ? 0 : composition[one])
      end
      check_headings
      
      # Normalised AA Composition
      if @first
        amino_acids.each do |one|
          @headings.push "Normalised number of AA: #{one}"
        end
      end
      amino_acids.each do |one|
        @current_row.push(composition[one].nil? ? 0.0 : composition[one].to_f/code.amino_acid_sequence.sequence.length.to_f)
      end
      check_headings
      
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
      
      # gMARS and other headings
      #      code.gmars_vector(3).each do |node|
      #        # Push the headings on the fly - easier this way
      #        headings.push node.name if first
      #        results.push node.normalised_value
      #      end
      
      @first = false if @first
      
      # Check to make sure that all the rows have the same number of entries as a debug thing
      @headings.flatten!
      if @current_row.length != @headings.length
        
      end
      all_data.push(@current_row)
      #      break
      #      puts results.join(sep)
    end
    
    rarff_relation = Rarff::Relation.new('PfalciparumLocalisation')
    rarff_relation.instances = all_data
    @headings.each_with_index do |heading, index|
      rarff_relation.attributes[index].name = "\"#{heading}\""
    end
    
    # Make some attributes noiminal instead of String
    # Localisation
    rarff_relation.attributes[1].type = "{#{TopLevelLocalisation.all.reach.name.join(',').gsub(/[\ \(\)]/,'_')}}"
    # Wolf_PSORTs
    [4,5,6].each do |i|
      rarff_relation.attributes[i].type = "{#{wolf_psort_outputs.keys.join(',').gsub(' ','_')}}"
    end
    
    puts rarff_relation.to_arff
  end
  
  private
  def check_headings
    if @first
      @headings.flatten!
      unless @current_row.length == @headings.length
        raise Exception, "Bad number of entries in the row for code #{@current_row[0].inspect}: headings #{@headings.length} results #{@current_row.length}"
      end
    end
  end
end
