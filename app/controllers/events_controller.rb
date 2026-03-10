class EventsController < InertiaController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def show
    event = Event.includes(:organization).find(params[:id])

    raise ActiveRecord::RecordNotFound unless event.published? || Current.organization == event.organization

    render inertia: 'events/show', props: {
      event: serialize_event(event),
      organization: serialize_organization(event.organization),
      attendee_count: event.attendees.count,
      is_attending: current_user_attending?(event)
    }
  end

  private

  def serialize_event(event)
    event.as_json(only: %i[
                    id title description date start_time end_time
                    venue_name street_address city state zip
                    dress_code starting_ticket_price ticket_link
                    hashtags countdown_timer auction_items gift_items status
                  ])
  end

  def serialize_organization(org)
    org.as_json(only: %i[
                  id name slug email website donation_url
                  description primary_cause causes industries
                ])
  end

  def current_user_attending?(event)
    return false unless Current.user

    event.attendances.exists?(user: Current.user)
  end

  def render_not_found
    redirect_to root_path, alert: 'Event not found' # rubocop:disable Rails/I18nLocaleTexts
  end
end
