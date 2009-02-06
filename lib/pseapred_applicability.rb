#!/usr/bin/env ruby

# An early version of applicability
#
# Usage: pseapred_applicability.rb training.fasta target.fasta

require 'distance_matrix'

require 'hash_goodies'

require 'rubygems'
require 'bio'
require 'peach'

# read in the fasta file of the training data
trainings = Bio::FlatFile.open(ARGV[0]).to_a

# read in the fasta file of the target data
targets = Bio::FlatFile.open(ARGV[0]).to_a

# compare each of the targets to each of the trainings
# using the BLOSUM62 DistanceMatrix as an example
matrix = DistanceMatrix.blosum62
amino_acids = %w(A R N D C Q E G H I L K M F P S T W Y V B J Z X *)
target_scores = []

#targets.peach(4) do |target|
targets.each do |target|
  score = 0
  target_composition = target.seq.composition.normalize
  trainings.each do |training|
    training_composition = training.seq.composition.normalize
    
    amino_acids.each do |aa1|
      target_percent = training_composition[aa1]
      amino_acids.each do |aa2|
        train_percent = target_composition[aa2]
      
        if target_percent.nil? or
            train_percent.nil?
          next #zeroes are useless
        else
          s = target_percent*train_percent*matrix.get(aa1,aa2)
          #puts " #{aa1} #{target_percent} #{aa2} #{train_percent} #{matrix.get(aa1,aa2)} #{s}"
          score += s
        end
      
      end
      
    end
  end
  target_scores.push(score)
  puts score
end

puts "Average: #{target_scores.average}"
puts target_scores.join(' ')
    
