require File.dirname(__FILE__) + '/../test_helper'

class ClusterEntriesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:cluster_entries)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_cluster_entry
    assert_difference('ClusterEntry.count') do
      post :create, :cluster_entry => { }
    end

    assert_redirected_to cluster_entry_path(assigns(:cluster_entry))
  end

  def test_should_show_cluster_entry
    get :show, :id => cluster_entries(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => cluster_entries(:one).id
    assert_response :success
  end

  def test_should_update_cluster_entry
    put :update, :id => cluster_entries(:one).id, :cluster_entry => { }
    assert_redirected_to cluster_entry_path(assigns(:cluster_entry))
  end

  def test_should_destroy_cluster_entry
    assert_difference('ClusterEntry.count', -1) do
      delete :destroy, :id => cluster_entries(:one).id
    end

    assert_redirected_to cluster_entries_path
  end
end
