require 'test_helper'

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test 'valid username returns 200 with correct user data' do
    user = users(:alice)
    get user_profile_url(username: user.username)

    assert_response :success
    props = inertia_props

    assert_equal user.username, props['user']['username']
    assert_equal user.bio, props['user']['bio']
  end

  test 'serializes all expected user fields' do
    get user_profile_url(username: users(:alice).username)
    user_data = inertia_props['user']

    %w[id username bio city state first_name last_name email
       social_x social_linkedin social_instagram social_facebook
       interested_causes interested_industries].each do |field|
      assert user_data.key?(field), "Missing field: #{field}"
    end
  end

  test 'visibility false returns 404' do
    user = users(:alice)
    user.update(visibility: false)

    get "/u/#{user.username}"

    assert_redirected_to root_url
  end

  test 'visibility_full_name false hides name' do
    get user_profile_url(username: users(:bob).username)
    user_data = inertia_props['user']

    assert_nil user_data['first_name']
    assert_nil user_data['last_name']
  end

  test 'visibility_full_name true shows name' do
    get user_profile_url(username: users(:alice).username)
    user_data = inertia_props['user']

    assert_equal 'Alice', user_data['first_name']
    assert_equal 'Johnson', user_data['last_name']
  end

  test 'visibility_email false hides email' do
    get user_profile_url(username: users(:bob).username)
    user_data = inertia_props['user']

    assert_nil user_data['email']
  end

  test 'normalizes social handles into profile URLs' do
    user = users(:alice)
    user.update!(
      social_x: '@alicej',
      social_linkedin: 'alice-johnson',
      social_instagram: '@alicegram',
      social_facebook: 'alice.fb'
    )

    get user_profile_url(username: user.username)
    user_data = inertia_props['user']

    assert_equal 'https://x.com/alicej', user_data['social_x']
    assert_equal 'https://www.linkedin.com/in/alice-johnson', user_data['social_linkedin']
    assert_equal 'https://www.instagram.com/alicegram', user_data['social_instagram']
    assert_equal 'https://www.facebook.com/alice.fb', user_data['social_facebook']
  end

  test 'preserves full social urls' do
    user = users(:alice)
    user.update!(
      social_x: 'https://x.com/alicej',
      social_linkedin: 'https://linkedin.com/in/alice-johnson'
    )

    get user_profile_url(username: user.username)
    user_data = inertia_props['user']

    assert_equal 'https://x.com/alicej', user_data['social_x']
    assert_equal 'https://linkedin.com/in/alice-johnson', user_data['social_linkedin']
  end

  test 'includes followed organizations' do
    get user_profile_url(username: users(:alice).username)
    orgs = inertia_props['followed_organizations']

    assert_kind_of Array, orgs
    assert_operator orgs.length, :>=, 1
    assert orgs.first.key?('name')
    assert orgs.first.key?('slug')
  end

  test 'includes only published attended events' do
    get user_profile_url(username: users(:alice).username)
    events = inertia_props['attended_events']

    events.each do |event|
      assert_equal 'published', event['status']
    end
  end

  test 'non-existent username redirects to root' do
    get '/u/does-not-exist'

    assert_redirected_to root_url
  end

  private

  def inertia_props
    assert_response :success
    match = response.body.match(%r{<script\b[^>]*data-page="app"[^>]*>(.+?)</script>}m)
    JSON.parse(match[1])['props']
  end
end
