# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Draw a list of coding regions
  def coding_region_list(coding_regions)
    # Add list of coding regions
    links = coding_regions.sort{|a,b|
      a.string_id <=> b.string_id
    }.collect{ |code|
      "<li>#{link_to code.string_id, :controller => :coding_regions, :action => :show, :id => code}</li>"
    }.join("\n")
    to_return = "<ul>\n#{links}\n</ul>"
    
    # Add export possibilities
    to_return += link_to "Export #{coding_regions.length} proteins >>", :controller => :coding_regions, :action => :export, 
      :params => {:string_ids => coding_regions.reach.string_id.join(",")}
    
    to_return
  end
end
