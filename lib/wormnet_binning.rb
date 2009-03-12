#!/usr/bin/env ruby 
#Script to analyze and plot wormnet data

require 'rubygems'
require 'fastercsv'
require 'array_pair'

#sort wormnet results into bins based on wormnet score, set range for data bins (0,10,20..320)
bins= []

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

  # split data into bins, bins will be e.g. scores = 0, 1-10, 11-20
  bin_number = (score/10).to_i
  bins[bin_number] ||= [] #if that bin is a new bin (ie. bins[bin_number]==nil), then initialize as an empty array
  if lethal == 'true'
    bins[bin_number].push 1
  else
    bins[bin_number].push 0
  end
end
  
# Then, after reading the whole file, analyze each of the bins
bins.each_with_index do |bin, index|
  puts [
    "#{index*10}-#{(index+1)*10}",
    (bin.average*100).round
  ].join("\t")
end
