# frozen_string_literal: true

class NotificationsController < CreateNotifications::Base
  before_action :authenticate_user!, only: [:create]

  def create
    notification = Notification.new(notificaiton_params)
    notification.save!

    render json: { id: notification.id }, status: :ok
  end

  private

  def notification_params
    params.require(:notification).permit(:name, :description)
  end
end
