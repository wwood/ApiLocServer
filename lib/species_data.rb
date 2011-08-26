require 'reubypathdb'

# Add modifications to EuPathDBSpeciesData to make it suitable for my use
class SpeciesData < EuPathDBSpeciesData
  SOURCE_VERSIONS = {
    'PlasmoDB' => '7.2',#
    'ToxoDB' => '6.4',#'7.0',#
    'CryptoDB' => '4.4',#'4.5',#
    'PiroplasmaDB' => '1.0',#'1.1',#
  }
  
  def initialize(nickname, base_data_directory="#{ENV['HOME']}/phd/data")
    super(nickname,base_data_directory)
  end
  
  def transcript_blast_database_path
    "/blastdb/#{transcript_fasta_filename}"
  end
end