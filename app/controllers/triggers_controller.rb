# frozen_string_literal: true

class TriggersController < ApplicationController
  before_action :authenticate_user!, only: %i[index create]
  before_action :check_user_logged_in!, only: %i[index create]
  before_action :check_notification_owner!, only: %i[index create]

  def index
    triggers = Trigger.where notification_id: params[:notification_id]

    render json: { triggers: triggers }, status: :ok
  end

  def create
    trigger = Trigger.new(trigger_params)
    trigger.save!

    render json: { success: :ok }, status: :ok
  end

  def attributes
    render json: { attributes: Trigger::ATTRIBUTES }, status: :ok
  end

  private

  def trigger_params
    params.permit(:aws_column, :relationship, :trigger_type, :value, :notification_id)
  end

  def check_user_logged_in!
    raise SecurityError.new(User::NEEDS_TO_BE_LOGGED_IN_MSG) if current_user.blank?
  end

  def check_notification_owner!
    notification = Notification.find(params[:notification_id])

    raise SecurityError.new(Trigger::DOES_NOT_OWN_NOTIFICATION_MSG) if notification.user_id != current_user.id
  rescue SecurityError => e
    render json: { error: e.message }, status: :unauthorized
  end
end
