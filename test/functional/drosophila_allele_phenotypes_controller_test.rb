require 'test_helper'

class DrosophilaAllelePhenotypesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:drosophila_allele_phenotypes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_drosophila_allele_phenotype
    assert_difference('DrosophilaAllelePhenotype.count') do
      post :create, :drosophila_allele_phenotype => { }
    end

    assert_redirected_to drosophila_allele_phenotype_path(assigns(:drosophila_allele_phenotype))
  end

  def test_should_show_drosophila_allele_phenotype
    get :show, :id => drosophila_allele_phenotypes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => drosophila_allele_phenotypes(:one).id
    assert_response :success
  end

  def test_should_update_drosophila_allele_phenotype
    put :update, :id => drosophila_allele_phenotypes(:one).id, :drosophila_allele_phenotype => { }
    assert_redirected_to drosophila_allele_phenotype_path(assigns(:drosophila_allele_phenotype))
  end

  def test_should_destroy_drosophila_allele_phenotype
    assert_difference('DrosophilaAllelePhenotype.count', -1) do
      delete :destroy, :id => drosophila_allele_phenotypes(:one).id
    end

    assert_redirected_to drosophila_allele_phenotypes_path
  end
end
