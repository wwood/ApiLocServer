class ProteomicExperimentPeptide < ActiveRecord::Base
  belongs_to :coding_region
  belongs_to :proteomic_experiment

  def regex
    r = peptide

    if matches = r.match(/^\-\.(.+)\.\-$/) #way unlikely coz it's a real short protein
      r = "^(#{matches[1]})$"
    elsif matches = r.match(/^\-\.(.+)\.(.)$/)
      r = "^(#{matches[1]})#{matches[2]}"
    elsif matches = r.match(/^(.)\.(.+)\.\-$/)
      r = "#{matches[1]}(#{matches[2]})$"
    elsif matches = r.match(/^(.)\.(.+)\.(.)$/)
      r = "#{matches[1]}(#{matches[2]})#{matches[3]}"
    else
      raise Exception, "Don't know how to make a regex out of #{peptide}"
    end

    raise Exception, "Unexpected peptide format, so I'm not going to convert it into a regex, sorry: #{peptide}, for debug ended up with #{r}" if r.match(/\./) or r.match(/\-/)
    
    /#{r}/i
  end
end
