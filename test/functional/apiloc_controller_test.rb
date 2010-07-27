require 'test_helper'

class ApilocControllerTest < ActionController::TestCase
  ##   this setup is too slow..
  ##  setup do
  ##    puts "setting up.."
  ##    sp = Species.find_by_name(Species::BERGHEI_NAME)
  ##    LocalisationSpreadsheet.new.upload_static_info(sp)
  ##    
  ##    DevelopmentalStageTopLevelDevelopmentalStage.new.upload_apiloc_top_level_developmental_stages
  ##    ApilocLocalisationTopLevelLocalisation.new.upload_apiloc_top_level_localisations
  ##    puts '..done'
  ##  end
  
  #  setup do
  #    puts
  #    puts
  #  end
  
  test "index" do
    get(:index)
    assert_template 'apiloc/index.html.erb'
  end
  
  test "gene no hit" do
    get(:gene, :id => 'not a gene')
    assert_template 'apiloc/choose_species.erb'
    assert_equal 'not a gene', assigns(:gene_id)
    assert_nil assigns(:species_name)
    assert_equal [], assigns(:codes)
  end
  
  test "gene hits 1 gene exactly but multiple genes partially no species" do
    get(:gene, :id => 'PF1')
    assert_template 'apiloc/choose_species.erb'
    assert_equal [5,6,20,21].collect{|n| 
      CodingRegion.find(n)
    }, assigns(:codes).sort{|a,b| a.id <=> b.id}
  end
  
  test "gene hits 1 gene exactly and partially no species" do
    get(:gene, :id => 'PF1.1')
    assert_redirected_to :controller => :apiloc, 
    :action => :gene, :species => 'Plasmodium falciparum'
    assert_equal CodingRegion.find(6), assigns(:code)
  end
  
  test "gene species gene not found" do
    get(:gene, :id => 'PFnot', :species => 'Plasmodium falciparum')
    assert_equal 'PFnot', assigns(:gene_id)
    assert_template 'apiloc/choose_species.erb'
    assert_equal [], assigns(:codes)
    assert_equal 'Plasmodium falciparum', assigns(:species_name)
  end
  
  test "gene species species not found" do
    get(:gene, :id => 'PF1', :species => 'Plasmodium blah')
    assert_equal 'PF1', assigns(:gene_id)
    assert_template 'apiloc/choose_species.erb'
    assert_equal [], assigns(:codes)
    assert_equal 'Plasmodium blah', assigns(:species_name)
  end
  
  test "gene species and coding region 2 letter abbreviation name conflict" do
    get(:gene, :id => 'TgPF1', :species => 'Plasmodium falciparum')
    assert_equal 21, assigns(:code).id
  end
  
  test "multiple gene names including one which is the whole" do
    get(:gene, :id => 'mea')
    assert_template 'apiloc/choose_species.erb'
    assert_not_nil assigns(:codes)
    assert_equal [12,13,16,17], assigns(:codes).pick(:id).sort
  end
  
  test "find by annotation" do
    get(:gene, :id => 'massive')
    #    assert_equal [CodingRegion.find(1), CodingRegion.find(2)],
    #    assigns(:codes).sort{|a,b| a.id <=> b.id}
  end
  
  
  test "test searching for genes with lower case only" do
  
end

test "negative_species_named_route" do
  assert_equal 'http://test.host/apiloc/species/negative/Plasmodium%20caninum',
  negative_species_url('Plasmodium caninum')
end

test "positive species page" do
  get(:species, :id => 'Plasmodium falciparum')
  assert_template 'apiloc/species'
  assert_equal true, assigns(:viewing_positive_localisations)
end

test "negative species" do
  get(:species, :id => 'Plasmodium falciparum', :negative => true)
  assert_template 'apiloc/species'
  assert_equal false, assigns(:viewing_positive_localisations)
end

test "cytoplasm not organellar" do
  get(:localisation, :id => Localisation::CYTOPLASM_NOT_ORGANELLAR_PUBLIC_NAME)
  assert_response :success
  assert_nil flash[:error]
  assert_equal 'cytoplasm', assigns(:top_level_localisation).name
end
end
