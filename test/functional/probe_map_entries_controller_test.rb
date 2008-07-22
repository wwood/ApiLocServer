require File.dirname(__FILE__) + '/../test_helper'

class ProbeMapEntriesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:probe_map_entries)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_probe_map_entry
    assert_difference('ProbeMapEntry.count') do
      post :create, :probe_map_entry => { }
    end

    assert_redirected_to probe_map_entry_path(assigns(:probe_map_entry))
  end

  def test_should_show_probe_map_entry
    get :show, :id => probe_map_entries(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => probe_map_entries(:one).id
    assert_response :success
  end

  def test_should_update_probe_map_entry
    put :update, :id => probe_map_entries(:one).id, :probe_map_entry => { }
    assert_redirected_to probe_map_entry_path(assigns(:probe_map_entry))
  end

  def test_should_destroy_probe_map_entry
    assert_difference('ProbeMapEntry.count', -1) do
      delete :destroy, :id => probe_map_entries(:one).id
    end

    assert_redirected_to probe_map_entries_path
  end
end
