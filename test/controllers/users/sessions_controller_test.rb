# frozen_string_literal: true

require 'test_helper'

module Users
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    test 'GET sign_in renders the sign in page' do
      get users_sign_in_url

      assert_response :success
    end

    test 'POST sign_in with valid credentials signs in and redirects' do
      post users_sign_in_url, params: { email: users(:alice).email, password: 'password123' }

      assert_redirected_to root_path
      assert_equal users(:alice).id, session[:user_id]
    end

    test 'POST sign_in with wrong password redirects back with error' do
      post users_sign_in_url, params: { email: users(:alice).email, password: 'wrongpassword' }

      assert_redirected_to users_sign_in_path
      assert_nil session[:user_id]
    end

    test 'POST sign_in with nonexistent email redirects back with error' do
      post users_sign_in_url, params: { email: 'nobody@example.com', password: 'password123' }

      assert_redirected_to users_sign_in_path
      assert_nil session[:user_id]
    end

    test 'DELETE sign_out clears session and redirects' do
      post users_sign_in_url, params: { email: users(:alice).email, password: 'password123' }

      assert_equal users(:alice).id, session[:user_id]

      delete users_sign_out_url

      assert_redirected_to root_path
      assert_nil session[:user_id]
    end
  end
end
