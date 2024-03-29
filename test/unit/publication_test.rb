require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_create_id
    id = '1244'
    assert_difference 'Publication.count', 1 do
      pubs = Publication.find_create_from_ids_or_urls(id)
      assert_equal 1, pubs.length
      assert_kind_of Publication, pubs[0]
      assert_equal 1244, pubs[0].pubmed_id
      assert_nil pubs[0].url
    end
  end
  
  # test url
  def test_url
    id = 'http://nowhere.com'
    assert_difference 'Publication.count', 1 do
      pubs = Publication.find_create_from_ids_or_urls(id)
      assert_equal 1, pubs.length
      assert_kind_of Publication, pubs[0]
      assert_equal 'http://nowhere.com', pubs[0].url
      assert_nil pubs[0].pubmed_id
    end    
  end
  
  #test url and id separated by comma
  def test_url_and_id
    id = 'http://nowhere.com/ ww, 1234'
    assert_raise ParseException do
      pubs = Publication.find_create_from_ids_or_urls(id)
    end    
  end
  
  def test_half_number
    id = '123a'
    assert_equal [], Publication.find_create_from_ids_or_urls(id)
  end
  
  def test_upload_again
    id = '145'
    assert_difference 'Publication.count' do
      Publication.find_create_from_ids_or_urls(id)
    end
    assert_difference 'Publication.count', 0 do
      Publication.find_create_from_ids_or_urls(id)
    end
  end
  
  def test_year
    assert_equal 1997, Publication.new(:date => '1997').year
    assert_equal nil, Publication.new(:date => 'ages ago').year
    assert_equal 2003, Publication.new(:date => 'May, 2003').year
  end
  
  def test_fulltext_url
    p = Publication.new(:url => 'http://abc.net')
    assert_equal 'http://abc.net', p.fulltext_url
    p.pubmed_id = 3
    assert_equal 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=pubmed&id=3&retmode=ref&cmd=prlinks', p.fulltext_url
  end
end
