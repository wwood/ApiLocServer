require 'test_helper'

class ExpressionContextTest < ActiveSupport::TestCase
  
  test "english" do
    assert_equal 1, expression_contexts(:one).developmental_stage_id
    assert_equal "apicoplast during schizont", expression_contexts(:one).english
    assert_equal "ring", expression_contexts(:no_localisation).english
    assert_equal "apicoplast", expression_contexts(:no_developmental_stage).english
  end
end
