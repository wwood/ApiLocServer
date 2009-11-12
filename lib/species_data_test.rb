# To change this template, choose Tools | Templates
# and open the template in the editor.

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'species_data'

class SpeciesDataTest < Test::Unit::TestCase
  def test_method_missing
    spd = SpeciesData.new('Plasmodium yoelii')
    assert_equal 'yoelii', spd.directory
  end

  def test_nickname
    spd = SpeciesData.new('Plasmodium yoelii').fasta_file_species_name
    assert_equal spd, SpeciesData.new('yoelii').fasta_file_species_name
  end

  def test_protein_data_path
    spd = SpeciesData.new('Plasmodium yoelii')
    assert_equal '/home/ben/phd/data/Plasmodium yoelii/genome/PlasmoDB/6.1/PyoeliiAnnotatedProteins_PlasmoDB-6.1.fasta',
      spd.protein_fasta_path
  end
end
