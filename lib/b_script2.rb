require 'jgi_genes'
require 'simple_go'
require 'rio'
require 'api_db_genes'
require 'yeast_genome_genes'
require 'signalp'
require 'api_db_fasta'
require 'gff3_genes'
require 'tm_hmm_wrapper'
require 'rubygems'
require 'csv'
require 'bio'
require 'peach'

#require 'mscript'
require 'reach'
require 'plasmo_a_p'
require 'top_db_xml'
require 'pdb_tm'
#require 'go'
require 'wormbase_go_file'
require 'libsvm_array'
require 'bl2seq_report_shuffling'
require 'rarff'
require 'stdlib'
require 'babesia'
require 'spoctopus_wrapper'
require 'b_script'

class BScript2
  def printtandem(roll)
    raise if roll.empty?
    puts
    puts "#{roll[0].string_id} #{roll[0].annotation.annotation}"
    roll[1..(roll.length-1)].each do |hit|
      puts "#{hit[0].string_id} #{hit[0].annotation.annotation} #{hit[1]}"
    end
  end

  # Taking in order all the genes in P. falciparum, is there interesting clusters?
  def tandem_orthologue_search
    Species.find_by_name(Species::FALCIPARUM_NAME).scaffolds.each do |scaf|
      #start with the most downstream gene
      code = scaf.downstreamest_coding_region
      puts
      puts
      puts scaf.name

      roll = []

      while code != nil #never actually reach this condition
        next_code = code.next_coding_region
        break if next_code.nil?

        unless code.aaseq.nil? or next_code.aaseq.nil?
          hits = code.amino_acid_sequence.blastp(
            next_code.amino_acid_sequence,
            '1e-5'
          ).hits

          if hits.length > 0 and hits[0].evalue < 0.00001
            if roll.empty?
              roll.push code
            end
            roll.push [next_code, hits[0].evalue]
          else
            unless roll.empty?
              printtandem(roll)
              roll = []
            end
          end
        end

        code = next_code
      end
      printtandem(roll) unless roll.empty?
    end
  end
end
