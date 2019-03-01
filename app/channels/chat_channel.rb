class ChatChannel < ApplicationCable::Channel
  def subscribed
    Chat.involving(current_user).each do |chat|
      stream_from "chat_#{chat.id}"
    end
  end

  # Called when message-form contents are received by the server
  def send_message(payload)
    message = Message.new(user: current_user, chat_id: payload["id"], body: payload["message"])

    ActionCable.server.broadcast "chat_#{payload['id']}", message: render_message(message) if message.save

    suggested_time = TimeCop.new(message.body).perform

    suggest_appointment(suggested_time, payload["id"]) if suggested_time
  end

  def suggest_appointment(suggested_time, chat_id)
    chat = Chat.find(chat_id)
    guest = chat.sender == current_user ? chat.recipient : chat.sender
    appointment = Appointment.new(
      organizer: current_user,
      guest: guest,
      start_time: suggested_time
    )

    sleep(1)

    ChatNotificationRelayJob.perform_later current_user.id, chat.id, render_suggestion(appointment, chat)
  end

  def unsubscribed
    stop_all_streams
  end

  private

  def render_message(message)
    ApplicationController.render(
          partial: 'messages/message',
          locals: {message: message}
      )
  end

  def render_suggestion(appointment, chat)
    ApplicationController.render(
          partial: 'appointments/suggestion',
          locals: {chat: chat, appointment: appointment}
      )
  end

  def render_request(appointment)
    ApplicationController.render(
          partial: 'appointments/request',
          locals: {appointment: appointment}
      )
  end
end
