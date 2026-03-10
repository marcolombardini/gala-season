# frozen_string_literal: true

require 'test_helper'

module Organizations
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    test 'GET sign_up renders the registration page' do
      get organizations_sign_up_url

      assert_response :success
    end

    test 'POST sign_up with valid params creates organization and signs in' do
      assert_difference 'Organization.count', 1 do
        post organizations_sign_up_url, params: {
          organization: {
            name: 'New Charity',
            email: 'newcharity@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      assert_redirected_to root_path
      assert_not_nil session[:organization_id]
    end

    test 'POST sign_up with missing fields does not create organization' do
      assert_no_difference 'Organization.count' do
        post organizations_sign_up_url, params: {
          organization: {
            name: '',
            email: '',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      assert_redirected_to organizations_sign_up_path
    end

    test 'POST sign_up with duplicate email does not create organization' do
      assert_no_difference 'Organization.count' do
        post organizations_sign_up_url, params: {
          organization: {
            name: 'Another Charity',
            email: organizations(:charity_org).email,
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end

      assert_redirected_to organizations_sign_up_path
    end
  end
end
