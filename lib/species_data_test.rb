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
    assert_equal "/home/ben/phd/data/Plasmodium yoelii/genome/PlasmoDB/#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}/PyoeliiAnnotatedProteins_PlasmoDB-#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}.fasta",
      spd.protein_fasta_path
  end

  def test_one_word_name
    spd = SpeciesData.new('Plasmodium chabaudi')
    assert_equal 'Pchabaudi', spd.one_word_name
  end

  def test_download_directory
    spd = SpeciesData.new('Plasmodium chabaudi')
    assert_equal "http://plasmodb.org/common/downloads/release-#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}/Pchabaudi", spd.eu_path_db_download_directory
  end

  def test_transcript_path_default
    spd = SpeciesData.new('Plasmodium chabaudi')
    assert_equal "/home/ben/phd/data/Plasmodium chabaudi/genome/PlasmoDB/#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}/PchabaudiAnnotatedTranscripts_PlasmoDB-#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}.fasta",
      spd.transcript_fasta_path
  end

  def test_transcript_fasta_filename
    spd = SpeciesData.new('falciparum')
    assert_equal "Pfalciparum_PlasmoDB-#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}.gff",
      spd.gff_filename
  end

  def test_gzfile_path_toxo
    spd = SpeciesData.new('gondii')
    assert_equal '/home/ben/phd/data/Toxoplasma gondii/genome/ToxoDB/5.2/TgondiiME49Gene_ToxoDB-5.2.txt.gz',
      spd.gene_information_gzfile_path
  end
end
