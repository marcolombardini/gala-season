class ProfilesController < InertiaController
  SOCIAL_BASE_URLS = {
    'social_x' => 'https://x.com/',
    'social_linkedin' => 'https://www.linkedin.com/in/',
    'social_instagram' => 'https://www.instagram.com/',
    'social_facebook' => 'https://www.facebook.com/'
  }.freeze

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def show
    user = User.find_by!(username: params[:username])
    raise ActiveRecord::RecordNotFound unless user.visibility?

    render inertia: 'profiles/show', props: {
      user: serialize_user(user),
      followed_organizations: serialize_followed_organizations(user),
      attended_events: serialize_events(user.attended_events.published.upcoming.order(date: :asc))
    }
  end

  private

  def serialize_user(user)
    user.as_json(only: %i[
                   id username bio city state
                   social_x social_linkedin social_instagram social_facebook
                   interested_causes interested_industries
                 ]).merge(
                   visible_name_fields(user),
                   'email' => user.visibility_email? ? user.email : nil
                 ).tap do |data|
                   normalize_social_links!(data)
                 end
  end

  def visible_name_fields(user)
    return { 'first_name' => nil, 'last_name' => nil } unless user.visibility_full_name?

    { 'first_name' => user.first_name, 'last_name' => user.last_name }
  end

  def normalize_social_links!(data)
    SOCIAL_BASE_URLS.each do |field, base_url|
      data[field] = social_url(base_url, data[field])
    end
  end

  def serialize_followed_organizations(user)
    user.followed_organizations.map do |org|
      org.as_json(only: %i[id name slug])
    end
  end

  def serialize_events(events)
    events.includes(:organization).map do |event|
      event.as_json(
        only: %i[id title date venue_name city state starting_ticket_price dress_code status]
      ).merge(
        'organization' => event.organization.as_json(only: %i[name slug])
      )
    end
  end

  def social_url(base_url, value)
    return nil if value.blank?

    normalized = value.strip
    return normalized if normalized.match?(%r{\Ahttps?://}i)
    return "https://#{normalized}" if normalized.start_with?('www.') || normalized.include?('/')

    "#{base_url}#{normalized.delete_prefix('@')}"
  end

  def render_not_found
    redirect_to root_path, alert: 'Profile not found' # rubocop:disable Rails/I18nLocaleTexts
  end
end
