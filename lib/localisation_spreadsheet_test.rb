$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'rubygems'
require 'test/unit'
require 'localisation_spreadsheet'
require 'test_helpers'

class LocalisationSpreadsheetTest < Test::Unit::TestCase
  def test_foo
    
  end
end


class LocalisationSpreadsheetRowTest < Test::Unit::TestCase
  def test_simple
    input = 'PfGAP45	PFL1090w	16321976	IMC during extracellular merozoite	taken directly from 16321976	Light, EM	polyclonal antibody directly against protein	This showed that both PfGAP proteins are present in erythrocyte stage parasites, localizing to a ring of fluorescence around the developing merozoites within schizonts or around free merozoites (Fig. 1C). This pattern is consistent with localization to the IMC that lines the length of the merozoite under the plasma membrane	3D7'
    r = LocalisationSpreadsheetRow.new.create_from_array('Plasmodium falciparum', input.split("\t"))
    assert_equal ['GAP45'], r.common_names
    assert_equal 'PFL1090w', r.gene_id
    assert_equal '16321976', r.pubmed_id
    assert_equal 'IMC during extracellular merozoite', r.localisation_and_timing
    assert_equal 'taken directly from 16321976', r.mapping_comments
    assert_equal %w(Light EM), r.microscopy_types
    assert_equal 'polyclonal antibody directly against protein', r.localisation_method
    assert_equal 'This showed that both PfGAP proteins are present in erythrocyte stage parasites, localizing to a ring of fluorescence around the developing merozoites within schizonts or around free merozoites (Fig. 1C). This pattern is consistent with localization to the IMC that lines the length of the merozoite under the plasma membrane',
      r.quote
    assert_equal %w(3D7), r.strains
  end

  def test_comments
    #this was supposed to be simple
      input = 'PfGAP45	PFL1090w	16321976	IMC during extracellular merozoite	taken directly from 16321976	Light, EM	polyclonal antibody directly against protein	This showed that both PfGAP proteins are present in erythrocyte stage parasites, localizing to a ring of fluorescence around the developing merozoites within schizonts or around free merozoites (Fig. 1C). This pattern is consistent with localization to the IMC that lines the length of the merozoite under the plasma membrane	3D7	comment 1	comment 2'
      r = LocalisationSpreadsheetRow.new.create_from_array('Plasmodium falciparum', input.split("\t"))
      assert_equal %w(3D7), r.strains
      assert_equal ['comment 1','comment 2'], r.comments
      input = 'PfGAP45	PFL1090w	16321976	IMC during extracellular merozoite	taken directly from 16321976	Light, EM	polyclonal antibody directly against protein	This showed that both PfGAP proteins are present in erythrocyte stage parasites, localizing to a ring of fluorescence around the developing merozoites within schizonts or around free merozoites (Fig. 1C). This pattern is consistent with localization to the IMC that lines the length of the merozoite under the plasma membrane	3D7	comment 1	'
      r = LocalisationSpreadsheetRow.new.create_from_array('Plasmodium falciparum', input.split("\t"))
      assert_equal %w(3D7), r.strains
      assert_equal ['comment 1'], r.comments
  end

  def test_no_gene_id
    input = 'PfSSP2, TRAP		1409621	microneme during sporozoite		EM	polyclonal antibody directly to protein	Murine antibodies against recombinant PfSSP2 identify a 90-kDa protein in extracts of P. falciparum sporozoites, recognize sporozoites and infected hepatocytes by immunofluorescence, localize PfSSP2 to the sporozoite micronemes by immunoelectron microscopy and to the surface membrane by live immunofluorescence, and inhibit sporozoite invasion and development in hepatocytes in vitro.	NF54, 3D7'
    r = LocalisationSpreadsheetRow.new.create_from_array('Plasmodium falciparum', input.split("\t"))
    assert_equal %w(SSP2 TRAP), r.common_names
    assert_equal %w(NF54 3D7), r.strains
  end

  def test_no_strain_info
    input = 'PfSSP2, TRAP		1409621	microneme during sporozoite		EM	polyclonal antibody directly to protein	quote.	3D7'
    r = LocalisationSpreadsheetRow.new.create_from_array('Plasmodium falciparum', input.split("\t"))
    assert_equal %w(SSP2 TRAP), r.common_names
    assert_equal %w(3D7), r.strains
  end

  def test_warn_about_strain_info
    # test is missing but recorded OK
    input = 'TRAP		7664729	cytoplasm during salivary gland sporozoite, weak cytoplasm during hemoceol sporozoite		Light, EM	Monoclonal antibody directly to protein	quotering.		strain information not found'
    err = capture_stderr do
      r = LocalisationSpreadsheetRow.new.create_from_array('Plasmodium falciparum', input.split("\t"))
      assert_equal ['strain information not found'], r.comments
    end
    assert_equal "", err

    # test missing and not recorded OK
    input = 'TRAP		7664729	cytoplasm during salivary gland sporozoite, weak cytoplasm during hemoceol sporozoite		Light, EM	Monoclonal antibody directly to protein	quotering.		'
    err = capture_stderr do
      r = LocalisationSpreadsheetRow.new.create_from_array('Plasmodium falciparum', input.split("\t"))
    end
    expected = "Strain info missing for [\"TRAP\", \"\", \"7664729\", \"cytoplasm during salivary gland sporozoite, weak cytoplasm during hemoceol sporozoite\", \"\", \"Light, EM\", \"Monoclonal antibody directly to protein\", \"quotering.\"]. Comments []\n"
    assert_equal expected, err
  end
end
