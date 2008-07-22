require File.dirname(__FILE__) + '/../test_helper'

class LocalisationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:localisations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_localisation
    assert_difference('Localisation.count') do
      post :create, :localisation => { }
    end

    assert_redirected_to localisation_path(assigns(:localisation))
  end

  def test_should_show_localisation
    get :show, :id => localisations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => localisations(:one).id
    assert_response :success
  end

  def test_should_update_localisation
    put :update, :id => localisations(:one).id, :localisation => { }
    assert_redirected_to localisation_path(assigns(:localisation))
  end

  def test_should_destroy_localisation
    assert_difference('Localisation.count', -1) do
      delete :destroy, :id => localisations(:one).id
    end

    assert_redirected_to localisations_path
  end
end
