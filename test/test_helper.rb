ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class ActiveSupport::TestCase
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
    unless differences.kind_of?(Array)
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

end
