$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'rubygems'
require 'tandem_repeat_finder'

class TandemRepeatFinderTest < Test::Unit::TestCase
  def setup
    @t = Bio::TandemRepeatFinder::Wrapper.new
  end

  def test_one
    # "1 39 13 3.0 13 100 0 78 7 0 84 7 0.77 AGGGGGGGGGGGT AGGGGGGGGGGGTAGGGGGGGGGGGTAGGGGGGGGGGGT"
    result = @t.run('AGGGGGGGGGGGTAGGGGGGGGGGGTAGGGGGGGGGGGT')
    assert_kind_of Bio::TandemRepeatFinder::Result, result
    assert_equal 1, result.length
    assert_equal 39, result.length_covered
    assert_equal 1, result[0].start
    assert_equal 39, result[0].stop
    assert_equal 3.0, result[0].copy_number
  end

  def test_none
    result = @t.run('AT')
    assert_kind_of Bio::TandemRepeatFinder::Result, result
    assert_equal 0, result.length
    assert_equal 0, result.length_covered
  end

  def test_two
    result = @t.run('AGGGGGGGGGGGTAGGGGGGGGGGGTAGGGGGGGGGGGTAAAAAAAAAAAGTAAAAAAAAAAAGT')
    assert_kind_of Bio::TandemRepeatFinder::Result, result
    assert_equal 2, result.length
    assert_equal 65, result.length_covered # this is overlapping too so a good test
    assert_equal 1, result[0].start
    assert_equal 40, result[0].stop
    assert_equal 3.1, result[0].copy_number
    assert_equal 38, result[1].start
    assert_equal 65, result[1].stop
    assert_equal 2.2, result[1].copy_number
  end
end
