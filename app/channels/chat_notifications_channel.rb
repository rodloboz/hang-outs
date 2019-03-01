class ChatNotificationsChannel < ApplicationCable::Channel
  def subscribed
    Chat.involving(current_user).each do |chat|
      stream_from "notifications:#{current_user.id}_for_chat_#{chat.id}"
    end
  end

  def request_appointment(payload)
    chat = Chat.find(payload["id"])
    guest = chat.sender == current_user ? chat.recipient : chat.sender

    appointment = Appointment.new(organizer: current_user, guest: guest, start_time: payload["start_time"])

    ActionCable.server.broadcast "notifications:#{guest.id}_for_chat_#{chat.id}", message: render_request(appointment) if appointment.save
  end

  def unsubscribed
    stop_all_streams
  end

  private

  def render_request(appointment)
    ApplicationController.render(
          partial: 'appointments/request',
          locals: {appointment: appointment}
      )
  end
end
