class Notification < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :actor, class_name: 'User'
  belongs_to :notifiable, polymorphic: true
  after_commit -> { NotificationRelayJob.perform_later(self, count) }

  scope :unread, -> { where(read_at: nil) }

  private

  def count
    recipient.notifications.unread.size
  end
end
