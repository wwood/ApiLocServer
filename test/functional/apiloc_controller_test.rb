require 'test_helper'

class ApilocControllerTest < ActionController::TestCase
  test "gene no hit" do
    get(:gene, :id => 'not a gene')
    assert_template 'apiloc/choose_species.erb'
    assert_equal 'not a gene', assigns(:gene_id)
    assert_nil assigns(:species_name)
    assert_equal [], assigns(:codes)
  end
  
  test "gene single hit no species" do
    get(:gene, :id => 'PF1')
    assert_redirected_to :controller => :apiloc,
    :action => :gene, :id => 'PF1', :species => 'Plasmodium falciparum'
  end
  
  test "gene species gene not found" do
    get(:gene, :id => 'PFnot', :species => 'Plasmodium falciparum')
    assert_equal 'PFnot', assigns(:gene_id)
    assert_template 'apiloc/choose_species.erb'
    assert_equal [], assigns(:codes)
    assert_equal 'Plasmodium falciparum', assigns(:species_name)
  end
  
  test "gene species species not found" do
    get(:gene, :id => 'PF1', :species => 'Plasmodium blah')
    assert_equal 'PF1', assigns(:gene_id)
    assert_template 'apiloc/choose_species.erb'
    assert_equal [], assigns(:codes)
    assert_equal 'Plasmodium blah', assigns(:species_name)
  end
end
