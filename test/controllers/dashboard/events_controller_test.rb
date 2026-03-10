# frozen_string_literal: true

require 'test_helper'

module Dashboard
  class EventsControllerTest < ActionDispatch::IntegrationTest
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
