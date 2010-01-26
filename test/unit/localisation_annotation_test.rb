require 'test_helper'

class LocalisationAnnotationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "fluorescent" do
    assert_equal 1, LocalisationAnnotation.fluorescent.first(:order => 'id').id
  end
  test "epitope" do
    t = LocalisationAnnotation.epitope_tag.first(:order => 'id')
    assert t
    assert_equal 3, t.id
  end
  test "antibody" do
    t = LocalisationAnnotation.antibody.first(:order => 'id')
    assert t
    assert_equal 2, t.id
  end
end
