require 'reach'

class ExpressionContext < ActiveRecord::Base
  belongs_to :publication
  belongs_to :developmental_stage
  belongs_to :coding_region
  belongs_to :localisation
  belongs_to :localisation_modifier
  
  has_many :comments
  
  # mainly for testing - order of things not particularly relevant
  def <=>(another)
    [:coding_region_id, :localisation_id, :developmental_stage_id, :publication_id].each do |col|
      me = send(col)
      you = another.send(col)
      if me and you and me!=you
        return me<=>you
      elsif me and !you
        return 1
      elsif !me and you
        return -1
      end
    end
    return 0
  end
  
  def english
    return nil if !localisation_id and !developmental_stage_id
    if developmental_stage_id and localisation_id
      return "#{localisation.name} during #{developmental_stage.name}"
    elsif developmental_stage_id
      return "#{developmental_stage.name}"
    else
      return localisation.name
    end
  end
  
  def spreadsheet_english
    [
      "\"#{coding_region.coding_region_alternate_string_ids.all(:order => 'created_at desc').reach.name.reject{|n| n.nil?}.uniq.join(', ')}\"",
      coding_region.string_id,
      english,
      publication.definition,
      "\"#{comments.reach.comment.join(', ')}\""
    ]
  end
  
  # Comparison operator, mainly for testing
  def ==(another)
    [:coding_region_id, :localisation_id, :developmental_stage_id, :publication_id].each do |col|
      me = send(col)
      you = another.send(col)
      if me and you and me!=you
        return false
      elsif me and !you
        return false
      elsif !me and you
        return false
      end
    end
    return true
  end
end
