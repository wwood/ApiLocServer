require 'test_helper'

class UserCommentTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "max_validation" do
    assert_equal 2, UserComment.create!(
      :coding_region_id => 1,
      :title => 'a real dummy',
      :comment => 'dummy you'
    ).number
    
    assert_equal 1, UserComment.create!(
      :coding_region_id => 10089090, #a new coding_region_id
      :title => 'a real dummy',
      :comment => 'dummy you'
    ).number
  end
end
