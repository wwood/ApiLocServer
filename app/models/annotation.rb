class Annotation < ActiveRecord::Base
  belongs_to :coding_region
  
  # Convenience method for simple creation
  def self.create_with_gene_id(coding_region_string_id, annotation)
    code = CodingRegion.find_by_name_or_alternate(coding_region_string_id)
    if !code
      $stderr.puts "No coding region #{coding_region_string_id}"
      return nil
    end
      
    return Annotation.find_or_create_by_coding_region_id_and_annotation(
      code.id,
      annotation
    )
  end
end
