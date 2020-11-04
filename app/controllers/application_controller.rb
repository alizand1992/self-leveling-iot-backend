# frozen_string_literal: true

class ApplicationController < ActionController::Base
  respond_to :json
  include ActionController::MimeResponds

  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?, only: [:create]

  def index
    render json: { authenticity_token: form_authenticity_token }, status: :ok
  end

  def user_data
    if user_signed_in?
      render json: current_user.to_json, status: :ok
    else
      render json: { error: 'You are not logged in!' }, status: :unauthorized
    end
  end

  private

  def check_user_logged_in!
    raise SecurityError.new(User::NEEDS_TO_BE_LOGGED_IN_MSG) if current_user.blank?
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name])
  end
end
