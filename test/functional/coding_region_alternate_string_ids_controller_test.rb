require File.dirname(__FILE__) + '/../test_helper'

class CodingRegionAlternateStringIdsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:coding_region_alternate_string_ids)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_coding_region_alternate_string_ids
    assert_difference('CodingRegionAlternateStringIds.count') do
      post :create, :coding_region_alternate_string_ids => { }
    end

    assert_redirected_to coding_region_alternate_string_ids_path(assigns(:coding_region_alternate_string_ids))
  end

  def test_should_show_coding_region_alternate_string_ids
    get :show, :id => coding_region_alternate_string_ids(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => coding_region_alternate_string_ids(:one).id
    assert_response :success
  end

  def test_should_update_coding_region_alternate_string_ids
    put :update, :id => coding_region_alternate_string_ids(:one).id, :coding_region_alternate_string_ids => { }
    assert_redirected_to coding_region_alternate_string_ids_path(assigns(:coding_region_alternate_string_ids))
  end

  def test_should_destroy_coding_region_alternate_string_ids
    assert_difference('CodingRegionAlternateStringIds.count', -1) do
      delete :destroy, :id => coding_region_alternate_string_ids(:one).id
    end

    assert_redirected_to coding_region_alternate_string_ids_path
  end
end
