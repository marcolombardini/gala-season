# frozen_string_literal: true

module Organizations
  class SessionsController < InertiaController
    def new
      render inertia: 'Organizations/Sessions/New'
    end

    def create
      organization = Organization.find_by(email: params[:email])

      if organization&.authenticate(params[:password])
        sign_in_organization(organization)
        redirect_to root_path
      else
        redirect_to organizations_sign_in_path, inertia: { errors: { base: ['Invalid email or password'] } }
      end
    end

    def destroy
      sign_out
      redirect_to root_path
    end
  end
end
