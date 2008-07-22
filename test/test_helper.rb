ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  
  # assert_difference is a handy new type of assertion. I downloaded this snippet from
  # http://project.ioni.st/post/218#post-218
  # and I've seen other people use it as well
  #
  # For instance this should be ok:
  # assert_difference Publication, :count do {
  #   Publication.new(..).save!
  # }
  #
  # because there will be one more publication after the block is through.
  # See also assert_no_difference
  def assert_difference(object, method, difference=1)
    initial_value = object.send(method)
    yield
    assert_equal initial_value + difference,
      object.send(method), "#{object}##{method}"
  end
  
  # assert_difference is a handy new type of assertion. I downloaded this snippet from
  # http://project.ioni.st/post/218#post-218
  # and I've seen other people use it as well
  def assert_no_difference(object, method, &block)
    assert_difference object, method, 0, &block
  end
  
  
  
  # I wrote this method myself, when I wanted to observe more than a single variable
  # at a time.
  #
  # Works like assert_difference, except arrays of objects and methods are passed instead
  def assert_differences(objects, methods=nil, differences = 1)
    
    # Initialising
    initial_values = []
    if methods
      assert_equal objects.length, methods.length #some people are idiots.
    end
    
    i = 0
    if methods
      for m in methods
        initial_values[i] = objects[i].send(m)
        i += 1
      end
    else
      for o in objects
        initial_values[i] = objects[i].send(:count)
        i += 1
      end
    end
    
    yield
    
    # Checking at the end
    if differences == 1
      # everything is incremented by one
      i = 0
      for initial in initial_values
        assert_equal initial_values[i]+differences, objects[i].send(methods[i]), "#{objects[i]}##{methods[i]}"
        i += 1
      end
    else
      # It is an array
      assert_equal initial_values.length, differences.length
      i = 0
      for initial in initial_values
        if methods
          assert_equal initial_values[i]+differences[i], objects[i].send(methods[i]), "#{objects[i]}##{methods[i]}"
        else
          assert_equal initial_values[i]+differences[i], objects[i].send(:count), "#{objects[i]}##{:count}"
        end
        i += 1
      end      
    end
  end
  
  
  
  
  
  # get us an object that represents an uploaded file
  # method copied from http://manuals.rubyonrails.com/read/chapter/28#page237
  def uploaded_file(path, content_type="application/octet-stream", filename=nil)
    filename ||= File.basename(path)
    t = Tempfile.new(filename)
    FileUtils.copy_file(path, t.path)
    (class << t; self; end;).class_eval do
      alias local_path path
      define_method(:original_filename) { filename }
      define_method(:content_type) { content_type }
    end
    return t
  end
end
