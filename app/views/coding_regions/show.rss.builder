xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "ApiLoc Updates for #{@coding_region.string_id} in #{@coding_region.species.name}"
    xml.description "Web feed giving comments and other changes to #{@coding_region.string_id} in #{@coding_region.species.name} in ApiLoc"
    xml.link coding_region_url(@coding_region)
    
    for context in @coding_region.expression_contexts
      xml.item do
        xml.title context.english
        xml.pubDate context.created_at.to_s(:rfc822)
        xml.link coding_region_url(context.coding_region)
        xml.guid formatted_expression_context_url(context, :rss)
      end
    end
    
    for comment in @coding_region.user_comments
      xml.item do
        xml.title comment.title
        xml.description comment.comment
        xml.pubDate comment.created_at.to_s(:rfc822)
        xml.link coding_region_url(@coding_region)
        xml.guid formatted_coding_region_url(@coding_region, :rss)
      end
    end
  end
end