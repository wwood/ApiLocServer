#!/usr/bin/env ruby
#Script to analyze and plot wormnet data

require 'rubygems'
require 'fastercsv'
require 'array_pair'

#sort wormnet results into bins based on wormnet score, set range for data bins (0,10,20..320)
bins1= []
bins2= []
bin_size = 10

# read in wormnet results file
FasterCSV.foreach(ARGV[0], :headers => true, :col_sep => "\t") do |splits|
  # check the line has the correct number of columns
  unless [8,10].include?(splits.length)
    raise Exception, "badly parsed line: #{splits.inspect}"
  end

  #names of the cols that will be used
  gene_id = splits[0] #not used?
  score = splits[5].to_f.round #round off wormnet core scores to zero decimal places
  lethal =  splits[1]
  mamortho = splits[8]

  # split data into bins, bins will be e.g. scores = 0, 1-10, 11-20
  # scores of exactly 0 are kept in a separate bin, and scores of
  # exactly 10 are in the second bin, not the third. That same rule
  # applies to 10, 20, 30, ..
  bin_number = nil
  if score == 0
    bin_number = 0
  elsif (score % 10) == 0 #score is a multiple of 10

    bin_number = (score/bin_size).to_i
  else #score is >0 and not a multiple of 10

    bin_number = (score/bin_size).to_i+1
  end

  bins1[bin_number] ||= [] #if that bin is a new bin (ie. bins[bin_number]==nil), then initialize as an empty array
  if lethal == 'true'
    bins1[bin_number].push 1
  else
    bins1[bin_number].push 0
  end

  #make bins for genes without mammalian orthologues

  bins2[bin_number] ||= [] #if that bin is a new bin (ie. bins[bin_number]==nil), then initialize as an empty array
  if mamortho == 'false'
    if lethal == 'true'
      bins2[bin_number].push 1
    else
      bins2[bin_number].push 0
    end
  end
end

# Then, after reading the whole file, analyze each of the bins

#headings
puts [
  "Score_range",
  "No. genes",
  "Lethal_Gene",
  "Lethal(%)",
  "Nomam_No._genes",
  "Nomam_Lethal_Gene",
  "Nomam_Lethal(%)"
].join("\t")


bins1.each_with_index do |bin1, index|
  bin_range = nil
  if index == 0
    bin_range =  0
  else
    bin_range = "#{((index-1)*bin_size)+1}-#{index*bin_size}"
  end

  #calculate no of genes per bin
  if bin1.nil?
    numgen = 0; wscore = 0
  else
    numgen = bin1.length
    wscore = (bin1.average*100).round
  end

  #calculate for genes without mammalian orthologues
  nomamnumgen = nil
  nomamscore = nil
  bin2 = bins2[index]
  bin_range = nil
  if index == 0
    bin_range =  0
  else
    bin_range = "#{((index-1)*bin_size)+1}-#{index*bin_size}"
  end

  if bin2.nil? or bin2.empty?
    nomamnumgen = 0; nomamscore = 0
  else
    nomamnumgen = bin2.length
    nomamscore = (bin2.average*100).round
  end

  puts [
    bin_range,
    numgen,
    (bin1.nil? ? 0 : bin1.total),
    wscore,
    nomamnumgen,
    (bin2.nil? ? 0 : bin2.total),
    nomamscore
  ].join("\t")
end