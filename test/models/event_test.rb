require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test 'valid event' do
    event = Event.new(title: 'Test Gala', date: 30.days.from_now, organization: organizations(:charity_org))

    assert_predicate event, :valid?
  end

  test 'requires title' do
    event = Event.new(date: 30.days.from_now, organization: organizations(:charity_org))

    assert_not event.valid?
    assert_includes event.errors[:title], "can't be blank"
  end

  test 'requires date' do
    event = Event.new(title: 'Test Gala', organization: organizations(:charity_org))

    assert_not event.valid?
    assert_includes event.errors[:date], "can't be blank"
  end

  test 'belongs to organization' do
    event = events(:upcoming_gala)

    assert_equal organizations(:charity_org), event.organization
  end

  test 'has many attendees through attendances' do
    event = events(:upcoming_gala)

    assert_includes event.attendees, users(:alice)
    assert_includes event.attendees, users(:bob)
  end

  test 'dress_code enum' do
    event = events(:upcoming_gala)

    assert_predicate event, :black_tie?
    event.cocktail_attire!

    assert_predicate event, :cocktail_attire?
  end

  test 'status enum' do
    assert_predicate events(:upcoming_gala), :published?
    assert_predicate events(:draft_event), :draft?
  end

  test 'published scope' do
    published = Event.published

    assert_includes published, events(:upcoming_gala)
    assert_includes published, events(:past_gala)
    assert_not_includes published, events(:draft_event)
  end

  test 'upcoming scope' do
    upcoming = Event.upcoming

    assert_includes upcoming, events(:upcoming_gala)
    assert_includes upcoming, events(:draft_event)
    assert_not_includes upcoming, events(:past_gala)
  end

  test 'defaults to draft status' do
    event = Event.new

    assert_predicate event, :draft?
  end
end
