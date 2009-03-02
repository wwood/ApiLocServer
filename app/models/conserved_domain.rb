class ConservedDomain < ActiveRecord::Base
  belongs_to :coding_region

  def upload_from_eupathdb(filename, species_common_name)
    FasterCSV.foreach(filename, :col_sep => "\t") do |row|
      code = CodingRegion.find_by_name_or_alternate_and_organism(row[0], species_common_name)
      type = row[1].capitalize

      if row[3] and row[3].length > 0
        ConservedDomain.find_or_create_by_coding_region_id_and_type_and_identifier_and_start_and_stop_and_score_and_name(
          code.id,
          type,
          row[2],
          row[4],
          row[5],
          row[6],
          row[3]
        )
      else
        ConservedDomain.find_or_create_by_coding_region_id_and_type_and_identifier_and_start_and_stop_and_score(
          code.id,
          type,
          row[2],
          row[4],
          row[5],
          row[6]
        )
      end
    end
  end
end
