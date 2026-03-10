# frozen_string_literal: true

require 'test_helper'

class AuthenticationTest < ActionDispatch::IntegrationTest
  test 'unauthenticated request succeeds with no current user or organization' do
    get root_url

    assert_response :success
  end

  test 'signed_in? is false when not authenticated' do
    get root_url

    assert_nil Current.user
    assert_nil Current.organization
  end
end

class AuthenticationConcernTest < ActiveSupport::TestCase
  class DummyController
    def self.before_action(*); end

    def self.helper_method(*); end

    include Authentication

    attr_reader :session

    def initialize
      @session = {}
    end

    def reset_session
      @session = {}
    end
  end

  setup do
    Current.reset
  end

  teardown do
    Current.reset
  end

  test 'sign_in_user clears current organization' do
    controller = DummyController.new

    Current.organization = organizations(:charity_org)

    controller.send(:sign_in_user, users(:alice))

    assert_equal users(:alice), Current.user
    assert_nil Current.organization
  end

  test 'sign_in_organization clears current user' do
    controller = DummyController.new

    Current.user = users(:alice)

    controller.send(:sign_in_organization, organizations(:charity_org))

    assert_equal organizations(:charity_org), Current.organization
    assert_nil Current.user
  end
end
