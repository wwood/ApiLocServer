# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

module Bio
  class Pats
    class Report
      attr_accessor :predictions
      
      def parse(pats_output)
        cur_protein = nil
        pats_output.split("\n").each do |line|
          if matches = line.match(/^>(.+)/)
            cur_protein = matches[1]
          elsif matches = line.match(/^apicoplast candidate: (\d.\d+) \-\-> (.+)/) #apicoplast candidate: 0.813 --> YES
            r = Result.new
            r.score = matches[1].to_f
            if matches[2]=='YES' 
              r.prediction = true 
            else
              r.prediction = false
            end
            if @predictions.nil?
              @predictions = {}
            end
            @predictions[cur_protein] = r
          end
        end
      end
    end
    
    class Result
      # score between 0 and 1
      attr_accessor :score
      # binary true/false prediction output by PATS
      attr_accessor :prediction
    end
  end
end
