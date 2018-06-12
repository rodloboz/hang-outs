class FriendRequestsController < ApplicationController
  before_action :set_friend_request, except: [:index, :create]
  before_action :set_user, except: [:index, :update]

  def index
    @incoming = FriendRequest.where(friend: current_user)
    @outgoing = current_user.friend_requests
  end

  def create
    friend = User.find(params[:friend_id])
    @friend_request = current_user.friend_requests.new(friend: friend)

    if @friend_request.save
      Notification.create(
        recipient: friend,
        actor: current_user,
        action: 'sent',
        notifiable: @friend_request
      )
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js
      end
    end
  end

  def update
    @friend_request.accept
    Notification.create(
      recipient: @friend_request.friend,
      actor: current_user,
      action: 'accepted',
      notifiable: @friend_request
    )
    redirect_to friendships_path
  end

  def destroy
    @friend_request.destroy
    respond_to do |format|
      format.html { redirect_to friend_requests_path }
      format.js { render action: :create }
    end
  end

  private

  def set_friend_request
    @friend_request = FriendRequest.find(params[:id])
  end

  def set_user
    @user = User.find(params[:user_id] || params[:friend_id])
  end
end
