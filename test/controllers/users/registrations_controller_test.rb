# frozen_string_literal: true

require 'test_helper'

module Users
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    test 'GET sign_up renders the registration page' do
      get users_sign_up_url

      assert_response :success
    end

    test 'POST sign_up with valid params creates user and signs in' do
      assert_difference 'User.count', 1 do
        post users_sign_up_url, params: {
          user: {
            first_name: 'Jane',
            last_name: 'Doe',
            email: 'jane@example.com',
            username: 'janedoe',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      assert_redirected_to root_path
      assert_not_nil session[:user_id]
    end

    test 'POST sign_up with missing fields does not create user' do
      assert_no_difference 'User.count' do
        post users_sign_up_url, params: {
          user: {
            first_name: '',
            last_name: '',
            email: '',
            username: '',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      assert_redirected_to users_sign_up_path
    end

    test 'POST sign_up with duplicate email does not create user' do
      assert_no_difference 'User.count' do
        post users_sign_up_url, params: {
          user: {
            first_name: 'Another',
            last_name: 'Alice',
            email: users(:alice).email,
            username: 'anotheralice',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      assert_redirected_to users_sign_up_path
    end
  end
end
