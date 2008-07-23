require 'test_helper'

class MousePhenoInfosControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:mouse_pheno_infos)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_mouse_pheno_info
    assert_difference('MousePhenoInfo.count') do
      post :create, :mouse_pheno_info => { }
    end

    assert_redirected_to mouse_pheno_info_path(assigns(:mouse_pheno_info))
  end

  def test_should_show_mouse_pheno_info
    get :show, :id => mouse_pheno_infos(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => mouse_pheno_infos(:one).id
    assert_response :success
  end

  def test_should_update_mouse_pheno_info
    put :update, :id => mouse_pheno_infos(:one).id, :mouse_pheno_info => { }
    assert_redirected_to mouse_pheno_info_path(assigns(:mouse_pheno_info))
  end

  def test_should_destroy_mouse_pheno_info
    assert_difference('MousePhenoInfo.count', -1) do
      delete :destroy, :id => mouse_pheno_infos(:one).id
    end

    assert_redirected_to mouse_pheno_infos_path
  end
end
