# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'pats'

class PatsTest < Test::Unit::TestCase
  def setup
    @pats = Bio::Pats::Report.new
  end
  def test_simple
    input = 'Neural network output is in [0,1] :
values close to 1 --> likely apicoplast-targeted
values close to 0 --> unlikely apicoplast-targeted

**************************************************

>PF
MKGKMNMCLFFFYSILYVVLCTYvlgiseeylkerp
qglnvetnnnnnnnnnnnsnsndamsfvnevirfie
nekddkedkkvkiisrpventlhrypvss
apicoplast candidate: 0.813 --> YES'
    
    @pats.parse(input)
    r = Bio::Pats::Result.new
    r.score = 0.813
    r.prediction = true
    hash = Hash.new
    hash['PF'] = r
    assert_equal ['PF'], @pats.predictions.keys
    assert @pats.predictions['PF'].prediction
    assert_equal 0.813, @pats.predictions['PF'].score
  end
  
  def test_multiple
    input = '>PFA0445w|gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis|hypothetical protein, conserved
MLKITCVGLFFYIIKSLFVNTKApetslekitefrq
qhrktldgrlcaaaflhddqtytncttslspdgtsg
rewcyvevqllgkgsrdwdycrdsinydk
apicoplast candidate: 0.702 --> YES

>PFA0590w|parasite plasma membrane during schizont, parasite plasma membrane during schizont, parasite plasma membrane during schizont, parasite plasma membrane during schizont, parasite plasma membrane during schizont, parasite plasma membrane during schizont|ABC transporter(CT family), PfMRP
MTTYKENVGISNKGNKKKKSCQNisflnflsfdwir
plindlikgdiqelpnicrnfdvpyyaskleenlrd
ievedsefyseknssnehvlhhcnsndas
apicoplast candidate: 0.021 --> NO'
    
    @pats.parse(input)
    name = 'PFA0445w|gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis, gametocyte surface during gametocytogenesis|hypothetical protein, conserved'
    r = Bio::Pats::Result.new
    r.score = 0.702
    r.prediction = true
    hash = Hash.new
    hash[name] = r
    assert_equal 2, @pats.predictions.length
    assert @pats.predictions[name]
    assert_equal r.prediction, @pats.predictions[name].prediction
    assert_equal r.score, @pats.predictions[name].score
    
    name = 'PFA0590w|parasite plasma membrane during schizont, parasite plasma membrane during schizont, parasite plasma membrane during schizont, parasite plasma membrane during schizont, parasite plasma membrane during schizont, parasite plasma membrane during schizont|ABC transporter(CT family), PfMRP'
    r = Bio::Pats::Result.new
    r.score = 0.021
    r.prediction = false
    hash = Hash.new
    hash[name] = r
    assert @pats.predictions[name]
    assert_equal r.prediction, @pats.predictions[name].prediction
    assert_equal r.score, @pats.predictions[name].score
  end
end
