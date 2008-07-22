require File.dirname(__FILE__) + '/../test_helper'

class GoAlternatesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:go_alternates)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_go_alternate
    assert_difference('GoAlternate.count') do
      post :create, :go_alternate => { }
    end

    assert_redirected_to go_alternate_path(assigns(:go_alternate))
  end

  def test_should_show_go_alternate
    get :show, :id => go_alternates(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => go_alternates(:one).id
    assert_response :success
  end

  def test_should_update_go_alternate
    put :update, :id => go_alternates(:one).id, :go_alternate => { }
    assert_redirected_to go_alternate_path(assigns(:go_alternate))
  end

  def test_should_destroy_go_alternate
    assert_difference('GoAlternate.count', -1) do
      delete :destroy, :id => go_alternates(:one).id
    end

    assert_redirected_to go_alternates_path
  end
end
