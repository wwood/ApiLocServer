require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_create_id
    id = '1244'
    assert_difference 'Publication.count', 1 do
      pubs = Publication.create_from_ids_or_urls(id)
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
      pubs = Publication.create_from_ids_or_urls(id)
      assert_equal 1, pubs.length
      assert_kind_of Publication, pubs[0]
      assert_equal 'http://nowhere.com', pubs[0].url
      assert_nil pubs[0].pubmed_id
    end    
  end
  
  #test url and id separated by comma
  def test_url_and_id
    id = 'http://nowhere.com/ ww, 1234'
    assert_difference 'Publication.count', 2 do
      pubs = Publication.create_from_ids_or_urls(id)
      assert_equal 2, pubs.length
      
      assert_kind_of Publication, pubs[0]
      assert_equal 'http://nowhere.com/ ww', pubs[0].url
      assert_nil pubs[0].pubmed_id

      assert_kind_of Publication, pubs[1]
      assert_equal 1234, pubs[1].pubmed_id
      assert_nil pubs[1].url
    end    
  end
  
  def test_half_number
    id = '123a'
    assert_raise ParseException do
      Publication.create_from_ids_or_urls(id)
    end    
  end
end
