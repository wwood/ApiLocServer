require File.dirname(__FILE__) + '/../test_helper'

class SpeciesTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_two_letter_name
    assert_equal 'Pf', Species.new(:name => 'Plasmodium fragile').two_letter_prefix
    assert_equal nil, Species.new(:name => 'Plasmodioops').two_letter_prefix
  end
end
