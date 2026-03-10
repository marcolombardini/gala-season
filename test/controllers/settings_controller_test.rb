# frozen_string_literal: true

require 'test_helper'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  test 'unauthenticated user is redirected' do
    get settings_url

    assert_redirected_to root_url
  end

  test 'authenticated user sees settings page' do
    sign_in users(:alice)
    get settings_url

    assert_response :success
    user_data = inertia_props['user']

    assert_equal 'Alice', user_data['first_name']
    assert_equal 'alice@example.com', user_data['email']
  end

  test 'update basic info' do
    sign_in users(:alice)
    patch settings_url,
          params: { user: { first_name: 'Alicia', last_name: 'Jones', email: 'alicia@example.com',
                            username: 'aliciaj' } }

    assert_redirected_to settings_url
    users(:alice).reload

    assert_equal 'Alicia', users(:alice).first_name
    assert_equal 'aliciaj', users(:alice).username
  end

  test 'update profile fields' do
    sign_in users(:alice)
    patch settings_url, params: { user: { bio: 'New bio', city: 'Austin', state: 'TX' } }

    assert_redirected_to settings_url
    users(:alice).reload

    assert_equal 'New bio', users(:alice).bio
    assert_equal 'Austin', users(:alice).city
  end

  test 'update interests' do
    sign_in users(:alice)
    patch settings_url,
          params: { user: { interested_causes: %w[Health Environment], interested_industries: ['Technology'] } }

    assert_redirected_to settings_url
    users(:alice).reload

    assert_equal %w[Health Environment], users(:alice).interested_causes
    assert_equal ['Technology'], users(:alice).interested_industries
  end

  test 'update visibility settings' do
    sign_in users(:alice)
    patch settings_url, params: { user: { visibility: false, visibility_email: true } }

    assert_redirected_to settings_url
    users(:alice).reload

    assert_not users(:alice).visibility
    assert users(:alice).visibility_email
  end

  test 'update password' do
    sign_in users(:alice)
    patch settings_url, params: { user: { password: 'newpassword123', password_confirmation: 'newpassword123' } }

    assert_redirected_to settings_url
    assert users(:alice).reload.authenticate('newpassword123')
  end

  test 'blank password is ignored' do
    sign_in users(:alice)
    patch settings_url, params: { user: { bio: 'Updated bio', password: '', password_confirmation: '' } }

    assert_redirected_to settings_url
    users(:alice).reload

    assert_equal 'Updated bio', users(:alice).bio
    assert users(:alice).authenticate('password123')
  end

  test 'invalid update returns errors' do
    sign_in users(:alice)
    patch settings_url, params: { user: { first_name: '' } }

    assert_response :redirect
  end

  private

  def sign_in(user)
    post users_sign_in_url, params: { email: user.email, password: 'password123' }
  end

  def inertia_props
    assert_response :success
    match = response.body.match(%r{<script\b[^>]*data-page="app"[^>]*>(.+?)</script>}m)
    JSON.parse(match[1])['props']
  end
end
