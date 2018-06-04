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
end
