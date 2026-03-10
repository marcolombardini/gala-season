class HomeController < InertiaController
  def index
    render inertia: 'home/index', props: {
      events: serialize_events(filtered_events),
      filters: filter_params,
      causes: Organization.pluck(:causes).flatten.uniq.sort,
      industries: Organization.pluck(:industries).flatten.uniq.sort
    }
  end

  private

  def filtered_events
    events = Event.published.upcoming.includes(:organization).order(date: :asc)
    events = apply_text_filters(events)
    events = apply_location_filters(events)
    events = apply_date_and_price_filters(events)
    apply_organization_filters(events)
  end

  def apply_text_filters(events)
    events = events.where('events.title ILIKE ?', "%#{params[:q]}%") if params[:q].present?
    events
  end

  def apply_location_filters(events)
    events = events.where('events.city ILIKE ?', "%#{params[:city]}%") if params[:city].present?
    events = events.where(state: params[:state]) if params[:state].present?
    events
  end

  def apply_date_and_price_filters(events)
    events = apply_month_filter(events)
    events = events.where(starting_ticket_price: params[:price_min].to_f..) if params[:price_min].present?
    events = events.where(starting_ticket_price: ..params[:price_max].to_f) if params[:price_max].present?
    events
  end

  def apply_month_filter(events)
    return events if params[:month].blank?

    events.where('EXTRACT(MONTH FROM events.date) = ?', params[:month].to_i)
  end

  def apply_organization_filters(events)
    if params[:cause].present?
      events = events.joins(:organization).where('? = ANY(organizations.causes)',
                                                 params[:cause])
    end
    if params[:industry].present?
      events = events.joins(:organization).where('? = ANY(organizations.industries)',
                                                 params[:industry])
    end
    events
  end

  def serialize_events(events)
    events.map do |event|
      event.as_json(
        only: %i[id title date venue_name city state starting_ticket_price dress_code status]
      ).merge(
        'organization' => event.organization.as_json(only: %i[name slug])
      )
    end
  end

  def filter_params
    params.slice(:q, :cause, :city, :state, :month, :price_min, :price_max, :industry).permit!.to_h
  end
end
