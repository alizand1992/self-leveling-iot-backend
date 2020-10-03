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

  def show
    if user_signed_in?
      notification = Notification.find(params[:id])

      if !notification.belongs_to_user(current_user)
        render json: { error: User::MISSING_PERMISSION_MSG }, status: :unauthorized
      else
        render json: {
          notification: {
            name: notification.name,
            description: notification.description,
          },
        }, status: :ok
      end
    else
      render json: { error: User::NEEDS_TO_BE_LOGGED_IN_MSG }, status: :unauthorized
    end
  end

  def update
    if user_signed_in?
      notification = Notification.find(params[:id])

      if notification.belongs_to_user(current_user)
        notification.update(notification_params)
        notification.save!

        render json: { success: 'ok' }, status: :ok
      else
        render json: { error: 'You do not have correct permissions' }, status: :unauthorized
      end
    end
  end

  private

  def notification_params
    params.permit(:name, :description)
  end
end
