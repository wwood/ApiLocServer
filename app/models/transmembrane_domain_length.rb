require 'pdb_tm'

# A measurement representing a single transmembrane domain length
class TransmembraneDomainLength < TransmembraneDomainMeasurement
  def upload_pdb_tm
    Bio::PdbTm::Xml.new(File.open("#{Script::DATA_DIR}/transmembrane/pdbtm/20080923/pdbtmalpha.xml")).entries.each do |e|
      code = CodingRegion.fs(e.pdb_id, Species.pdb_tm_dummy_name) or raise Exception, "Coding region not found"
      e.transmembrane_domains.each do |tmd|
        TransmembraneDomainLength.find_or_create_by_measurement_and_coding_region_id(
          tmd.length,
          code.id
        )
      end
    end
  end
end
