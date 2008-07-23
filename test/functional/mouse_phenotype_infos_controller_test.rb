require 'test_helper'

class MousePhenotypeInfosControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:mouse_phenotype_infos)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_mouse_phenotype_info
    assert_difference('MousePhenotypeInfo.count') do
      post :create, :mouse_phenotype_info => { }
    end

    assert_redirected_to mouse_phenotype_info_path(assigns(:mouse_phenotype_info))
  end

  def test_should_show_mouse_phenotype_info
    get :show, :id => mouse_phenotype_infos(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => mouse_phenotype_infos(:one).id
    assert_response :success
  end

  def test_should_update_mouse_phenotype_info
    put :update, :id => mouse_phenotype_infos(:one).id, :mouse_phenotype_info => { }
    assert_redirected_to mouse_phenotype_info_path(assigns(:mouse_phenotype_info))
  end

  def test_should_destroy_mouse_phenotype_info
    assert_difference('MousePhenotypeInfo.count', -1) do
      delete :destroy, :id => mouse_phenotype_infos(:one).id
    end

    assert_redirected_to mouse_phenotype_infos_path
  end
end
