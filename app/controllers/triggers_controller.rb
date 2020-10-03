# frozen_string_literal: true

class TriggersController < ApplicationController
  before_action :authenticate_user!, only: %i[create]

  def create
    raise SecurityError.new(User::NEEDS_TO_BE_LOGGED_IN_MSG) unless current_user.present?

    notification = Notification.find(params[:notification_id])

    raise SecurityError.new(Trigger::DOES_NOT_OWN_NOTIFICATION_MSG) if notification.user_id != current_user.id

    trigger = Trigger.new(trigger_params)
    trigger.save!

    render json: { success: :ok }, status: :ok
  rescue SecurityError => e
    render json: { error: e.message }, status: :unauthorized
  end

  private

  def trigger_params
    params.permit(:aws_column, :relationship, :trigger_type, :value, :notification_id)
  end
end
