class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat

  validates_presence_of :body, :chat_id, :user_id

  def message_time
    created_at.strftime("%d %b, %Y")
  end
end
