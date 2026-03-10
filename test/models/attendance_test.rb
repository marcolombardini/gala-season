require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
  test 'valid attendance' do
    attendance = Attendance.new(user: users(:alice), event: events(:past_gala))

    assert_predicate attendance, :valid?
  end

  test 'prevents duplicate attendance' do
    attendance = Attendance.new(user: users(:alice), event: events(:upcoming_gala))

    assert_not attendance.valid?
    assert_includes attendance.errors[:user_id], 'has already been taken'
  end
end
