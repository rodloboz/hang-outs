class AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:accept, :reject]

  def create
    @appointment = Appointment.new(appointment_params)
    byebug
  end

  def accept
    @appointment.update(status: :accepted)
  end

  def reject
    @appointment.update(status: :rejected)
  end

  private

  def appointment_params
    params.require(:appointment).permit(:start_time)
  end

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end
end
