require File.dirname(__FILE__) + '/../test_helper'

class SpeciesTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_two_letter_name
    assert_equal 'Pf', Species.new(:name => 'Plasmodium fragile').two_letter_prefix
    assert_equal nil, Species.new(:name => 'Plasmodioops').two_letter_prefix
  end
  
  def test_four_letter_to_species_name
    assert_equal Species::HUMAN_NAME, Species.four_letter_to_species_name('hsap')
    assert_raise Exception do
      Species.four_letter_to_species_name('aaaa')
    end
  end
  
  def test_agreeable_name_and_two_letter_prefix
    assert_equal true,
    Species.agreeable_name_and_two_letter_prefix?(Species.falciparum_name, 'PfNAddaco')
    assert_equal false,
    Species.agreeable_name_and_two_letter_prefix?(Species.falciparum_name, 'TgNAddaco')
  end
end
