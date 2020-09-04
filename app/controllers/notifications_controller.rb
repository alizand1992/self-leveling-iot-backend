# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :authenticate_user!, only: :create

  def create
    notification = Notification.new(notification_params)
    notification.user = current_user

    notification.save!

    render json: { notification: notification }, status: :ok
  end

  private

  def notification_params
    params.permit(:name, :description)
  end
end
