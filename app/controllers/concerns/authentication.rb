# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :set_current_auth
    helper_method :signed_in?, :current_user, :current_organization
  end

  private

  def set_current_auth
    Current.user = session[:user_id] ? User.find_by(id: session[:user_id]) : nil
    Current.organization = session[:organization_id] ? Organization.find_by(id: session[:organization_id]) : nil
  end

  def authenticate!
    redirect_to root_path unless signed_in?
  end

  def authenticate_user!
    redirect_to root_path unless current_user
  end

  def authenticate_organization!
    redirect_to root_path unless current_organization
  end

  def signed_in?
    current_user.present? || current_organization.present?
  end

  def current_user
    Current.user
  end

  def current_organization
    Current.organization
  end

  def sign_in_user(user)
    reset_session
    session[:user_id] = user.id
    Current.user = user
    Current.organization = nil
  end

  def sign_in_organization(organization)
    reset_session
    session[:organization_id] = organization.id
    Current.organization = organization
    Current.user = nil
  end

  def sign_out
    reset_session
    Current.reset
  end
end
