class FriendRequest < ApplicationRecord
  belongs_to :user
  belongs_to :friend, class_name: 'User'

  def accept
    user.friends << friend
    destroy
  end

  def notification_to_s
    "you a friend request"
  end
end
