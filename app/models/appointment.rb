class Appointment < ApplicationRecord
  belongs_to :organizer, foreign_key: :organizer_id, class_name: 'User'
  belongs_to :guest, foreign_key: :guest_id, class_name: 'User'

  enum status: [:pending, :accepted, :cancelled, :rejected]

  scope :requested_to, -> (user) {
    where("appointments.guest_id = ?", user).pending
  }

  after_update :create_notification, if: :accepted?

  def appointment_time
    minutes = start_time.min > 0 ? ":%M" : ""
    start_time.in_time_zone("Jerusalem").strftime("%A, %d %B %Y at %-l#{minutes} %P")
  end

  private

  def create_notification
    Notification.create(
      recipient: organizer,
      actor: guest,
      action: 'accepted',
      notifiable: self
    )
  end
end
