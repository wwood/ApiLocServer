#!/usr/bin/env /home/uyen/phd/gnr/script/runner

# Takes a jgi input 'genes' gff file, and creates a list of gene/upstream
# region lengths, and puts that in the database also.
autoload(:JgiGenesGff, "jgi_genes.rb")

#class JgiToDatabase
#  
#  def run
    jgi = JgiGenesGff.new('/home/uyen/data/jgi/Brafl1/Brafl1.FilteredModels1.gff')
    iter = jgi.distance_iterator

    while iter.has_next_distance
      jgi_gene = iter.next_gene
      g = Gene.new(
        :name => jgi_gene.name,
        :species_id => 1,
        :upstream_distance => iter.next_distance
      )
      g.save!
      print '.'
    end

    puts
    puts "finished."
#  end
#end

