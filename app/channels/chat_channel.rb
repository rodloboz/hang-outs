class ChatChannel < ApplicationCable::Channel
  def subscribed
    Chat.involving(current_user).each do |chat|
      stream_from "chat_#{chat.id}"
    end
  end

  # Called when message-form contents are received by the server
  def send_message(payload)
    message = Message.new(user: current_user, chat_id: payload["id"], body: payload["message"])

    ActionCable.server.broadcast "chat_#{payload['id']}", message: render(message) if message.save
  end

  def unsubscribed
    stop_all_streams
  end

  private

  def render(message)
    ApplicationController.render(
          partial: 'messages/message',
          locals: {message: message}
      )
  end
end
