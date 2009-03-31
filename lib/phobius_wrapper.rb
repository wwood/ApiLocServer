#!/usr/bin/env ruby

require 'transmembrane'
include Transmembrane
require 'tempfile'
require 'rubygems'
gem 'rio'
require 'rio'

class PhobiusWrapper
  
  # Given an amino acid sequence, return a TransmembraneProtein
  # made up of the predicted transmembrane domains
  def calculate(sequence)
    rio(:tempdir) do |d|
      FileUtils.cd(d.to_s) do
        Tempfile.open('phobiusin') { |tempfilein|
          # Write a fasta to the tempfile
          tempfilein.puts '>wrapperSeq'
          tempfilein.puts "#{sequence}"
          tempfilein.close #required. Maybe because it doesn't flush otherwise?
      
          Tempfile.open('phobiusout') {|out|
            Tempfile.open('phobiuserr') {|err|
              result = system("phobius -short #{tempfilein.path} >#{out.path} 2>#{err.path}")
        
#              if !result
#                raise Exception, "Running phobius program failed. $? was #{$?.inspect}"
#              end
        
              # make sure the error file isn't anything unexpected
              # by default it prints a copyright notice thing
              errs = rio(err.path).readlines
              if errs.length != 3
                raise Exception, "Unexpected phobius standard error: #{errs}"
              end
              
              # 4th line - the first bits are bleh.
              line = rio(out.path).readlines[1] #the second line of stdout is the result line
              
              return PhobiusResult.create_from_short_line(line)
            }
          }
        }
      end
    end
  end
end


class PhobiusResult
  attr_reader :domains
  
  # initialise with the output line of a 
  # eg. 
  #Plasmodium_falciparum_3D7|MAL8|PF08_0140|Annotation|Plasmodium_falciparum_Sanger_Stanford_TIGR|(protein  1  0  o2523-2544i
  def self.create_from_short_line(line)
    protein = TransmembraneProtein.new
    raise Exception, 'Null result returned to phobius wrapper from phobius. Sequence problem?' if !line
  
    
    splits = line.strip.split(" ") #split by some number of spaces. This is a little strange, but eh.
    if splits.length != 4
      raise Exception, "Incorrectly parsed short line from Phobius: #{line}"
    end
    
    substrate = splits[3]
    if substrate.gsub!(/^[io]/,'').nil?
      raise Exception, "Badly parsed Topology hit: #{substrate}"
    end
    
    matches = substrate.match('^(\d+?)\-')
    if !matches
      return protein #no transmembrane domains predicted
    end
    
    # eat the string from the beginning adding the transmembrane domains
    prev = matches[1]
    substrate.gsub!(/^(\d+?)-/,'')
    # match all the middle bits
    reg = /^(\d+?)[io](\d+?)\-/
    while matches =substrate.match(reg)
      tmd = TransmembraneDomainDefinition.new
      tmd.start = prev.to_i
      tmd.stop = matches[1].to_i
      protein.push tmd
      
      prev = matches[2]
      substrate.gsub!(reg, '')
    end
    #match the last bit
    if !(matches = substrate.match('(\d+?)[io]$'))
      raise Exception, "Failed to parse the last bit of: #{substrate}"
    end
    tmd = TransmembraneDomainDefinition.new
    tmd.start = prev.to_i
    tmd.stop = matches[1].to_i
    protein.push tmd
    
    return protein
  end
end



# If being run directly instead of being require'd,
# output one transmembrane per line, and
# indicate that a particular protein has no transmembrane domain
if $0 == __FILE__
  require 'bio'

  runner = PhobiusWrapper.new

  Bio::FlatFile.auto(ARGF).each do |seq|
    result = runner.calculate(seq.seq)
    name = seq.definition

    if result.has_domain?
      # At least one TMD found. Output each on a separate line
      result.transmembrane_domains.each do |tmd|
        puts [
          name,
          'Transmembrane',
          tmd.start,
          tmd.stop
        ].join("\t")
      end
    else
      puts [
        name,
        'No Transmembrane Domain Found'
      ].join("\t")
    end
  end
end