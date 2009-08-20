class ProteomicExperimentPeptide < ActiveRecord::Base
  belongs_to :coding_region
  belongs_to :proteomic_experiment

  def regex
    r = peptide.gsub('.','')
    if matches = r.match(/(.*)\-$/)
      r = "#{matches[1]}$"
    end
    
    if matches = r.match(/^\-(.*)/)
      r = "^#{matches[1]}"
    end
    
    /#{r}/i
  end
end
