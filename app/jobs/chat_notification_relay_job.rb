class ChatNotificationRelayJob < ApplicationJob
  queue_as :default

  def perform(recipient_id, chat_id, message)
    ActionCable.server.broadcast "notifications:#{recipient_id}_for_chat_#{chat_id}", message: message
  end
end
