require 'test_helper'

class OrganizationProfilesControllerTest < ActionDispatch::IntegrationTest
  test 'valid slug returns 200 with correct org data' do
    org = organizations(:charity_org)
    get organization_profile_url(slug: org.slug)

    assert_response :success
    props = inertia_props

    assert_equal org.name, props['organization']['name']
    assert_equal org.slug, props['organization']['slug']
    assert_equal org.description, props['organization']['description']
  end

  test 'serializes all expected organization fields' do
    get organization_profile_url(slug: organizations(:charity_org).slug)
    org_data = inertia_props['organization']

    %w[id name slug email phone website donation_url description
       primary_cause causes industries].each do |field|
      assert org_data.key?(field), "Missing field: #{field}"
    end
  end

  test 'returns published events only' do
    get organization_profile_url(slug: organizations(:charity_org).slug)
    events = inertia_props['events']

    events.each do |event|
      assert_equal 'published', event['status']
    end
  end

  test 'excludes draft events' do
    get organization_profile_url(slug: organizations(:arts_foundation).slug)
    events = inertia_props['events']

    assert_empty events
  end

  test 'returns correct follower_count' do
    get organization_profile_url(slug: organizations(:charity_org).slug)

    assert_equal 1, inertia_props['follower_count']
  end

  test 'is_following true for authenticated following user' do
    post users_sign_in_url, params: { email: users(:alice).email, password: 'password123' }
    get organization_profile_url(slug: organizations(:charity_org).slug)

    assert inertia_props['is_following']
  end

  test 'is_following false when not signed in' do
    get organization_profile_url(slug: organizations(:charity_org).slug)

    assert_not inertia_props['is_following']
  end

  test 'non-existent slug redirects to root' do
    get '/o/does-not-exist'

    assert_redirected_to root_url
  end

  private

  def inertia_props
    assert_response :success
    match = response.body.match(%r{<script\b[^>]*data-page="app"[^>]*>(.+?)</script>}m)
    JSON.parse(match[1])['props']
  end
end
