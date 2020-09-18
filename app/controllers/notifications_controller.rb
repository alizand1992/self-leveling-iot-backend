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

      if notification.user_id != current_user.id
        render json: { error: 'You do not have correct permissions' }, status: :unauthorized
      else
        render json: {
          notification: {
            name: notification.name,
            description: notification.description,
          },
        }, status: :ok
      end
    else
      render json: { error: 'User needs to be logged in' }, status: :unauthorized
    end
  end

  private

  def notification_params
    params.permit(:name, :description)
  end
end
