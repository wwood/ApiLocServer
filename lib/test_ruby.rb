#!/usr/bin/env ruby -w

require 'csv'

   
    #Ben - info is in file like below, the cols in bold are the ones I'm using, do I need to remove the "" )
    #836    3    "viable"    "CG5819"    1    0    10    0    10    "Not Lethal"    0    0    0    0    0    0    0    0    0    0    0    0    "No"

    FasterCSV.foreach("/home/maria/data/Essentiality/Drosophila/nature07936-s3.csv_test", :headers => true, :col_sep => "\t") do |row|

      puts row[3]
     
    end
