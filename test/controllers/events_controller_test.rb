require 'test_helper'

class EventsControllerTest < ActionDispatch::IntegrationTest
  test 'published event returns 200 with correct data' do
    event = events(:upcoming_gala)
    get event_url(event)

    assert_response :success
    props = inertia_props

    assert_equal event.title, props['event']['title']
    assert_equal event.organization.name, props['organization']['name']
    assert_equal event.organization.slug, props['organization']['slug']
    assert_equal event.description, props['event']['description']
  end

  test 'serializes full event fields' do
    get event_url(events(:upcoming_gala))
    event_data = inertia_props['event']

    %w[id title description date start_time end_time venue_name street_address
       city state zip dress_code starting_ticket_price ticket_link
       hashtags countdown_timer auction_items gift_items status].each do |field|
      assert event_data.key?(field), "Missing field: #{field}"
    end
  end

  test 'serializes organization with expanded fields' do
    get event_url(events(:upcoming_gala))
    org_data = inertia_props['organization']

    %w[id name slug email description primary_cause causes industries].each do |field|
      assert org_data.key?(field), "Missing field: #{field}"
    end
  end

  test 'draft event redirects for anonymous visitor' do
    get event_url(events(:draft_event))

    assert_redirected_to root_url
  end

  test 'draft event redirects for different organization' do
    post organizations_sign_in_url, params: { email: organizations(:charity_org).email, password: 'password123' }
    get event_url(events(:draft_event))

    assert_redirected_to root_url
  end

  test 'draft event returns 200 for owning organization' do
    post organizations_sign_in_url, params: { email: organizations(:arts_foundation).email, password: 'password123' }
    get event_url(events(:draft_event))

    assert_response :success
    assert_equal 'Art Auction Night', inertia_props['event']['title']
  end

  test 'includes correct attendee_count' do
    get event_url(events(:upcoming_gala))

    assert_equal 2, inertia_props['attendee_count']
  end

  test 'is_attending true for authenticated attending user' do
    post users_sign_in_url, params: { email: users(:alice).email, password: 'password123' }
    get event_url(events(:upcoming_gala))

    assert inertia_props['is_attending']
  end

  test 'is_attending false when not signed in' do
    get event_url(events(:upcoming_gala))

    assert_not inertia_props['is_attending']
  end

  test 'non-existent event redirects' do
    get '/events/00000000-0000-0000-0000-000000000000'

    assert_redirected_to root_url
  end

  private

  def inertia_props
    assert_response :success
    match = response.body.match(%r{<script\b[^>]*data-page="app"[^>]*>(.+?)</script>}m)
    JSON.parse(match[1])['props']
  end
end
