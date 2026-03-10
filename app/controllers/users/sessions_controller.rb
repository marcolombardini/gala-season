# frozen_string_literal: true

module Users
  class SessionsController < InertiaController
    def new
      render inertia: 'Users/Sessions/New'
    end

    def create
      user = User.find_by(email: params[:email])

      if user&.authenticate(params[:password])
        sign_in_user(user)
        redirect_to root_path
      else
        redirect_to users_sign_in_path, inertia: { errors: { base: ['Invalid email or password'] } }
      end
    end

    def destroy
      sign_out
      redirect_to root_path
    end
  end
end
