class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications:#{current_user.id}"
  end

  def send_notification(notification)
    # html = ApplicationController.render partial: "notifications/#{notification.notifiable_type.underscore.pluralize}/#{notification.action}", locals: {notification: notification}, formats: [:html]
    # ActionCable.server.broadcast "notifications:#{notification.recipient_id}", html: html
  end

  def unsubscribed
    stop_all_streams
  end
end
