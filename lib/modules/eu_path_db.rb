# Methods associated mainly with uploading data from PlasmoDB and ToxoDB etc.

require 'eu_path_d_b_gene_information_table'
require 'zlib'

class BScript
  # Use the gene table to upload the GO terms to the database
  def upload_gondii_gene_table_to_database
    oracle = EuPathDBGeneInformationTable.new(
      Zlib::GzipReader.open(
        "#{DATA_DIR}/Toxoplasma gondii/ToxoDB/5.2/TgondiiME49Gene_ToxoDB-5.2.txt.gz"
      ))

    oracle.each do |info|
      # find the gene
      gene_id = info.get_info('ID')
      code = CodingRegion.s(Species::TOXOPLASMA_GONDII_NAME).find_by_string_id(gene_id)
      unless code
        $stderr.puts "Couldn't find coding region #{gene_id}, skipping"
        next
      end

      associates = info.get_table('GO Terms')
      associates.each do |a|
        go_id = a['GO ID']
        go = GoTerm.find_by_go_identifier_or_alternate(go_id)
        unless go
          $stderr.puts "Couldn't find go term: #{go_id}, skipping"
          next
        end

        CodingRegionGoTerm.find_or_create_by_coding_region_id_and_go_term_id_and_evidence_code(
          code.id,
          go.id,
          a['Evidence Code']
        )
      end
    end
  end
end
