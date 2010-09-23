class ExportPredCache < ActiveRecord::Base
  belongs_to :coding_region
  set_table_name 'export_preds'
  
  # create from a Bio::ExportPred::Result, given a coding region id
  # to boot.
  def self.create_from_result(coding_region_id, result)
    attrs = {:coding_region_id => coding_region_id}
    Bio::ExportPred::Result.all_result_names.each do |name|
      attrs[name] = result.send(name)
    end
    ExportPredCache.create!(attrs)
  end
  
  # Convert to a normal result object so methods can be
  # deferred there
  def to_exportpred_result
    res = Bio::ExportPred::Result.new
    Bio::ExportPred::Result.all_result_names.each do |name|
      res.send("#{name}=", self.send(name))
    end
    return res
  end
  
  def predicted?
    to_exportpred_result.predicted?
  end
  alias_method :signal?, :predicted?
end
