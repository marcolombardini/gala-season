# frozen_string_literal: true

module Dashboard
  class EventsController < InertiaController
    before_action :authenticate_organization!
    before_action :set_event, only: %i[edit update]

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

    def new
      render inertia: 'dashboard/events/new', props: {
        dress_codes: Event.dress_codes.keys
      }
    end

    def edit
      render inertia: 'dashboard/events/edit', props: {
        event: serialize_event(@event),
        dress_codes: Event.dress_codes.keys
      }
    end

    def create
      event = current_organization.events.build(event_params)

      if event.save
        redirect_to dashboard_events_path, flash: { success: 'Event created.' }
      else
        redirect_to new_dashboard_event_path, inertia: { errors: event.errors.to_hash(true) }
      end
    end

    def update
      if @event.update(event_params)
        redirect_to dashboard_events_path, flash: { success: 'Event updated.' }
      else
        redirect_to edit_dashboard_event_path(@event), inertia: { errors: @event.errors.to_hash(true) }
      end
    end

    private

    def set_event
      @event = current_organization.events.find(params[:id])
    end

    def event_params
      params.expect(event: [
                      :title, :description, :date, :start_time, :end_time,
                      :venue_name, :street_address, :city, :state, :zip,
                      :dress_code, :starting_ticket_price, :ticket_link,
                      :countdown_timer, :auction_items, :gift_items, :status,
                      { hashtags: [] }
                    ])
    end

    def serialize_events(events)
      events.map do |event|
        event.as_json(only: %i[id title date status]).merge(
          'attendee_count' => event.attendees_count
        )
      end
    end

    def serialize_event(event)
      event.as_json(only: %i[
                      id title description date start_time end_time
                      venue_name street_address city state zip
                      dress_code starting_ticket_price ticket_link
                      hashtags countdown_timer auction_items gift_items status
                    ])
    end
  end
end
