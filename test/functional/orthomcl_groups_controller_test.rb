require File.dirname(__FILE__) + '/../test_helper'

class OrthomclGroupsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:orthomcl_groups)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_orthomcl_group
    assert_difference('OrthomclGroup.count') do
      post :create, :orthomcl_group => { }
    end

    assert_redirected_to orthomcl_group_path(assigns(:orthomcl_group))
  end

  def test_should_show_orthomcl_group
    get :show, :id => orthomcl_groups(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => orthomcl_groups(:one).id
    assert_response :success
  end

  def test_should_update_orthomcl_group
    put :update, :id => orthomcl_groups(:one).id, :orthomcl_group => { }
    assert_redirected_to orthomcl_group_path(assigns(:orthomcl_group))
  end

  def test_should_destroy_orthomcl_group
    assert_difference('OrthomclGroup.count', -1) do
      delete :destroy, :id => orthomcl_groups(:one).id
    end

    assert_redirected_to orthomcl_groups_path
  end
end
