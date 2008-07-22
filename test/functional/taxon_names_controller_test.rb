require File.dirname(__FILE__) + '/../test_helper'

class TaxonNamesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:taxon_names)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_taxon_name
    assert_difference('TaxonName.count') do
      post :create, :taxon_name => { }
    end

    assert_redirected_to taxon_name_path(assigns(:taxon_name))
  end

  def test_should_show_taxon_name
    get :show, :id => taxon_names(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => taxon_names(:one).id
    assert_response :success
  end

  def test_should_update_taxon_name
    put :update, :id => taxon_names(:one).id, :taxon_name => { }
    assert_redirected_to taxon_name_path(assigns(:taxon_name))
  end

  def test_should_destroy_taxon_name
    assert_difference('TaxonName.count', -1) do
      delete :destroy, :id => taxon_names(:one).id
    end

    assert_redirected_to taxon_names_path
  end
end
