class OrganizationProfilesController < InertiaController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def show
    organization = Organization.find_by!(slug: params[:slug])

    render inertia: 'organization_profiles/show', props: {
      organization: serialize_organization(organization),
      events: serialize_events(organization.events.published.upcoming.order(date: :asc)),
      follower_count: organization.followers.count,
      is_following: current_user_following?(organization)
    }
  end

  private

  def serialize_organization(org)
    org.as_json(only: %i[
                  id name slug email phone website donation_url
                  description primary_cause causes industries
                ])
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

  def current_user_following?(organization)
    return false unless Current.user

    Current.user.follows.exists?(organization: organization)
  end

  def render_not_found
    redirect_to root_path, alert: 'Organization not found' # rubocop:disable Rails/I18nLocaleTexts
  end
end
