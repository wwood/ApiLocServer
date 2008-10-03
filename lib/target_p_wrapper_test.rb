# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'target_p_wrapper'

class TargetPWrapperTest < Test::Unit::TestCase
  def test_me
    wrap = TargetPWrapper.new
    assert wrap
    
    # ben@uyen:~/bioinfo/targetp-1.1$ ./targetp ~/bin/testFiles/abc.fa 
 
    ### targetp v1.1 prediction results ##################################
    #Number of query sequences:  1
    #Cleavage site predictions not included.
    #Using NON-PLANT networks.
    #
    #Name                  Len            mTP     SP  other  Loc  RC
    #----------------------------------------------------------------------
    #abc                     3          0.057  0.030  0.976   _    1
    #----------------------------------------------------------------------
    #cutoff                             0.000  0.000  0.000
    seq = 'ATG'
    assert t = wrap.targetp(seq)
    assert_kind_of Bio::TargetP::Report, t
    #    p t
    #    assert_equal ['wrapperSeq'], t.query_sequences #white box testing
    assert_equal 'NON-PLANT', t.networks
    assert t.cutoff
    assert_equal 0.057, t.pred['mTP']
    assert_equal 0.03, t.pred['SP']
    assert_equal 0.976, t.pred['other']
  end
  
  def test_real
    seq = 'ASQKRPSQRHGSKYLATASTMDHARHGFLPRHRDTGILDSIGRFFGGDRGAPK
NMYKDSHHPARTAHYGSLPQKSHGRTQDENPVVHFFKNIVTPRTPPPSQGKGR
KSAHKGFKGVDAQGTLSKIFKLGGRDSRSGSPMARRELVISLIVES'
    wrap = TargetPWrapper.new
    assert wrap
    
    # ben@uyen:~/bioinfo/targetp-1.1$ ./targetp ~/bin/testFiles/abc.fa 
 
 
    ### targetp v1.1 prediction results ##################################
    #Number of query sequences:  1
    #Cleavage site predictions not included.
    #Using NON-PLANT networks.
    #
    #Name                  Len            mTP     SP  other  Loc  RC
    #----------------------------------------------------------------------
    #seq2                  152          0.775  0.032  0.325   M    3
    #----------------------------------------------------------------------
    #cutoff                             0.000  0.000  0.000

    assert t = wrap.targetp(seq)
    assert_kind_of Bio::TargetP::Report, t
    assert_equal 'M', t.prediction['Loc']
  end
  
  
  def test_plant
    wrap = TargetPWrapper.new
    wrap.set_plant
    
    # ### targetp v1.1 prediction results ##################################
    #Number of query sequences:  1
    #Cleavage site predictions not included.
    #Using PLANT networks.
    #
    #Name                  Len     cTP    mTP     SP  other  Loc  RC
    #----------------------------------------------------------------------
    #abc                     3   0.120  0.106  0.119  0.942   _    1
    #----------------------------------------------------------------------
    #cutoff                      0.000  0.000  0.000  0.000

    seq = 'ATG'
    assert t = wrap.targetp(seq)
    assert_kind_of Bio::TargetP::Report, t
    #    p t
    #    assert_equal ['wrapperSeq'], t.query_sequences #white box testing
    assert_equal 'PLANT', t.networks
    assert t.cutoff
    assert_equal 0.106, t.pred['mTP']
    assert_equal 0.119, t.pred['SP']
    assert_equal 0.942, t.pred['other']
    assert_equal 0.12, t.pred['cTP']
    assert_equal '_', t.pred['Loc']
  end
end
