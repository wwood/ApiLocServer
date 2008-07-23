require 'test_helper'

class DrosophilaAlleleGenesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:drosophila_allele_genes)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_drosophila_allele_gene
    assert_difference('DrosophilaAlleleGene.count') do
      post :create, :drosophila_allele_gene => { }
    end

    assert_redirected_to drosophila_allele_gene_path(assigns(:drosophila_allele_gene))
  end

  def test_should_show_drosophila_allele_gene
    get :show, :id => drosophila_allele_genes(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => drosophila_allele_genes(:one).id
    assert_response :success
  end

  def test_should_update_drosophila_allele_gene
    put :update, :id => drosophila_allele_genes(:one).id, :drosophila_allele_gene => { }
    assert_redirected_to drosophila_allele_gene_path(assigns(:drosophila_allele_gene))
  end

  def test_should_destroy_drosophila_allele_gene
    assert_difference('DrosophilaAlleleGene.count', -1) do
      delete :destroy, :id => drosophila_allele_genes(:one).id
    end

    assert_redirected_to drosophila_allele_genes_path
  end
end
