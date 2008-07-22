require File.dirname(__FILE__) + '/../test_helper'

class ProbeMapsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:probe_maps)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_probe_map
    assert_difference('ProbeMap.count') do
      post :create, :probe_map => { }
    end

    assert_redirected_to probe_map_path(assigns(:probe_map))
  end

  def test_should_show_probe_map
    get :show, :id => probe_maps(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => probe_maps(:one).id
    assert_response :success
  end

  def test_should_update_probe_map
    put :update, :id => probe_maps(:one).id, :probe_map => { }
    assert_redirected_to probe_map_path(assigns(:probe_map))
  end

  def test_should_destroy_probe_map
    assert_difference('ProbeMap.count', -1) do
      delete :destroy, :id => probe_maps(:one).id
    end

    assert_redirected_to probe_maps_path
  end
end
