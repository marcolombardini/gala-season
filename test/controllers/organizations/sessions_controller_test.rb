# frozen_string_literal: true

require 'test_helper'

module Organizations
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    test 'GET sign_in renders the sign in page' do
      get organizations_sign_in_url

      assert_response :success
    end

    test 'POST sign_in with valid credentials signs in and redirects' do
      post organizations_sign_in_url, params: { email: organizations(:charity_org).email, password: 'password123' }

      assert_redirected_to root_path
      assert_equal organizations(:charity_org).id, session[:organization_id]
    end

    test 'POST sign_in with wrong password redirects back with error' do
      post organizations_sign_in_url, params: { email: organizations(:charity_org).email, password: 'wrongpassword' }

      assert_redirected_to organizations_sign_in_path
      assert_nil session[:organization_id]
    end

    test 'POST sign_in with nonexistent email redirects back with error' do
      post organizations_sign_in_url, params: { email: 'nobody@example.com', password: 'password123' }

      assert_redirected_to organizations_sign_in_path
      assert_nil session[:organization_id]
    end

    test 'DELETE sign_out clears session and redirects' do
      post organizations_sign_in_url, params: { email: organizations(:charity_org).email, password: 'password123' }

      assert_equal organizations(:charity_org).id, session[:organization_id]

      delete organizations_sign_out_url

      assert_redirected_to root_path
      assert_nil session[:organization_id]
    end
  end
end
