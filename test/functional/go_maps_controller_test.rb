require File.dirname(__FILE__) + '/../test_helper'

class GoMapsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:go_maps)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_go_map
    assert_difference('GoMap.count') do
      post :create, :go_map => { }
    end

    assert_redirected_to go_map_path(assigns(:go_map))
  end

  def test_should_show_go_map
    get :show, :id => go_maps(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => go_maps(:one).id
    assert_response :success
  end

  def test_should_update_go_map
    put :update, :id => go_maps(:one).id, :go_map => { }
    assert_redirected_to go_map_path(assigns(:go_map))
  end

  def test_should_destroy_go_map
    assert_difference('GoMap.count', -1) do
      delete :destroy, :id => go_maps(:one).id
    end

    assert_redirected_to go_maps_path
  end
end
