require File.dirname(__FILE__) + '/../test_helper'

class ScaffoldsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:scaffolds)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_scaffold
    assert_difference('Scaffold.count') do
      post :create, :scaffold => { }
    end

    assert_redirected_to scaffold_path(assigns(:scaffold))
  end

  def test_should_show_scaffold
    get :show, :id => scaffolds(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => scaffolds(:one).id
    assert_response :success
  end

  def test_should_update_scaffold
    put :update, :id => scaffolds(:one).id, :scaffold => { }
    assert_redirected_to scaffold_path(assigns(:scaffold))
  end

  def test_should_destroy_scaffold
    assert_difference('Scaffold.count', -1) do
      delete :destroy, :id => scaffolds(:one).id
    end

    assert_redirected_to scaffolds_path
  end
end
