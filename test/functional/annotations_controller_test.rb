require File.dirname(__FILE__) + '/../test_helper'

class AnnotationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:annotations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_annotation
    assert_difference('Annotation.count') do
      post :create, :annotation => { }
    end

    assert_redirected_to annotation_path(assigns(:annotation))
  end

  def test_should_show_annotation
    get :show, :id => annotations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => annotations(:one).id
    assert_response :success
  end

  def test_should_update_annotation
    put :update, :id => annotations(:one).id, :annotation => { }
    assert_redirected_to annotation_path(assigns(:annotation))
  end

  def test_should_destroy_annotation
    assert_difference('Annotation.count', -1) do
      delete :destroy, :id => annotations(:one).id
    end

    assert_redirected_to annotations_path
  end
end
