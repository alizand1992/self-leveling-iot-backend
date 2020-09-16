# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!, only: %i[create index]

  def index
    raise SecurityError unless current_user.present?

    notifications = Notification.where(user_id: current_user.id)

    render json: { notifications: notifications }, status: :ok
  rescue SecurityError
    render json: { error: 'User needs to be logged in' }, status: :unauthorized
  end

  def create
    notification = Notification.new(notification_params)
    notification.user_id = current_user.id

    notification.save!

    render json: { notification: notification }, status: :ok
  end

  private

  def notification_params
    params.permit(:name, :description)
  end
end
