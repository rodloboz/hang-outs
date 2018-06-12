class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notifications

  def index; end

  def mark_as_read
    @notifications.update_all(read_at: Time.zone.now)
    render json: { sucess: true}, status: :ok
  end

  private

  def set_notifications
    @notifications = Notification.where(recipient: current_user).unread
  end
end
