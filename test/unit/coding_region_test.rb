require File.dirname(__FILE__) + '/../test_helper'

class CodingRegionTest < ActiveSupport::TestCase
  def test_get_first_base_scaffold_wise
    #nadda
    assert_equal nil, CodingRegion.find(1).calculate_upstream_region
    
    # positive strand
    assert_equal 40, CodingRegion.find(2).calculate_upstream_region
    
    # negative strand
    assert_equal 40, CodingRegion.find(3).calculate_upstream_region
    
    # different scaffold
    assert_nil CodingRegion.find(4).calculate_upstream_region
    
  end
  
  def test_upstream_coding_region
    # test none
    assert_nil CodingRegion.find(1).upstream_coding_region
    
    # test forward
    assert_equal 2, CodingRegion.find(3).upstream_coding_region.id
    
    # test backward
    assert_equal 3, CodingRegion.find(2).upstream_coding_region.id
  end
  
  #  def test_upstream_coding_region_same_orientation
  #    # test none
  #    assert_nil CodingRegion.find(1).upstream_coding_region
  #
  #    # test forward
  #    assert_equal 1, CodingRegion.find(3).upstream_coding_region
  #
  #    # test backward
  #    assert_equal 5, CodingRegion.find(2).upstream_coding_region
  #  end
  
  def test_get_by_normal_or_alternate
    #normal
    c = CodingRegion.find_by_name_or_alternate 'PF1.1'
    assert c
    assert_kind_of CodingRegion, c
    assert_equal 6, c.id
    
    #alternate
    c = CodingRegion.find_by_name_or_alternate 'blah'
    assert c
    assert_kind_of CodingRegion, c
    assert_equal 6, c.id
    
    #nil
    c = CodingRegion.find_by_name_or_alternate 'blahno'
    assert_nil c
  end
  
  def test_get_by_normal_or_alternate_with_species
    # test easy - 1 gene with 1 name
    code = CodingRegion.find_by_name_or_alternate_and_organism('PF1', 'Plasmodium falciparum')
    assert code
    assert_equal 5, code.id
    
    # test no results
    code = CodingRegion.find_by_name_or_alternate_and_organism('PF1', 'sponge')
    assert_nil code
    
    # test hard to coding regions with same name but different species
    code = CodingRegion.find_by_name_or_alternate_and_organism('PF01', 'Plasmodium falciparum')
    assert code
    assert_equal 7, code.id
    code = CodingRegion.find_by_name_or_alternate_and_organism('PF01', 'sponge')
    assert code
    assert_equal 8, code.id
    
    #wierd chars in name
    assert CodingRegion.find_by_name_or_alternate_and_organism("PF01'", 'Plasmodium falciparum')
    
    
    # could test mroe here with alternates, but meh
    
  end
  
  def test_single_orthomcl
    # test good
    o = CodingRegion.find(2).single_orthomcl
    assert_kind_of OrthomclGene, o
    assert_equal 2, o.id
    
    # test fail with no orthomcl gene
    assert_raise CodingRegion::UnexpectedOrthomclGeneCount do
      CodingRegion.find(7).single_orthomcl
    end
    
    # test fail with multiple orthomcl genes
    assert_raise CodingRegion::UnexpectedOrthomclGeneCount do
      CodingRegion.find(1).single_orthomcl
    end
    
    # test fail when single one is non-official
    assert_raise CodingRegion::UnexpectedOrthomclGeneCount do
      CodingRegion.find(3).single_orthomcl
    end
  end
  
  def test_wormnet_core_total_linkage_scores
    # test normal, that includes non wormnet and wormnet non core decoys
    assert_equal((1.7+0.405465108108), CodingRegion.find(4).wormnet_core_total_linkage_scores)
    
    # test nothing
    assert_equal 0.0, CodingRegion.find(3).wormnet_core_total_linkage_scores
  end
  
  def test_is_enzyme?
    assert CodingRegion.find(2).is_enzyme?
    assert_equal false, CodingRegion.find(1).is_enzyme?
    
    # test no annotations
    code = CodingRegion.create!(:string_id => 'dummya', :gene_id => CodingRegion.find(1).gene_id)
    
    # test 1 annotation that is non-existant
    assert_equal false, code.is_enzyme?(true)
    go = GoTerm.create!(:term => 'you wish', :go_identifier => 'goid_nadda', :aspect => GoTerm::ASPECTS[0])
    CodingRegionGoTerm.create(:coding_region_id => code.id, :go_term_id => go.id, :evidence_code => 'IEA')
    assert_equal false, code.is_enzyme?(true)
    assert_raise RException do
      code.is_enzyme?(false)
    end
  end
  
  def test_is_gpcr?
    # plain gpcr
    assert CodingRegion.find(3).is_gpcr?
    
    # gpcr offspring
    assert CodingRegion.find(4).is_gpcr?
    
    # false
    assert_equal false, CodingRegion.find(2).is_gpcr?
    
    
    # test no annotations
    code = CodingRegion.create!(:string_id => 'dummya', :gene_id => CodingRegion.find(1).gene_id)
    
    # test 1 annotation that is non-existant
    assert_equal false, code.is_gpcr?(true)
    go = GoTerm.create!(:term => 'you wish', :go_identifier => 'goid_nadda', :aspect => GoTerm::ASPECTS[0])
    CodingRegionGoTerm.create(:coding_region_id => code.id, :go_term_id => go.id, :evidence_code => 'IEA')
    assert_equal false, code.is_gpcr?(true)
    assert_raise RException do
      code.is_gpcr?(false)
    end
  end
  
  def test_go_term?
    # plain gpcr
    assert CodingRegion.find(3).go_term?(GoTerm::GPCR_GO_TERM)
    
    # gpcr offspring
    assert CodingRegion.find(4).go_term?(GoTerm::GPCR_GO_TERM)
    
    # false
    assert_equal false, CodingRegion.find(2).go_term?(GoTerm::GPCR_GO_TERM)
  end
  
  def test_enzyme_then_gpcr_bug
    assert CodingRegion.find(3).is_gpcr?
    assert_equal false, CodingRegion.find(3).is_enzyme?
  end
  
  def test_golgi_consensi
    n = GolgiNTerminalSignal.create!(:signal => '^A')
    c = GolgiCTerminalSignal.create!(:signal => 'BB$')
    
    code = CodingRegion.first
    code.amino_acid_sequence = AminoAcidSequence.create(
        :coding_region_id => code.id,
        :sequence => 'AGGGGGGGDBB'
    )
    assert_equal [n, c], code.golgi_consensi
  end
  
  def test_signalp
    @seq_with_signal = "MKKIITLKNLFLIILVYIFSEKKDLRCNVIKGNNIK"
    @seq_without_signal = "MRRRRRRRRRRRRRRRRRRRRRRRRR" #ie lotsa charge
    code = nil
    
    assert_differences([AminoAcidSequence, SignalPCache, CodingRegion], nil, [1,1,1]) do
      code = CodingRegion.create!(:string_id => 'whatever12131')
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
                                                                        code.id,
                                                                        @seq_with_signal
      )
      code.save!
      sp = code.signalp_however
      
      assert sp
      assert sp.signal?
    end
    
    assert_differences([AminoAcidSequence, SignalPCache, CodingRegion], nil, [0,0,0]) do
      code = CodingRegion.find_by_string_id('whatever12131')
      sp = code.signalp_however
      assert sp.signal?
    end
    
    assert_differences([AminoAcidSequence, SignalPCache, CodingRegion], nil, [1,1,1]) do
      code = CodingRegion.create!(:string_id => 'whatever121311321')
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
                                                                        code.id,
                                                                        @seq_without_signal
      )
      code.save!
      sp = code.signalp_however
      
      assert sp
      assert_equal false, sp.signal?
    end
  end
  
  def test_export_pred
    code = nil
    assert_differences([AminoAcidSequence, ExportPredCache, CodingRegion], nil, [1,1,1]) do
      code = CodingRegion.create!(:string_id => 'whatever12fd1311321')
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
                                                                        code.id,
          'MAVSTYNNTRRNGLRYVLKRRTILSVFAVICMLSLNLSIFENNNNNYGFHCNKRHFKSLAEASPEEHNNLRSHSTSDPKKNEEKSLSDEINKCDMKKYTAEEINEMINSSNEFINRNDMNIIFSYVHESEREKFKKVEENIFKFIQSIVETYKIPDEYKMRKFKFAHFEMQGYALKQEKFLLEYAFLSLNGKLCERKKFKEVLEYVKREWIEFRKSMFDVWKEKLASEFREHGEMLNQKRKLKQHELDRRAQREKMLEEHSRGIFAKGYLGEVESETIKKKTEHHENVNEDNVEKPKLQQHKVQ'
      )
      sp = code.export_pred_however
      
      assert sp
      assert sp.predicted?
    end
    
    assert_differences([AminoAcidSequence, ExportPredCache, CodingRegion], nil, [0,0,0]) do
      code.export_pred_cache(:reload => true) #how come this doesn't reload by itself?
      sp = code.export_pred_however
      
      assert sp
      assert sp.predicted?
    end
    
    # not predicted sequence
    assert_differences([AminoAcidSequence, ExportPredCache, CodingRegion], nil, [1,1,1]) do
      code = CodingRegion.create!(:string_id => 'whatever12fd13fdsa11321')
      AminoAcidSequence.find_or_create_by_coding_region_id_and_sequence(
                                                                        code.id,
          'MDVQDFLNCNKLKISKEKISNLNKSKIGILITNLGSPEKLTYWSLYKYLSEFLTDPRVVKLNRFLWLPILYTFVLPFRSGKVLSKYKSIWIKDGSPLCVNTHNQ'
      )
      sp = code.export_pred_however
      
      assert sp
      assert_equal false, sp.predicted?
    end
    
    assert_differences([AminoAcidSequence, ExportPredCache, CodingRegion], nil, [0,0,0]) do
      code.export_pred_cache(:reload => true) #how come this doesn't reload by itself?
      sp = code.export_pred_however
      
      assert sp
      assert_equal false, sp.predicted?
      assert_equal nil, sp.score #annoyingly exportpred doesn't seem to give negative scores - this is a bug in the code
    end
  end
  
  def test_wolf_psort_predictions
    # cached one is for testing, but is actually wrong, so deleting all of them yields a
    # different result
    assert_equal 'nucl', CodingRegion.find(1).wolf_psort_localisation('plant')
    
    WolfPsortPrediction.destroy_all
    assert_equal 'cyto', CodingRegion.find(1).wolf_psort_localisation('plant')
  end
  
  def test_segmasker
    # try cached
    num = SegmaskerLowComplexityPercentage.count
    assert_equal 0.75, CodingRegion.find(1).segmasker_low_complexity_percentage_however
    assert_equal num, SegmaskerLowComplexityPercentage.count
    
    # try uncached
    CodingRegion.find(1).segmasker_low_complexity_percentage.destroy
    num = SegmaskerLowComplexityPercentage.count
    # $ segmasker
    #>da
    #TSPFIIIINIIDIFHHSYLLYFIFSFNFITIIFFYYYVEKSIFIFIFIIKYTFSYHIIIF
    #>da
    #4 - 12
    #20 - 36
    #41 - 48
    assert_equal(
     (12+36+48-4-20-41+3).to_f/60.to_f,
    CodingRegion.find(1).segmasker_low_complexity_percentage_however
    )
    assert_equal num+1, SegmaskerLowComplexityPercentage.count
    #    p CodingRegion.find(1).segmasker_low_complexity_percentage_however.class
    #    p ((12+36+48-4-20-41+3).to_f/60.to_f).class
    assert_equal(
     ((12+36+48-4-20-41+3).to_f/60.to_f).round(3),
    CodingRegion.find(1).segmasker_low_complexity_percentage_however.round(3)
    )
    assert_equal num+1, SegmaskerLowComplexityPercentage.count
  end
  
  # Also tested (orthologously) in mouse_pheno_desc_test
  def test_lethal?
    # test mouse
    assert_equal true, CodingRegion.find(10).lethal?
    assert_nil CodingRegion.find(11).lethal?
    assert_equal false, CodingRegion.find(12).lethal?
    assert_equal true, CodingRegion.find(13).lethal?
    # test one with one lethal and one trusted
    assert_equal false, CodingRegion.find(17).lethal?
    
    # test elegans
    assert_equal true, CodingRegion.find(14).lethal?
    assert_equal false, CodingRegion.find(15).lethal?
    assert_equal nil, CodingRegion.find(16).lethal?
  end
  
  def test_phenotype_information?
    # test mouse
    assert_equal true, CodingRegion.find(10).phenotype_information?
    assert_equal false, CodingRegion.find(11).phenotype_information?
    assert_equal true, CodingRegion.find(12).phenotype_information?
    assert_equal true, CodingRegion.find(13).phenotype_information?
    # test elegans
    assert_equal true, CodingRegion.find(14).phenotype_information?
    assert_equal true, CodingRegion.find(15).phenotype_information?
    assert_equal false, CodingRegion.find(16).phenotype_information?
  end
  
  def test_percent_length_from_chromosome_end_percent
    # test positive near start
    assert_equal 15, (CodingRegion.find(1).length_from_chromosome_end_percent*100).round
    
    # test positive near end of chromosome
    assert_equal 9, (CodingRegion.find(4).length_from_chromosome_end_percent*100).round
    
    # test negative (near end)
    assert_equal 8, (CodingRegion.find(2).length_from_chromosome_end_percent*100).round
  end
  
  def test_percent_length_from_chromosome_end
    # tested mainly in test_percent_length_from_chromosome_end_percent
    # test positive near start
    assert_equal 10, CodingRegion.find(1).length_from_chromosome_end
  end
  
  def test_chromosome_name
    assert_equal 'MAL3', CodingRegion.find(1).chromosome_name
    assert_nil CodingRegion.find(4).chromosome_name
  end
  
  def test_second_exon_splice_offset
    assert_equal 2, CodingRegion.find(1).second_exon_splice_offset
    assert_equal 0, CodingRegion.find(2).second_exon_splice_offset
    assert_nil CodingRegion.find(3).second_exon_splice_offset
  end
  
  def test_proteomics_profile
    assert_equal [
    [0]*3,
    [1]*3,
    [0]*40,
    [1]*14
    ].flatten,
    CodingRegion.find(1).proteomics_profile
    
    # test no aaseq
    assert_nil CodingRegion.new.proteomics_profile
    
    # test aaseq but no hits
    c = CodingRegion.new
    c.amino_acid_sequence = AminoAcidSequence.new(:sequence => 'ABC')
    assert_equal [0,0,0], c.proteomics_profile
  end
  
  def test_name
    code = CodingRegion.find(1)
    assert_equal nil, code.name
    code.string_id = '123'; assert_equal 'Pf123', code.name
    code.string_id = '-123'; assert_equal 'Pf-123', code.name
    code.string_id = 's-123'; assert_equal 'Pfs-123', code.name
    code.string_id = 'sf'; assert_equal 'sf', code.name
    
    code.string_id = CodingRegion::UNANNOTATED_CODING_REGIONS_DUMMY_GENE_NAME
    assert_equal 'No assigned gene identifier', code.name
    
    
    # One without a sensible binomial name doesn't bother with the prefix
    code = CodingRegion.find(4)
    assert_equal code.string_id, code.name
  end
  
  def test_find_all_by_partial_name_or_alternate_maybe_with_species_prefix
    # test just the id
    assert_equal [5,6,20,21].collect{|n| 
      CodingRegion.find(n)
    }, 
    CodingRegion.find_all_by_partial_name_or_alternate_maybe_with_species_prefix('PF1').sort{|a,b| a.id <=> b.id}
    # test the annotation
    assert_equal [1,3].collect{|n| 
      CodingRegion.find(n)
    }, 
    CodingRegion.find_all_by_partial_name_or_alternate_maybe_with_species_prefix('massive').sort{|a,b| a.id <=> b.id}
  end
end
