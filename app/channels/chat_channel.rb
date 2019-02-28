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

    suggestion = TimeScanner.new(message.body).perform

    suggest_appointment(suggested_time, payload["id"]) if suggested_time
  end

  def suggest_appointment(suggested_time, chat_id)
    chat: @chat, appointment: Appointment.new
    chat = Chat.find(chat_id)
    guest = chat.sender == current_user ? recipient : sender
    appointment = Appointment.new(
      organizer: current_user,
      guest: guest,
      start_time: suggested_time
    )

    ActionCable.server.broadcast "chat_#{chat_id}", suggestion: render_suggestion(appointment, chat)
  end

  def request_appointment(payload)
    chat = Chat.find(chat_id)
    guest = chat.sender == current_user ? recipient : sender

    appointment = Appointment.new(organizer: current_user, guest: guest, start_time: suggested_time )

    puts "******************** DEBUGGGGG *************************"
    ActionCable.server.broadcast "chat_#{chat_id}", suggestion: render_suggestion(appointment, chat) if message.save
  end

  def accept_appointment
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
end
