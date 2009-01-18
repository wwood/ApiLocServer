require 'test_helper'

class ExpressionContextsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expression_contexts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expression_context" do
    assert_difference('ExpressionContext.count') do
      post :create, :expression_context => { }
    end

    assert_redirected_to expression_context_path(assigns(:expression_context))
  end

  test "should show expression_context" do
    get :show, :id => expression_contexts(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => expression_contexts(:one).id
    assert_response :success
  end

  test "should update expression_context" do
    put :update, :id => expression_contexts(:one).id, :expression_context => { }
    assert_redirected_to expression_context_path(assigns(:expression_context))
  end

  test "should destroy expression_context" do
    assert_difference('ExpressionContext.count', -1) do
      delete :destroy, :id => expression_contexts(:one).id
    end

    assert_redirected_to expression_contexts_path
  end
end
