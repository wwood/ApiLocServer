require 'test_helper'

class PhenotypeObservedsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:phenotype_observeds)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_phenotype_observed
    assert_difference('PhenotypeObserved.count') do
      post :create, :phenotype_observed => { }
    end

    assert_redirected_to phenotype_observed_path(assigns(:phenotype_observed))
  end

  def test_should_show_phenotype_observed
    get :show, :id => phenotype_observeds(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => phenotype_observeds(:one).id
    assert_response :success
  end

  def test_should_update_phenotype_observed
    put :update, :id => phenotype_observeds(:one).id, :phenotype_observed => { }
    assert_redirected_to phenotype_observed_path(assigns(:phenotype_observed))
  end

  def test_should_destroy_phenotype_observed
    assert_difference('PhenotypeObserved.count', -1) do
      delete :destroy, :id => phenotype_observeds(:one).id
    end

    assert_redirected_to phenotype_observeds_path
  end
end
