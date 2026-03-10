require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test 'returns published upcoming events' do
    get root_url

    assert_response :success
    events = inertia_props['events']
    event_titles = events.pluck('title')

    assert_includes event_titles, events(:upcoming_gala).title
    assert_not_includes event_titles, events(:past_gala).title
    assert_not_includes event_titles, events(:draft_event).title
  end

  test 'excludes draft events' do
    get root_url
    events = inertia_props['events']
    statuses = events.pluck('status')

    assert(statuses.all?('published'))
  end

  test 'excludes past events' do
    get root_url
    events = inertia_props['events']
    dates = events.map { |e| Date.parse(e['date']) }

    assert(dates.all? { |d| d >= Date.current })
  end

  test 'serializes events as EventListItem shape' do
    get root_url
    event = inertia_props['events'].first

    assert event.key?('id')
    assert event.key?('title')
    assert event.key?('date')
    assert event.key?('venue_name')
    assert event.key?('city')
    assert event.key?('state')
    assert event.key?('starting_ticket_price')
    assert event.key?('dress_code')
    assert event.key?('status')
    assert event.key?('organization')
    assert event['organization'].key?('name')
    assert event['organization'].key?('slug')
  end

  test 'filters by name' do
    get root_url, params: { q: 'Spring' }
    events = inertia_props['events']

    assert_equal 1, events.length
    assert_equal 'Spring Charity Gala', events.first['title']
  end

  test 'filters by city' do
    get root_url, params: { city: 'Nashville' }
    events = inertia_props['events']

    assert(events.all? { |e| e['city']&.include?('Nashville') })
  end

  test 'filters by state' do
    get root_url, params: { state: 'TN' }
    events = inertia_props['events']

    assert(events.all? { |e| e['state'] == 'TN' })
  end

  test 'filters by month' do
    target_month = 30.days.from_now.month
    get root_url, params: { month: target_month }
    events = inertia_props['events']

    assert(events.all? { |e| Date.parse(e['date']).month == target_month })
  end

  test 'filters by price range' do
    get root_url, params: { price_min: 100, price_max: 200 }
    events = inertia_props['events']

    assert(events.all? do |e|
      price = e['starting_ticket_price'].to_f
      price.between?(100, 200)
    end)
  end

  test 'filters by cause' do
    get root_url, params: { cause: 'Education' }
    events = inertia_props['events']
    event_titles = events.pluck('title')

    assert_includes event_titles, 'Spring Charity Gala'
  end

  test 'filters by industry' do
    get root_url, params: { industry: 'Nonprofit' }
    events = inertia_props['events']
    event_titles = events.pluck('title')

    assert_includes event_titles, 'Spring Charity Gala'
  end

  test 'returns no events for non-matching filter' do
    get root_url, params: { q: 'Nonexistent Event XYZ' }
    events = inertia_props['events']

    assert_empty events
  end

  test 'passes filter params back to frontend' do
    get root_url, params: { q: 'Spring', city: 'Nashville' }
    filters = inertia_props['filters']

    assert_equal 'Spring', filters['q']
    assert_equal 'Nashville', filters['city']
  end

  test 'returns causes list' do
    get root_url
    causes = inertia_props['causes']

    assert_includes causes, 'Education'
    assert_includes causes, 'Health'
    assert_includes causes, 'Arts & Culture'
  end

  test 'returns industries list' do
    get root_url
    industries = inertia_props['industries']

    assert_includes industries, 'Nonprofit'
    assert_includes industries, 'Healthcare'
    assert_includes industries, 'Entertainment'
  end

  private

  def inertia_props
    assert_response :success
    match = response.body.match(%r{<script\b[^>]*data-page="app"[^>]*>(.+?)</script>}m)
    JSON.parse(match[1])['props']
  end
end
