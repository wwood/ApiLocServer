#!/usr/bin/ruby 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

puts "Hello World"

require 'bio'
str = "SEQ1\tEMBL\t\atg\t103\t105\t.\t+\t0\tname \"fgenesh2_pg.scaffold_1000001\"; transcriptId 63195\nSEQ1\tEMBL\t\exon\t103\t172\t.\t+\t0\n"
p Bio::GFF.new(str).records[1].strand
f = File.open('testFiles/test.gff', 'r')
l = f.gets
p l

p Bio::GFF.new(l).records[0].strand
