class Follow < ApplicationRecord
  belongs_to :follower, foreign_key: 'follower_id', class_name: 'User'
  belongs_to :following, foreign_key: 'following_id', class_name: 'User'

  after_create :create_notification

  def notification_to_s
    "following you"
  end

  private

  def create_notification
    Notification.create(
      recipient: following,
      actor: follower,
      action: 'started',
      notifiable: self
    )
  end
end
