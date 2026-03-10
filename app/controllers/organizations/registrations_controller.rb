# frozen_string_literal: true

module Organizations
  class RegistrationsController < InertiaController
    def new
      render inertia: 'Organizations/Registrations/New'
    end

    def create
      organization = Organization.new(organization_params)

      if organization.save
        sign_in_organization(organization)
        redirect_to root_path
      else
        redirect_to organizations_sign_up_path, inertia: { errors: organization.errors.to_hash(true) }
      end
    end

    private

    def organization_params
      params.expect(organization: %i[name email password password_confirmation])
    end
  end
end
