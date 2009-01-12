# Extra methods to the usual bioruby Bl2Seq
# so that I can determine the first hits from each
# so I can line up the hits somewhat automatically.

module Bio
  class Blast
    class Bl2seq
      class Report
        def most_upstream_query_hit
          iterations[0].hits[0].hsps.min{|a,b| 
            a.query_from <=> 
              b.query_from
          }
        end
        
        def query_overhang
          hsp = most_upstream_query_hit
          hsp.query_from - hsp.hit_from
        end
        
        def best_evalue
          iterations.reach.hits.evalue.flatten.min{|a,b|
            if a.nil? and b.nil?
              0
            elsif a.nil?
              -1
            elsif b.nil?
              1
            else
              a <=> b
            end
          }
        end
        
        # Return true if there is some disagreement about where the
        # start of the hit is.
        def shuffled_start?
          iterations.last.hits.select{|h|h.shuffled_start?}.length > 0
        end
        
        
        class Hit
          # Return true if there is some disagreement about where the
          # start of the hit is.
          def shuffled_start?
            max_index_query = 0
            max_index_hit = 0
            hsps.each_with_index do |hsp, i|
              next if i==0#first wins by default
              if hsp.query_from < hsps[max_index_query].query_from
                max_index_query = i
              end
              if hsp.hit_from < hsps[max_index_hit].hit_from
                max_index_hit = i
              end
            end
            return max_index_query != max_index_hit
          end
        end
      end

      
      class BabesiaCandidateWrapper
        attr_accessor :bl2seq_result, :query_fasta, :hit_fasta
  
        def initialize(bl2seq_result, query_fasta, hit_fasta)
          @bl2seq_result = bl2seq_result
          @query_fasta = query_fasta
          @hit_fasta = hit_fasta
        end
  
        def query_def
          @bl2seq_result.query_def
        end
  
        def hit_def
          @bl2seq_result.hits[0].definition
        end
  
        def nterminal_query_start
          @bl2seq_result.most_upstream_query_hit.query_from
        end
  
        def nterminal_hit_start
          @bl2seq_result.most_upstream_query_hit.hit_from
        end
  
        def difference
          nterminal_query_start - nterminal_hit_start
        end
      end
    end
  end
end
