

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'plasmo_a_p'

class PlasmoAPTest < Test::Unit::TestCase
  def setup
    # constructs are taken from the Science paper supplementary material.
    # Constructs are made using ACP as the base amino acid sequence - the constructs deviate from that
    signal = 'MKILLLCIIFLYYVNA'
    transit = 'FKNTQKDGVSLQILKKKRSNQVNF'
    rest = 'LNRKNDYNLIKNKNPSSSLKSTFDDIKKIISKQLSVEEDKIQMNSNFTKDLGADSLDLVELIMALEEKFNVTISDQDALKINTVQDAIDYIEKNNKQ'
    
    @constructs = []
    @names = []
    
    # base
    @names.push 'base'
    @constructs.push signal+transit+rest
    
    # no signal
    @names.push 'no signal peptide'
    @constructs.push 'M'+transit+rest
    
    # not transit
    @names.push 'no transit peptide'
    @constructs.push signal+rest
    
    # 2 A changes
    @names.push '2 A changes'
    myt = transit.clone
    myt[1] = 'A'
    myt[5] = 'A'
    @constructs.push signal+myt+rest
    
    # 1 E change
    @names.push '1 E change'
    myt = transit.clone
    myt[5] = 'E'
    @constructs.push signal+myt+rest
    
    # another 1 E changed
    @names.push 'another 1 E change'
    myt = transit.clone
    myt[1] = 'E'
    @constructs.push signal+myt+rest
    
    
    # 2 E changed
    @names.push '2 E change'
    myt = transit.clone
    myt[1] = 'E'
    myt[5] = 'E'
    @constructs.push signal+myt+rest
    
    # 2 D changed
    @names.push '2 D change'
    myt = transit.clone
    myt[1] = 'D'
    myt[5] = 'D'
    @constructs.push signal+myt+rest
    
    # 3 A changed
    @names.push '3 A change'
    myt = transit.clone
    myt[10] = 'A'
    myt[12] = 'A'
    myt[13] = 'A'
    @constructs.push signal+myt+rest
    
    @construct_points = [
      5,
      0,
      1,
      4,
      5,
      4,
      0,
      0,
      5
    ]
    
    @construct_strings = [
      '++',
      '-',
      '-',
      '+',
      '++',
      '+',
      '-',
      '-',
      '++'
    ]

    @plasmoap = Bio::PlasmoAP.new
  end
  
  def test_official_paper_constructs
    @constructs.each_with_index do |construct, i|
      obj = @plasmoap.calculate_score(construct)
      assert_kind_of Bio::PlasmoAPResult, obj
      assert_equal @construct_points[i], obj.points, "#{@names[i]}: #{i}: #{construct}"
      assert_equal @construct_strings[i], obj.to_s, i
    end
  end
  
  def test_short
    obj = @plasmoap.calculate_score('MMM')
    assert_equal 0, obj.points
  end
end
