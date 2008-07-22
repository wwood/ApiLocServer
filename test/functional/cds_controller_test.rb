require File.dirname(__FILE__) + '/../test_helper'

class CdsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:cds)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_cds
    assert_difference('Cds.count') do
      post :create, :cds => { }
    end

    assert_redirected_to cds_path(assigns(:cds))
  end

  def test_should_show_cds
    get :show, :id => cds(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => cds(:one).id
    assert_response :success
  end

  def test_should_update_cds
    put :update, :id => cds(:one).id, :cds => { }
    assert_redirected_to cds_path(assigns(:cds))
  end

  def test_should_destroy_cds
    assert_difference('Cds.count', -1) do
      delete :destroy, :id => cds(:one).id
    end

    assert_redirected_to cds_path
  end
end
