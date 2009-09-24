require 'reach'

# A class representing alternate string IDs taken from the literature
class LiteratureDefinedCodingRegionAlternateStringId < CodingRegionAlternateStringId

  NONSPECIFIC_COMMON_NAMES = %w(ARP H103 SPP)

  # Find strangeness in the literature uploaded names. 
  # 2 genes shouldn't have the same name, basically
  def check_for_inconsistency(species_name)
    # For each coding region in the species, for each of the common names
    # used, find another with that name
    CodingRegion.s(species_name).all.each do |code|
      code.literature_defined_coding_region_alternate_string_ids.each do |bait|
        CodingRegionAlternateStringId.find_all_by_name(bait.name,
          :joins => {:coding_region => {:gene => {:scaffold => :species}}},
          :conditions => [
            'species.name = ? and coding_region_alternate_string_ids.coding_region_id <> ?',
            species_name,
            bait.coding_region_id
          ]
        ).each do |prey|
          $stderr.puts "Found a conflict with #{bait.name}: #{bait.coding_region.string_id} #{prey.coding_region.string_id}"
        end
      end
    end
  end
end
