require 'go'

# A class to represent all offspring of a go term. The main idea is to be able to
# speed up queries that use multiple go terms, so that you don't
# have to query bioconductor every time
#
# It is NOT intended that this table include synonyms - all synonyms should
# be mapped to primary ids before interaction with this table
class GoTermOffspring < ActiveRecord::Base
  def load_from_bioconductor
    go_object = Bio::Go.new

    GoTerm.all.each do |parent|
      print '.'
      $stdout.flush

      begin
        offspring = go_object.go_offspring(parent.go_identifier)

        # Add the obvious
        GoTermOffspring.find_or_create_by_go_term_id_and_offspring_go_term_id(
          parent.id,
          parent.id
        )

        # Add th e real offspring
        offspring.each do |off|
          off_term = GoTerm.find_by_go_identifier_or_alternate(off)
          GoTermOffspring.find_or_create_by_go_term_id_and_offspring_go_term_id(
            parent.id,
            off_term.id
          )
        end

      rescue RException
        $stderr.puts "Failed to find #{parent.go_identifier}"
      end
    end
    puts
  end
end
