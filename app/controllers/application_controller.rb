# frozen_string_literal: true

class ApplicationController < ActionController::Base
  respond_to :json
  include ActionController::MimeResponds

  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?, only: [:create]
  before_action :authenticate_user!, only: :user_data

  def index
    render json: { authenticity_token: form_authenticity_token }, status: :ok
  end

  def user_data
    if current_user.nil?
      render json: { error: 'You are not logged in!' }, status: :unauthorized
    else
      render json: current_user.to_json, status: :ok
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name])
  end
end
