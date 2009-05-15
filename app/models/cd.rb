class Cd < ActiveRecord::Base
  belongs_to :coding_region

  named_scope :first, {:conditions => [:order => 1]}

  def length
    stop-start+1
  end

  # Give the number of coding regions that have each number of exons
  def self.exon_summary(coding_region_string_id_list)
    exon_counts = []
    coding_region_string_id_list.each do |string_id|
      num = CodingRegion.f(string_id).cds.count
      exon_counts[num] ||= 0
      exon_counts[num] += 1
    end

    exon_total = 0
    protein_count = 0
    exon_counts.each_with_index do |count, number|
      next if number == 0
      real_count = count.nil? ? 0 : count
      protein_count += real_count
      exon_total += real_count * number
      puts "#{number} exons: #{real_count}\t#{((real_count.to_f/coding_region_string_id_list.length.to_f)*10000.0).round.to_f/100.0} %"
    end
    puts "Average: #{exon_total.to_f/protein_count.to_f}"
  end
end
