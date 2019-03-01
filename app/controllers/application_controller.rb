class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  around_action :set_time_zone, if: :current_user

  private

  def set_time_zone(&block)
    Time.use_zone("Jerusalem", &block)
  end
end
