# frozen_string_literal: true

class FollowsController < InertiaController
  before_action :authenticate_user!

  def create
    organization = Organization.find_by!(slug: params[:slug])
    Follow.find_or_create_by(user: current_user, organization: organization)
    redirect_back_or_to(organization_profile_path(organization.slug))
  end

  def destroy
    organization = Organization.find_by!(slug: params[:slug])
    Follow.find_by(user: current_user, organization: organization)&.destroy
    redirect_back_or_to(organization_profile_path(organization.slug))
  end
end
