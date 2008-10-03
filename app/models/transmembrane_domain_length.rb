require 'pdb_tm'

# A measurement representing a single transmembrane domain length
class TransmembraneDomainLength < TransmembraneDomainMeasurement
  
  # Upload the lengths, given that all the the pdb entries are already coding regions,
  # BEWARE: this is not a find_or_create method - it has to be done all at once
  def upload_pdb_tm
    Bio::PdbTm::Xml.new(File.open("#{Script::DATA_DIR}/transmembrane/pdbtm/20080923/pdbtmalpha.xml")).entries.each do |e|
      code = CodingRegion.fs(e.pdb_id, Species.pdb_tm_dummy_name) or raise Exception, "Coding region not found"
      e.transmembrane_domains.each do |tmd|
        TransmembraneDomainLength.create!(
          :measurement => tmd.length,
          :coding_region_id => code.id
        )
      end
    end
  end
end
