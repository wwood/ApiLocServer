#!/usr/bin/env ruby 
#Script to analyze and plot wormnet data


#sort wormnet results into bins based on wormnet score, set range for data bins (0,10,20..320)
bins= []
range = 0..32
range.each do |bin|
a= bin*10
bins.push a 
end

# read in wormnet results file
$stdin.each do |line|

#skip header
 if first
        first = false
        next
      end	

# split the line up on tab characters into an array
  splits = line.strip.split("\t")


# check the line has the correct number of columns
  if splits.length != 10
    raise Exception, "badly parsed line: #{line}"
  end


  
#names of the cols that will be used
gene_id = splits[0]
score = splits[5].round #round off wormnet core scores to zero decimal places
lethal =  splits[1]



# split data into bins, bins will be e.g. scores = 0, 1-10, 11-20
if score == 0
bin1.push line 

#if wormnet score is between zero and 10
 
if score > 0 & score <= bins[1] + 1
bin2.push line

#is there a simple/better way to repeat above to bin data upto last bin(320)?



#then after reading in whole file, make an array of arrays of the bins in order to compare the bins?

allbins = bin1, bin2, bin3, # add all bins? 

# count no. of genes per bin
allbins.each do |b| 
total = b.length

#count no. of lethal genes
count = 0
if lethal == "true"
count += 1

#calculate probability of lethality for bin
prob = count/total

end



#print out summary table for bins: values for bins i.e 0..320, probability of lethality (prob) and then plot


