# frozen_string_literal: true

class AttendancesController < InertiaController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :authenticate_user!
  before_action :set_event

  def create
    Attendance.find_or_create_by(user: current_user, event: @event)
    redirect_back_or_to(event_path(@event))
  end

  def destroy
    Attendance.find_by(user: current_user, event: @event)&.destroy
    redirect_back_or_to(event_path(@event))
  end

  private

  def set_event
    @event = Event.published.find(params[:event_id])
  end

  def render_not_found
    redirect_to root_path, alert: 'Event not found' # rubocop:disable Rails/I18nLocaleTexts
  end
end
