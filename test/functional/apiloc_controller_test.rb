require 'test_helper'

class ApilocControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "negative_species_named_route" do
    assert_equal 'http://test.host/apiloc/species/negative/Plasmodium%20caninum',
    negative_species_url('Plasmodium caninum')
  end
  
  test "positive species page" do
    get(:species, :id => 'Plasmodium falciparum')
    assert_template 'apiloc/species'
    assert_equal true, assigns(:viewing_positive_localisations)
  end
  
  test "negative species" do
    get(:species, :id => 'Plasmodium falciparum', :negative => true)
    assert_template 'apiloc/species'
    assert_equal false, assigns(:viewing_positive_localisations)
  end
  
  test "cytoplasm not organellar" do
    get(:localisation, :id => Localisation::CYTOPLASM_NOT_ORGANELLAR_PUBLIC_NAME)
    assert_response :success
    assert_nil flash[:error]
    assert_equal 'cytoplasm', assigns(:top_level_localisation).name
  end
end
