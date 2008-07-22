require File.dirname(__FILE__) + '/../test_helper'

class GoTermsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:go_terms)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_go_term
    assert_difference('GoTerm.count') do
      post :create, :go_term => { }
    end

    assert_redirected_to go_term_path(assigns(:go_term))
  end

  def test_should_show_go_term
    get :show, :id => go_terms(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => go_terms(:one).id
    assert_response :success
  end

  def test_should_update_go_term
    put :update, :id => go_terms(:one).id, :go_term => { }
    assert_redirected_to go_term_path(assigns(:go_term))
  end

  def test_should_destroy_go_term
    assert_difference('GoTerm.count', -1) do
      delete :destroy, :id => go_terms(:one).id
    end

    assert_redirected_to go_terms_path
  end
end
