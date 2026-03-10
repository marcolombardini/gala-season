# frozen_string_literal: true

require 'test_helper'

class FollowsControllerTest < ActionDispatch::IntegrationTest
  test 'authenticated user can follow an organization' do
    user = users(:alice)
    org = organizations(:arts_foundation)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    assert_difference 'Follow.count', 1 do
      post organization_follow_url(slug: org.slug)
    end

    assert_response :redirect
    assert Follow.exists?(user: user, organization: org)
  end

  test 'authenticated user can unfollow an organization' do
    user = users(:alice)
    org = organizations(:charity_org)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    assert_difference 'Follow.count', -1 do
      delete organization_unfollow_url(slug: org.slug)
    end

    assert_response :redirect
    assert_not Follow.exists?(user: user, organization: org)
  end

  test 'duplicate follow is idempotent' do
    user = users(:alice)
    org = organizations(:charity_org)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    assert_no_difference 'Follow.count' do
      post organization_follow_url(slug: org.slug)
    end

    assert_response :redirect
  end

  test 'unfollow when not following does not error' do
    user = users(:alice)
    org = organizations(:arts_foundation)

    post users_sign_in_url, params: { email: user.email, password: 'password123' }

    assert_no_difference 'Follow.count' do
      delete organization_unfollow_url(slug: org.slug)
    end

    assert_response :redirect
  end

  test 'unauthenticated user is redirected on follow' do
    org = organizations(:charity_org)

    post organization_follow_url(slug: org.slug)

    assert_redirected_to root_url
  end

  test 'unauthenticated user is redirected on unfollow' do
    org = organizations(:charity_org)

    delete organization_unfollow_url(slug: org.slug)

    assert_redirected_to root_url
  end
end
