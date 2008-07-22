require File.dirname(__FILE__) + '/../test_helper'

class GenericGoMapsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:generic_go_maps)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_generic_go_map
    assert_difference('GenericGoMap.count') do
      post :create, :generic_go_map => { }
    end

    assert_redirected_to generic_go_map_path(assigns(:generic_go_map))
  end

  def test_should_show_generic_go_map
    get :show, :id => generic_go_maps(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => generic_go_maps(:one).id
    assert_response :success
  end

  def test_should_update_generic_go_map
    put :update, :id => generic_go_maps(:one).id, :generic_go_map => { }
    assert_redirected_to generic_go_map_path(assigns(:generic_go_map))
  end

  def test_should_destroy_generic_go_map
    assert_difference('GenericGoMap.count', -1) do
      delete :destroy, :id => generic_go_maps(:one).id
    end

    assert_redirected_to generic_go_maps_path
  end
end
