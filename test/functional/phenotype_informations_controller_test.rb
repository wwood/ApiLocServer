require 'test_helper'

class PhenotypeInformationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:phenotype_informations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_phenotype_information
    assert_difference('PhenotypeInformation.count') do
      post :create, :phenotype_information => { }
    end

    assert_redirected_to phenotype_information_path(assigns(:phenotype_information))
  end

  def test_should_show_phenotype_information
    get :show, :id => phenotype_informations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => phenotype_informations(:one).id
    assert_response :success
  end

  def test_should_update_phenotype_information
    put :update, :id => phenotype_informations(:one).id, :phenotype_information => { }
    assert_redirected_to phenotype_information_path(assigns(:phenotype_information))
  end

  def test_should_destroy_phenotype_information
    assert_difference('PhenotypeInformation.count', -1) do
      delete :destroy, :id => phenotype_informations(:one).id
    end

    assert_redirected_to phenotype_informations_path
  end
end
