# frozen_string_literal: true

require 'test_helper'

class AttendancesControllerTest < ActionDispatch::IntegrationTest
  test 'authenticated user can attend an event' do
    user = users(:bob)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    # Bob already attends via fixture, use a different event
    event_for_attend = events(:past_gala)
    assert_difference 'Attendance.count', 1 do
      post event_attend_url(event_id: event_for_attend.id)
    end

    assert_response :redirect
    assert Attendance.exists?(user: user, event: event_for_attend)
  end

  test 'authenticated user can unattend an event' do
    user = users(:alice)
    event = events(:upcoming_gala)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    assert_difference 'Attendance.count', -1 do
      delete event_unattend_url(event_id: event.id)
    end

    assert_response :redirect
    assert_not Attendance.exists?(user: user, event: event)
  end

  test 'duplicate attend is idempotent' do
    user = users(:alice)
    event = events(:upcoming_gala)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    assert_no_difference 'Attendance.count' do
      post event_attend_url(event_id: event.id)
    end

    assert_response :redirect
  end

  test 'authenticated user cannot attend a draft event' do
    user = users(:alice)
    event = events(:draft_event)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    assert_no_difference 'Attendance.count' do
      post event_attend_url(event_id: event.id)
    end

    assert_redirected_to root_url
    assert_not Attendance.exists?(user: user, event: event)
  end

  test 'unattend when not attending does not error' do
    user = users(:alice)
    event = events(:past_gala)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    assert_no_difference 'Attendance.count' do
      delete event_unattend_url(event_id: event.id)
    end

    assert_response :redirect
  end

  test 'authenticated user cannot unattend a draft event' do
    user = users(:alice)
    event = events(:draft_event)
    Attendance.create!(user: user, event: event)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    assert_no_difference 'Attendance.count' do
      delete event_unattend_url(event_id: event.id)
    end

    assert_redirected_to root_url
    assert Attendance.exists?(user: user, event: event)
  end

  test 'unauthenticated user is redirected on attend' do
    event = events(:upcoming_gala)

    post event_attend_url(event_id: event.id)

    assert_redirected_to root_url
  end

  test 'unauthenticated user is redirected on unattend' do
    event = events(:upcoming_gala)

    delete event_unattend_url(event_id: event.id)

    assert_redirected_to root_url
  end
end
