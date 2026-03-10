# frozen_string_literal: true

class SettingsController < InertiaController
  before_action :authenticate_user!

  def show
    render inertia: 'settings/show', props: {
      user: current_user.as_json(only: %i[
                                   first_name last_name email username bio birthdate sex city state
                                   social_x social_linkedin social_instagram social_facebook
                                   interested_causes interested_industries
                                   visibility visibility_full_name visibility_email
                                 ])
    }
  end

  def update
    if current_user.update(user_params)
      redirect_to settings_path, flash: { success: 'Settings updated' }
    else
      redirect_to settings_path, inertia: { errors: current_user.errors.to_hash(true) }
    end
  end

  private

  def user_params
    permitted = params.expect(user: [
                                :first_name, :last_name, :email, :username,
                                :bio, :birthdate, :sex, :city, :state,
                                :social_x, :social_linkedin, :social_instagram, :social_facebook,
                                :visibility, :visibility_full_name, :visibility_email,
                                :password, :password_confirmation,
                                { interested_causes: [], interested_industries: [] }
                              ])
    if permitted[:password].blank?
      permitted.delete(:password)
      permitted.delete(:password_confirmation)
    end
    permitted
  end
end
