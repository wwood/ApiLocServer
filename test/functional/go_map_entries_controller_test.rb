require File.dirname(__FILE__) + '/../test_helper'

class GoMapEntriesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:go_map_entries)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_go_map_entry
    assert_difference('GoMapEntry.count') do
      post :create, :go_map_entry => { }
    end

    assert_redirected_to go_map_entry_path(assigns(:go_map_entry))
  end

  def test_should_show_go_map_entry
    get :show, :id => go_map_entries(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => go_map_entries(:one).id
    assert_response :success
  end

  def test_should_update_go_map_entry
    put :update, :id => go_map_entries(:one).id, :go_map_entry => { }
    assert_redirected_to go_map_entry_path(assigns(:go_map_entry))
  end

  def test_should_destroy_go_map_entry
    assert_difference('GoMapEntry.count', -1) do
      delete :destroy, :id => go_map_entries(:one).id
    end

    assert_redirected_to go_map_entries_path
  end
end
