require File.dirname(__FILE__) + '/../test_helper'

class SignalPsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:signal_ps)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_signal_p
    assert_difference('SignalP.count') do
      post :create, :signal_p => { }
    end

    assert_redirected_to signal_p_path(assigns(:signal_p))
  end

  def test_should_show_signal_p
    get :show, :id => signal_ps(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => signal_ps(:one).id
    assert_response :success
  end

  def test_should_update_signal_p
    put :update, :id => signal_ps(:one).id, :signal_p => { }
    assert_redirected_to signal_p_path(assigns(:signal_p))
  end

  def test_should_destroy_signal_p
    assert_difference('SignalP.count', -1) do
      delete :destroy, :id => signal_ps(:one).id
    end

    assert_redirected_to signal_ps_path
  end
end
