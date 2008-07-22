require File.dirname(__FILE__) + '/../test_helper'

class OrthomclGenesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:orthomcl_genes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_orthomcl_gene
    assert_difference('OrthomclGene.count') do
      post :create, :orthomcl_gene => { }
    end

    assert_redirected_to orthomcl_gene_path(assigns(:orthomcl_gene))
  end

  def test_should_show_orthomcl_gene
    get :show, :id => orthomcl_genes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => orthomcl_genes(:one).id
    assert_response :success
  end

  def test_should_update_orthomcl_gene
    put :update, :id => orthomcl_genes(:one).id, :orthomcl_gene => { }
    assert_redirected_to orthomcl_gene_path(assigns(:orthomcl_gene))
  end

  def test_should_destroy_orthomcl_gene
    assert_difference('OrthomclGene.count', -1) do
      delete :destroy, :id => orthomcl_genes(:one).id
    end

    assert_redirected_to orthomcl_genes_path
  end
end
