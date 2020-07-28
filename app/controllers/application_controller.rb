# frozen_string_literal: true

class ApplicationController < ActionController::Base
  respond_to :json
  include ActionController::MimeResponds

  protect_from_forgery

  before_action :configure_permitted_parameters, if: :devise_controller?, only: [:create]

  def index
    render json: { authenticity_token: form_authenticity_token }, success: :ok
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name])
  end
end
