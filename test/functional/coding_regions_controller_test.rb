require File.dirname(__FILE__) + '/../test_helper'

class CodingRegionsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:coding_regions)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_coding_region
    assert_difference('CodingRegion.count') do
      post :create, :coding_region => { }
    end

    assert_redirected_to coding_region_path(assigns(:coding_region))
  end

  def test_should_show_coding_region
    get :show, :id => coding_regions(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => coding_regions(:one).id
    assert_response :success
  end

  def test_should_update_coding_region
    put :update, :id => coding_regions(:one).id, :coding_region => { }
    assert_redirected_to coding_region_path(assigns(:coding_region))
  end

  def test_should_destroy_coding_region
    assert_difference('CodingRegion.count', -1) do
      delete :destroy, :id => coding_regions(:one).id
    end

    assert_redirected_to coding_regions_path
  end
end
