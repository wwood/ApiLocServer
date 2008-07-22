require File.dirname(__FILE__) + '/../test_helper'

class PlasmodbGeneListsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:plasmodb_gene_lists)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_plasmodb_gene_list
    assert_difference('PlasmodbGeneList.count') do
      post :create, :plasmodb_gene_list => { }
    end

    assert_redirected_to plasmodb_gene_list_path(assigns(:plasmodb_gene_list))
  end

  def test_should_show_plasmodb_gene_list
    get :show, :id => plasmodb_gene_lists(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => plasmodb_gene_lists(:one).id
    assert_response :success
  end

  def test_should_update_plasmodb_gene_list
    put :update, :id => plasmodb_gene_lists(:one).id, :plasmodb_gene_list => { }
    assert_redirected_to plasmodb_gene_list_path(assigns(:plasmodb_gene_list))
  end

  def test_should_destroy_plasmodb_gene_list
    assert_difference('PlasmodbGeneList.count', -1) do
      delete :destroy, :id => plasmodb_gene_lists(:one).id
    end

    assert_redirected_to plasmodb_gene_lists_path
  end
end
