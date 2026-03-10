# frozen_string_literal: true

module Users
  class RegistrationsController < InertiaController
    def new
      render inertia: 'Users/Registrations/New'
    end

    def create
      user = User.new(user_params)

      if user.save
        sign_in_user(user)
        redirect_to root_path
      else
        redirect_to users_sign_up_path, inertia: { errors: user.errors.to_hash(true) }
      end
    end

    private

    def user_params
      params.expect(user: %i[first_name last_name email username password password_confirmation])
    end
  end
end
