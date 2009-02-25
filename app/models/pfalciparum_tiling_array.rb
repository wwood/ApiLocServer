class PfalciparumTilingArray < ActiveRecord::Base
MEASUREMENT_COLUMNS = %w(
 hb3_1
 hb3_2
 three_d7_1
 three_d7_2
 dd2_1
 dd2_2
 dd2_fosr_1
 dd2_fosr_2
 three_d7_attb
).slap.to_sym.retract

  def average
    total = 0.0
    MEASUREMENT_COLUMNS.each {|c| total += send(c)}
    total / MEASUREMENT_COLUMNS.length
  end
end
