$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'rubygems'
require 'tandem_repeat_finder'

class TandemRepeatFinderTest < Test::Unit::TestCase
  def test_foo
    t = Bio::TandemRepeatFinder::Wrapper.new
    p t.run('ATATATATATATATAT')
  end
end
