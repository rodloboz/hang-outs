class Appointment < ApplicationRecord
  belongs_to :organizer, foreign_key: :organizer_id, class_name: 'User'
  belongs_to :guest, foreign_key: :guest_id, class_name: 'User'

  validates :guest, uniqueness: { scope: :organizer }

  enum status: [:pending, :accepted, :cancelled, :rejected]

  def appointment_time
    start_time.strftime("%A, %d %B %Y at %l %P")
  end
end
