# frozen_string_literal: true

module Dashboard
  class EventsController < InertiaController
    before_action :authenticate_organization!

    def index
      events = current_organization.events
                                   .left_joins(:attendances)
                                   .select('events.*, COUNT(attendances.id) AS attendees_count')
                                   .group('events.id')
                                   .order(date: :desc)

      render inertia: 'dashboard/events/index', props: {
        events: serialize_events(events)
      }
    end

    private

    def serialize_events(events)
      events.map do |event|
        event.as_json(only: %i[id title date status]).merge(
          'attendee_count' => event.attendees_count
        )
      end
    end
  end
end
