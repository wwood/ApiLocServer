class ExpressionContext < ActiveRecord::Base
  belongs_to :publication
  belongs_to :developmental_stage
  belongs_to :developmental_stage
  belongs_to :localisation
end
