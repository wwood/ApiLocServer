require File.dirname(__FILE__) + '/../test_helper'

class SpeciesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:species)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_species
    assert_difference('Species.count') do
      post :create, :species => { }
    end

    assert_redirected_to species_path(assigns(:species))
  end

  def test_should_show_species
    get :show, :id => species(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => species(:one).id
    assert_response :success
  end

  def test_should_update_species
    put :update, :id => species(:one).id, :species => { }
    assert_redirected_to species_path(assigns(:species))
  end

  def test_should_destroy_species
    assert_difference('Species.count', -1) do
      delete :destroy, :id => species(:one).id
    end

    assert_redirected_to species_path
  end
end
