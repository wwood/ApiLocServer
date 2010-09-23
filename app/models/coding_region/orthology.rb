class CodingRegion < ActiveRecord::Base
  # return an array of apicomplexan orthologues of this coding region - the
  # ones that have been localised according to apiloc. Returns nil if it doesn't
  # find an orthomcl linkage
  def localised_apicomplexan_orthomcl_orthologues(options={})
    options = {
    :by_literature => false
    }.merge(options)
    begin
      group = single_orthomcl.official_group
      if group.nil?
        return nil
      else
        single_orthomcl.orthomcl_groups.first.orthomcl_genes.apicomplexan.collect{ |oge|
          if oge.coding_regions.length > 0
            oge.single_code
          else
            nil
          end
        }.no_nils.select do |code|
          if options[:by_literature]
            code.second_class_citizen_expression_contexts.count > 0
          else
            code.expressed_localisations.count > 0
          end
        end
      end
    rescue UnexpectedOrthomclGeneCount => e
      return nil
    end
  end
end