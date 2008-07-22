require 'rubygems'
gem 'bio'
gem 'rio'
require 'bio'
require 'rio'

# Runs memstat over multiple sequences in a fasta file
Bio::FlatFile.auto(ARGV[0]) do |ff|
  count = 1
  
  ff.each do |e| 
    # print the fasta to a tmp file
    name = "memsat#{count}"
    rio(name) < e.to_s
    count += 1
      
    # run memstat
    system "runmemsat '#{name}'"
  end
end