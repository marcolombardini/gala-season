require 'test_helper'

class FollowTest < ActiveSupport::TestCase
  test 'valid follow' do
    follow = Follow.new(user: users(:alice), organization: organizations(:arts_foundation))

    assert_predicate follow, :valid?
  end

  test 'prevents duplicate follow' do
    follow = Follow.new(user: users(:alice), organization: organizations(:charity_org))

    assert_not follow.valid?
    assert_includes follow.errors[:user_id], 'has already been taken'
  end
end
