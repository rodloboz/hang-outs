class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:accept, :reject]

  def create
    @appointment = Appointment.new(appointment_params)
  end

  def accept
    if @appointment.update(status: :accepted)
      chat = Chat.between(@appointment.organizer, @appointment.guest).first
      ChatNotificationRelayJob.perform_later @appointment.organizer.id, chat.id, render_accepted if chat
    end
    head :no_content
  end

  def reject
    @appointment.update(status: :rejected)
    head :no_content
  end

  private

  def appointment_params
    params.require(:appointment).permit(:start_time)
  end

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def render_accepted
    render_to_string(partial: "/appointments/accepted", locals: { appointment: @appointment })
  end
end
