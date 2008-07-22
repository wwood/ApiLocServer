require File.dirname(__FILE__) + '/../test_helper'

class ClustersetsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:clustersets)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_clusterset
    assert_difference('Clusterset.count') do
      post :create, :clusterset => { }
    end

    assert_redirected_to clusterset_path(assigns(:clusterset))
  end

  def test_should_show_clusterset
    get :show, :id => clustersets(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => clustersets(:one).id
    assert_response :success
  end

  def test_should_update_clusterset
    put :update, :id => clustersets(:one).id, :clusterset => { }
    assert_redirected_to clusterset_path(assigns(:clusterset))
  end

  def test_should_destroy_clusterset
    assert_difference('Clusterset.count', -1) do
      delete :destroy, :id => clustersets(:one).id
    end

    assert_redirected_to clustersets_path
  end
end
