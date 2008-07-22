require File.dirname(__FILE__) + '/../test_helper'

class CodingRegionLocalisationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:coding_region_localisations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_coding_region_localisation
    assert_difference('CodingRegionLocalisation.count') do
      post :create, :coding_region_localisation => { }
    end

    assert_redirected_to coding_region_localisation_path(assigns(:coding_region_localisation))
  end

  def test_should_show_coding_region_localisation
    get :show, :id => coding_region_localisations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => coding_region_localisations(:one).id
    assert_response :success
  end

  def test_should_update_coding_region_localisation
    put :update, :id => coding_region_localisations(:one).id, :coding_region_localisation => { }
    assert_redirected_to coding_region_localisation_path(assigns(:coding_region_localisation))
  end

  def test_should_destroy_coding_region_localisation
    assert_difference('CodingRegionLocalisation.count', -1) do
      delete :destroy, :id => coding_region_localisations(:one).id
    end

    assert_redirected_to coding_region_localisations_path
  end
end
