require File.dirname(__FILE__) + '/../test_helper'

class GoListsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:go_lists)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_go_list
    assert_difference('GoList.count') do
      post :create, :go_list => { }
    end

    assert_redirected_to go_list_path(assigns(:go_list))
  end

  def test_should_show_go_list
    get :show, :id => go_lists(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => go_lists(:one).id
    assert_response :success
  end

  def test_should_update_go_list
    put :update, :id => go_lists(:one).id, :go_list => { }
    assert_redirected_to go_list_path(assigns(:go_list))
  end

  def test_should_destroy_go_list
    assert_difference('GoList.count', -1) do
      delete :destroy, :id => go_lists(:one).id
    end

    assert_redirected_to go_lists_path
  end
end
