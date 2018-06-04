class Friendship < ApplicationRecord
  after_create :create_inverse_relationship, unless: :has_inverse_relationship?
  after_destroy :destroy_inverse_relationship

  belongs_to :user
  belongs_to :friend, class_name: 'User'

  private

  def create_inverse_relationship
    friend.friendships.create(friend: user)
  end

  def destroy_inverse_relationship
    friendship = friend.friendships.find_by(friend: user)
    friendship.destroy if friendship
  end

  def has_inverse_relationship?
    self.class.exists?(inverse_friendship_options)
  end

  def inverse_friendship_options
    { friend_id: user_id, user_id: friend_id }
  end
end
