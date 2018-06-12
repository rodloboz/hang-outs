Rails.application.routes.draw do
  devise_for :users
  root to: 'users#index'

  resources :users, only: [:index] do
    member do
      post :follow
      post :unfollow
    end
  end
  resources :friend_requests, only: [:index, :create, :update, :destroy]
  resources :friendships, only: :index

  resources :chats, only: [:index, :show, :create] do
    resources :messages, only: [:create]
  end

  resources :notifications, only: [:index] do
    collection do
      post :mark_as_read
    end
  end

  # mount ActionCable.server => '/cable'
end
