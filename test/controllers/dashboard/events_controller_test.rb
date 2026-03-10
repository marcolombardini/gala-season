# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class EventsControllerTest < ActionDispatch::IntegrationTest
    # --- index ---

    test 'redirects unauthenticated visitors to root' do
      get dashboard_events_url

      assert_redirected_to root_path
    end

    test 'redirects users to root' do
      post users_sign_in_url, params: { email: users(:alice).email, password: 'password123' }
      get dashboard_events_url

      assert_redirected_to root_path
    end

    test "shows org's events when signed in as organization" do
      sign_in_org(:charity_org)
      get dashboard_events_url
      props = inertia_props

      event_titles = props['events'].pluck('title')

      assert_includes event_titles, events(:upcoming_gala).title
      assert_includes event_titles, events(:past_gala).title
      assert_equal 2, props['events'].length
    end

    test "does not show other org's events" do
      sign_in_org(:arts_foundation)
      get dashboard_events_url
      props = inertia_props

      event_titles = props['events'].pluck('title')

      assert_includes event_titles, events(:draft_event).title
      assert_equal 1, props['events'].length
    end

    test 'shows draft events for own org' do
      sign_in_org(:arts_foundation)
      get dashboard_events_url
      props = inertia_props

      statuses = props['events'].pluck('status')

      assert_includes statuses, 'draft'
    end

    test 'includes attendee_count' do
      sign_in_org(:charity_org)
      get dashboard_events_url
      props = inertia_props

      upcoming = props['events'].find { |e| e['title'] == events(:upcoming_gala).title }

      assert_equal 2, upcoming['attendee_count']

      past = props['events'].find { |e| e['title'] == events(:past_gala).title }

      assert_equal 0, past['attendee_count']
    end

    test 'serializes correct shape' do
      sign_in_org(:charity_org)
      get dashboard_events_url
      props = inertia_props

      event = props['events'].first

      assert event.key?('id')
      assert event.key?('title')
      assert event.key?('date')
      assert event.key?('status')
      assert event.key?('attendee_count')
    end

    # --- new ---

    test 'new renders for authenticated org' do
      sign_in_org(:charity_org)
      get new_dashboard_event_url

      assert_response :success
    end

    test 'new redirects unauthenticated visitors' do
      get new_dashboard_event_url

      assert_redirected_to root_path
    end

    test 'new passes dress_codes' do
      sign_in_org(:charity_org)
      get new_dashboard_event_url
      props = inertia_props

      assert_includes props['dress_codes'], 'black_tie'
      assert_includes props['dress_codes'], 'cocktail_attire'
    end

    # --- create ---

    test 'create with valid data creates event and redirects' do
      sign_in_org(:charity_org)

      assert_difference 'Event.count', 1 do
        post dashboard_events_url, params: {
          event: { title: 'New Gala', date: 60.days.from_now.to_date.to_s, status: 'draft' }
        }
      end

      assert_redirected_to dashboard_events_path
      follow_redirect!

      assert_equal 'Event created.', flash[:success]
    end

    test 'create with invalid data redirects back with errors' do
      sign_in_org(:charity_org)

      assert_no_difference 'Event.count' do
        post dashboard_events_url, params: {
          event: { title: '', date: '' }
        }
      end

      assert_redirected_to new_dashboard_event_path
    end

    test 'create assigns event to current organization' do
      sign_in_org(:charity_org)

      post dashboard_events_url, params: {
        event: { title: 'Org Test', date: 60.days.from_now.to_date.to_s }
      }

      event = Event.find_by(title: 'Org Test')

      assert_equal organizations(:charity_org).id, event.organization_id
    end

    test 'create redirects unauthenticated visitors' do
      post dashboard_events_url, params: {
        event: { title: 'No Auth', date: 60.days.from_now.to_date.to_s }
      }

      assert_redirected_to root_path
    end

    # --- edit ---

    test 'edit renders for own event' do
      sign_in_org(:charity_org)
      get edit_dashboard_event_url(events(:upcoming_gala))
      props = inertia_props

      assert_response :success
      assert_equal events(:upcoming_gala).title, props['event']['title']
    end

    test 'edit includes dress_codes' do
      sign_in_org(:charity_org)
      get edit_dashboard_event_url(events(:upcoming_gala))
      props = inertia_props

      assert_includes props['dress_codes'], 'black_tie'
    end

    test "edit returns not found for other org's event" do
      sign_in_org(:arts_foundation)
      get edit_dashboard_event_url(events(:upcoming_gala))

      assert_response :not_found
    end

    test 'edit redirects unauthenticated visitors' do
      get edit_dashboard_event_url(events(:upcoming_gala))

      assert_redirected_to root_path
    end

    # --- update ---

    test 'update with valid data updates event and redirects' do
      sign_in_org(:charity_org)
      event = events(:upcoming_gala)

      patch dashboard_event_url(event), params: {
        event: { title: 'Updated Gala Title' }
      }

      assert_redirected_to dashboard_events_path
      assert_equal 'Updated Gala Title', event.reload.title
    end

    test 'update with invalid data redirects back with errors' do
      sign_in_org(:charity_org)
      event = events(:upcoming_gala)

      patch dashboard_event_url(event), params: {
        event: { title: '' }
      }

      assert_redirected_to edit_dashboard_event_path(event)
      assert_not_equal '', event.reload.title
    end

    test "update returns not found for other org's event" do
      sign_in_org(:arts_foundation)
      patch dashboard_event_url(events(:upcoming_gala)), params: {
        event: { title: 'Hacked' }
      }

      assert_response :not_found
      assert_not_equal 'Hacked', events(:upcoming_gala).reload.title
    end

    test 'update redirects unauthenticated visitors' do
      patch dashboard_event_url(events(:upcoming_gala)), params: {
        event: { title: 'No Auth' }
      }

      assert_redirected_to root_path
    end

    private

    def sign_in_org(fixture_name)
      post organizations_sign_in_url, params: { email: organizations(fixture_name).email, password: 'password123' }
    end

    def inertia_props
      assert_response :success
      match = response.body.match(%r{<script\b[^>]*data-page="app"[^>]*>(.+?)</script>}m)
      JSON.parse(match[1])['props']
    end
  end
end
