# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

class SimpleGo
  def initialize(obo_file)
    @go_file = File.open(obo_file, "r")
  end
  
  
  # Return the next GoEntry in the file,
  # or nil if none exists
  def next_go
    while (line = @go_file.gets)
      if !line
        return nil
      end
      
      if line.match('^\[Term\]')
        goid_line = @go_file.gets
        name_line = @go_file.gets
        namespace_line = @go_file.gets
        
        entry = GoEntry.new
        
        if (m = goid_line.match(/id: (GO\:\d+)/))
          entry.go_id = m[1]
        else
          raise Exception, "Badly formatted id line for parsing: '#{id_line}'"
        end
        
        name = nil
        if (m = name_line.match('name: ([^\n]+)'))
          entry.name = m[1]
        else
          raise Exception, "Badly formatted name line for parsing: '#{name_line}'"
        end
                
        namespace = nil
        if (m = namespace_line.match('namespace: ([^\n]+)'))
          entry.namespace = m[1]
        else
          raise Exception, "Badly formatted namespace line for parsing: '#{namespace_line}'"
        end
        
        #Parse alternates from the following lines
        alternate_line = @go_file.gets
        alternates = []
        while (m = alternate_line.match('alt_id: (GO\:\d+)\n'))
            alternates.push m[1]
            alternate_line = @go_file.gets
        end
        entry.alternates = alternates
        
        return entry
      end
    end
  end
end

# Something like ('GO:0000001','mitochondrion inheritance','biological_process')
class GoEntry
  attr_accessor :go_id, :name, :namespace, :alternates
  
  def initialize()
  end
end


class GoMapParser
  def initialize(map_file)
    @map_file = File.open(map_file, "r")
  end
  
  def next_relation
    line = @map_file.gets
    
    # Return if end of file, or that pesky last line
    if !line or line.match('part_of \=\> part_of \/\/ part_of')
      return nil
    end
    
    s1 = line.split ' => '
    if s1.length != 2
      raise Exception, "Badly handled map file line: #{line}"
    end
    e = GoMapEntryObj.new
    e.child_id = s1[0]
    
    s2 = s1[1].split ' // '
    if s2.length != 2
      raise Exception, "Badly handled map file line error type 2: #{line}"
    end
    
    if s2[0] != ''
      parents = s2[0].split ' '
      e.best_parent_id = parents
      if s2[1]
        e.all_parent_ids = s2[1].split ' '
      end
    end
    
    return e
  end
end


# Can't just call it GoMapEntry because then it clashes with the gnr rails
# model of the same name
class GoMapEntryObj
  attr_accessor :child_id, :best_parent_id, :all_parent_ids
end
