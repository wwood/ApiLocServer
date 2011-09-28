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
    assert_equal spd, SpeciesData.new('P. yoelii').fasta_file_species_name #check for not exactly the last name but close enough
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
    assert_equal "/home/ben/phd/data/Toxoplasma gondii/genome/ToxoDB/#{SpeciesData::SOURCE_VERSIONS['ToxoDB']}/TgondiiME49Gene_ToxoDB-#{SpeciesData::SOURCE_VERSIONS['ToxoDB']}.txt.gz",
    spd.gene_information_gzfile_path
  end
  
  def test_gzfile_path_default
    spd = SpeciesData.new('falciparum')
    assert_equal "/home/ben/phd/data/Plasmodium falciparum/genome/PlasmoDB/#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}/PfalciparumGene_PlasmoDB-#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}.txt.gz",
    spd.gene_information_gzfile_path
  end
  
  def test_gzfile_filename_default
    spd = SpeciesData.new('falciparum')
    assert_equal "PfalciparumGene_PlasmoDB-#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}.txt.gz",
    spd.gene_information_gzfile_filename
  end
  
  def test_directories_for_mkdir
    spd = SpeciesData.new('gondii')
    assert_equal [
      '/home/ben/phd/data',
      '/home/ben/phd/data/Toxoplasma gondii',
      '/home/ben/phd/data/Toxoplasma gondii/genome',
      '/home/ben/phd/data/Toxoplasma gondii/genome/ToxoDB',
      "/home/ben/phd/data/Toxoplasma gondii/genome/ToxoDB/#{SpeciesData::SOURCE_VERSIONS['ToxoDB']}"
    ],
    spd.directories_for_mkdir
  end
  
  def test_one_word_name
    assert_equal 'NeosporaCaninum', SpeciesData.new('Neospora caninum').one_word_name
    spd = SpeciesData.new('Plasmodium falciparum')
    assert_equal 'Pfalciparum', spd.one_word_name
  end
  
  def test_genomic_filename
    spd = SpeciesData.new('falciparum')
    assert_equal "PfalciparumGenomic_PlasmoDB-#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}.fasta",
    spd.genomic_fasta_filename
  end
  
  def test_transcripts_name_without_block
    spd = SpeciesData.new('Babesia bovis')
    assert_equal "BbovisT2BoAnnotatedTranscripts_PiroplasmaDB-#{SpeciesData::SOURCE_VERSIONS['PiroplasmaDB']}.fasta",
    spd.transcript_fasta_filename
  end
  
  def test_behind_usage_policy
    spd =  SpeciesData.new('Plasmodium chabaudi')
    assert_equal "http://plasmodb.org/common/downloads/release-#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}/Pchabaudi/fasta/data",
    spd.eu_path_db_fasta_download_directory
 end
 
 def test_behind_usage_policy
    spd =  SpeciesData.new('Plasmodium vivax')
    assert_equal "http://plasmodb.org/common/downloads/release-#{SpeciesData::SOURCE_VERSIONS['PlasmoDB']}/Pvivax/fasta",
    spd.eu_path_db_fasta_download_directory
 end
end
