$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'rubygems'
require 'test/unit'
require 'second_class_localisation_spreadsheet'
require 'test_helpers'

class LocalisationSpreadsheetTest < Test::Unit::TestCase
  def test_foo
    
  end
end


class SecondClassLocalisationSpreadsheetRowTest < Test::Unit::TestCase
  def test_simple
    input = [
    'P. falciparum',
    'S9',
    'PFL1090w',
    'random',
    'apicoplast',
    ]
    r = SecondClassLocalisationSpreadsheetRow.new.create_from_array(nil, input)
    assert_equal 'Plasmodium falciparum', r.species_name
    assert_equal ['s9'], r.common_names
    assert_equal 'PFL1090w', r.gene_id
    assert_equal 'random', r.pubmed_id
    assert_equal 'apicoplast', r.localisation_and_timing
    assert_equal nil, r.mapping_comments
  end
end
