# Converts a JGI GO file into a real gene ontology file


require 'jgi_go'

# Convert each line of the jgi GO file into a gene association line
go = JgiGoFile.new('/home/uyen/phd/data/jgi/Brafl1/Brafl1.goinfo.tab')
    
while go.has_next
  print 
end


