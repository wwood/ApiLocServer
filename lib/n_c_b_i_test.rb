$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'n_c_b_i'

class NCBITest < Test::Unit::TestCase
  def test_segmasker_wrapper
    # Example Output. First 2 lines are input, the rest is output
    # $ segmasker 
    #>dummy
    #MVSFSKNKVLSAAVFASVLLLDNNNSAFNNNLCSKNAKGLNLNKRLLHETQAHVDDAHHAHHVADAHHAHHV
    #>dummy
    #8 - 20
    #18 - 31
    #51 - 71
    output = Bio::SegmaskerWrapper.new.calculate('MVSFSKNKVLSAAVFASVLLLDNNNSAFNNNLCSKNAKGLNLNKRLLHETQAHVDDAHHAHHVADAHHAHHV')
    assert_equal 3, output.masked_segments.length
    assert_equal 20, output.masked_segments[0].stop
  end
  
  def test_lengths
    seg = Bio::SegmaskerSegment.new(2,5)
    assert_equal 4, seg.length
    
    protein = Bio::SegmaskerResult.new
    protein.masked_segments = [seg]
    assert_equal 4, protein.total_masked_length
    assert_equal 3.5, protein.median_masked_residue
    assert_equal [2,3,4,5], protein.residues
    
    protein.masked_segments = [seg, Bio::SegmaskerSegment.new(5,6)]
    assert_equal 6, protein.total_masked_length
    assert_equal 4.5, protein.median_masked_residue
    assert_equal [2,3,4,5,5,6], protein.residues
  end
end
