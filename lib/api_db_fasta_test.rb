# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'api_db_fasta'

class ApiDbFastaTest < Test::Unit::TestCase
  def test_falciparum
    fa = ApiDbFasta5p4.new.load('lib/testFiles/falciparum.fa')
    
    f = fa.next_entry
    assert f
    assert_equal 'PF08_0142', f.name
    assert_equal '(protein coding) erythrocyte membrane protein 1 (PfEMP1)', f.annotation
    assert_equal 'MAAAG', f.sequence[0..4]
    
    f = fa.next_entry
    assert f
    assert_equal 'PF08_0141', f.name
    assert_equal '(protein coding) erythrocyte membrane protein 1 (PfEMP1)', f.annotation
    assert_equal 'MGSQG', f.sequence[0..4]
    s = f.sequence
    assert_equal 'PCIKD', s[s.length-5..s.length-1]
    
    assert_nil fa.next_entry
  end
  
  #>TA15405 |||hypothetical protein|Theileria annulata|chr 02|||Manual
  #METKKKFSSPTALAVSPPKLTFHRRIARGAFGVVYLVSDDTGTQFAVKRSKKLLFHKQSI
  #IYLVIYHLSCSLVLPFYSLVT
  #>TA20245 |||hypothetical protein|Theileria annulata|chr 01|||Manual
  #MVFKIKELGYLLKPGEKFTNEEDCIDDININTKSEIYLINSKSNLINQFLFLILFLILII
  #TKIEEKLNEMELKLNDKNWIETLTIIGNTIPQNNNLTLNQQFNELANEFIKIGLNNFKVI
  #>TA14160 |||hypothetical protein|Theileria annulata|chr 02|||Manual
  #MSCGSFVAGIVQGILTSAKFVSNHIYLNYLYSYLLEGGLNTSSRVKQHPLP
  def test_theileria
    fa = TigrFasta.new.load('lib/testFiles/TANN.small.pep')
    
    f = fa.next_entry
    assert f
    assert_equal 'TA15405', f.name
    assert_equal 'hypothetical protein', f.annotation
    assert_equal 'METKK', f.sequence[0..4]
    s = f.sequence
    assert_equal 'YSLVT', s[s.length-5..s.length-1]
        
    f = fa.next_entry
    assert f
    assert_equal 'TA20245', f.name
    assert_equal 'hypothetical protein', f.annotation
    assert_equal 'MVFKI', f.sequence[0..4]
        
    f = fa.next_entry
    assert f
    assert_equal 'TA14160', f.name
    assert_equal 'hypothetical protein', f.annotation
    assert_equal 'MSCGS', f.sequence[0..4]
    s = f.sequence
    assert_equal 'QHPLP', s[s.length-5..s.length-1]
    
    assert_nil fa.next_entry
  end
  
  
  def test_cruel_cypto
    fa = ApiDbFasta5p4.new.load('lib/testFiles/crypto.cruel.fa')
    
    f = fa.next_entry
    assert f
    assert_equal 'cgd6_1490', f.name
    assert_equal 'AAEE01000002', f.scaffold
    assert_equal '(protein coding) dbj|baa86974.1, putative', f.annotation
    assert f.sequence
  end
  
  #>547.m00089 |TP05_0002|TP05_0002|ribosomal protein L4, putative|Theileria parva|chr_5|c5m547|547
  #MFSDNTIFSQLILNIKFGLTIKNKLIYCFNIFINKFLNSNKKILYDIKKNIKNNMFNFRN
  #KLNFNKSKKNIVSKKRTGKSRSGSSSSHTLRKGLLWFGLRNIKLKEKKFNKNLLNSLLID
  #NKNIITINNLEIIKFIYYITYNNNNLFKISSINTFYLNSIHNYKHLINNKKCINIVY*
  #>547.m00090 |TP05_0001|TP05_0001|ribosomal protein S4, putative|Theileria parva|chr_5|c5m547|547
  #VIYNIKKLKTLRKFNLTNIYELTTKTNIIFKKKKHIYKEYKLPTNIKILKILYDVKDKKL
  #KYSFNKFLFVNIYKFLKILKSRLDFVLFNNNLFSTINQSKQNISHKHIFLNNTIARHPSY
  #CVKNLDIIHLYNISCDQIIKKLIYNHIIRNITINKICRKTCKPILIKQIILKFDMNNLNN
  #TMCNKNFKIQINKTKTSDYYIKHKI*
  def test_annulata
    fa = TigrFasta.new.load('lib/testFiles/TPA1.small.fa')
    
    f = fa.next_entry
    assert f
    assert_equal 'TP05_0002', f.name
    assert_equal 'ribosomal protein L4, putative', f.annotation
    assert_equal 'MFSDN', f.sequence[0..4]
    s = f.sequence
    assert_equal 'NIVY*', s[s.length-5..s.length-1]
        
    f = fa.next_entry
    assert f
    assert_equal 'TP05_0001', f.name
    assert_equal 'ribosomal protein S4, putative', f.annotation
    assert_equal 'VIYNI', f.sequence[0..4]
    s = f.sequence
    assert_equal 'KHKI*', s[s.length-5..s.length-1]
    
    assert_nil fa.next_entry
  end
  
  
  def test_theileria_big
    fa = TigrFasta.new.load(File.join(ENV['HOME'],'phd/data/Theileria annulata/TANN.GeneDB.pep'))
    count = 0
    while f = fa.next_entry
      assert f.name
      assert f.sequence
      count += 1
    end
    assert_equal 3795, count
    
    fa = TigrFasta.new.load(File.join(ENV['HOME'],'phd/data/Theileria parva/TPA1.pep'))
    count = 0
    while f = fa.next_entry
      assert f.name
      assert f.sequence
      count += 1
    end
    assert_equal 4079, count
  end
  
  
  def test_apidb5p5
    fa = ApiDbFasta5p5.new
    p = fa.parse_name('psu|PF14_0043 | organism=Plasmodium_falciparum_3D7 | product=hypothetical protein | location=MAL14:154855-156918(-) | length=347')
    assert_equal 'PF14_0043', p.name
    assert_equal 'MAL14', p.scaffold
    assert_equal 'hypothetical protein', p.annotation

    # test empty product annoying one
    p = fa.parse_name('psu|PF08_tmp2 | organism=Plasmodium_falciparum_3D7 | product= | location=MAL8:100014-100175(-) | length=162')
    assert_equal 'PF08_tmp2', p.name
    assert_equal 'MAL8', p.scaffold
    assert_equal '', p.annotation
    
    fa = ApiDbFasta5p5.new.load('lib/testFiles/falciparum5.5.extract.fa')
    seq = 'MEENLMKLGTLMLLGFGEAGAKIISKNINEQERVNLLINGEIVYSVFSFCDIRNFTEITEVLKEKIMIFINLIAEIIHECCDFYGGTINKNIGDAFLLVWKYQKKEYSNKKMNMFKSPNNNYDEYSEKENINRICDLAFLSTVQTLIKLRKSEKIHIFLNNENMDELIKNNILELSFGLHFGWAIEGAIGSSYKIDLSYLSENVNIASRLQDISKIYKNNIVISGDFYDNMSEKFKVFDDIKKKAERKKRKKEVLNLSYNLYEEYAKNDDIKFIKIHYPKDYLEQFKIALESYLIGKWNESKNILEYLKRNNIFEDEILNQLWNFLSMNNFIAPSDWCGYRKFLQKS'
    assert_equal seq, fa.next_entry.sequence
  end

  def test_crypto4p0
    fa = CryptoDbFasta4p0.new
    p = fa.parse_name('gb|Chro.80234 | organism=Cryptosporidium_hominis | product=hypothetical protein | location=AAEL01000108:8398-11373(-) | length=991')
    assert_equal 'Chro.80234', p.name
    assert_equal 'AAEL01000108', p.scaffold
    assert_equal 'hypothetical protein', p.annotation
  end

  def test_vivax5p5
    fa = ApiDbFasta5p5.new
    p = fa.parse_name('gb|PVX_090835 | organism=Plasmodium_vivax_SaI-1 | product=hypothetical protein | location=CM000450:19413-20373(+) | length=961')
    assert_equal 'PVX_090835', p.name
    assert_equal 'CM000450', p.scaffold
    assert_equal 'hypothetical protein', p.annotation
  end

  def test_eupathdb2009
    fa = EuPathDb2009.new('abc_1')
    p = fa.parse_name('gb|PVX_090835 | organism=abc_1 | product=hypothetical protein | location=CM000450:19413-20373(+) | length=961')
    assert_equal 'PVX_090835', p.name
    assert_equal 'CM000450', p.scaffold
    assert_equal 'hypothetical protein', p.annotation

    assert_raise ParseException do
      fa = EuPathDb2009.new('abc_1')
      p = fa.parse_name('gbH|PVX_090835 | organism=abc_1 | product=hypothetical protein | location=CM000450:19413-20373(+) | length=961')
    end

    assert_raise ParseException do
      fa = EuPathDb2009.new('abc_1','gbI')
      p = fa.parse_name('gbH|PVX_090835 | organism=abc_1 | product=hypothetical protein | location=CM000450:19413-20373(+) | length=961')
    end

    fa = EuPathDb2009.new('abc_1','gbH')
    p = fa.parse_name('gbH|PVX_090835 | organism=abc_1 | product=hypothetical protein | location=CM000450:19413-20373(+) | length=961')
    assert_equal 'PVX_090835', p.name
    assert_equal 'CM000450', p.scaffold
    assert_equal 'hypothetical protein', p.annotation
  end
end
