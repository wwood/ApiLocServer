require File.dirname(__FILE__) + '/../test_helper'

class GoTermTest < ActiveSupport::TestCase
  fixtures :go_terms, :go_alternates
  
  # Replace this with your real tests.
  def test_get_by_alternate
    # normal
    assert GoTerm.find_by_go_identifier_or_alternate('GO:0005275')
    
    #alternate
    assert GoTerm.find_by_go_identifier_or_alternate('GO:0005279')
    
    #definitely doesn't exist
    assert_nil GoTerm.find_by_go_identifier_or_alternate('GO:0005279noway')
  end
end
