class ExpressionContext < ActiveRecord::Base
  belongs_to :publication
  belongs_to :developmental_stage
  belongs_to :coding_region
  belongs_to :localisation
  
  # mainly for testing - order of things not particularly relevant
  def <=>(another)
    [:coding_region_id, :localisation_id, :developmental_stage_id, :publication_id].each do |col|
      me = send(col)
      you = another.send(col)
      if me and you
        return me<=>you
      elsif me and !you
        return 1
      elsif !me and you
        return -1
      end
    end
    return 0
  end
end
