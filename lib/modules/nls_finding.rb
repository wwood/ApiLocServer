class BScript
  # Attempting to see if NLSs are conserved between falciparum and yeast,
  # using the results from the input data set in NLStradamus
  # http://www.biomedcentral.com/1471-2105/10/202
  def nlstradamus_orthologues
    # the first column of table 1
    yeasts = ["YBR009C", "YBR010W", "YDL007W", "YDR103W", "YDR146C", "YDR208W", "YDR224C", "YEL009C", "YER040W", "YFR034C", "YGL071W", "YGL097W", "YHR079C", "YIL075C", "YIL150C", "YJL194W", "YLR103C", "YLR182W", "YML007W", "YMR127C", "YMR239C", "YNL027W", "YOL123W", "YOL127W", "YPL153C", "YPR119W"]
    
    yeasts.each do |y|
      o = OrthomclGene.find_by_orthomcl_name("scer|#{y}")
      if o.nil?
        $stderr.puts "Unmable to find #{y}"
      else
        puts [
        y,
        o.official_group.orthomcl_genes.code('pfal').reach.orthomcl_name.join(", ")
        ].join("\t")
      end
    end
  end
end