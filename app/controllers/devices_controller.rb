class DevicesController < ApplicationController
  before_action :authenticate_user!, only: %i[register]
  before_action :check_user_logged_in!, only: %i[register]

  def index
    devices = Device.where(user_id: nil)
    devices = devices.map do |device |
      {
        aws_device_id: device.aws_device_id,
        device_name: device.device_name,
      }
    end

    render json: { devices: devices }.to_json, status: :ok
  end

  def sync
    Device.sync_with_aws
    render json: { success: :ok }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def register
    device = Device.where(aws_device_id: register_params[:aws_device_id], user_id: nil).first

    raise ActiveRecord::RecordNotFound.new(Device::DEVICE_NOT_FOUND) if device.nil?

    device.user_id = current_user.id
    device.device_name = register_params[:device_name]
    device.save!

    render json: { success: :ok }, status: :ok
  rescue ActiveRecord::RecordNotFound, ActionController::ParameterMissing => e
    render json: { error: e.message }, status: :bad_request
  end

  private

  def register_params
    @register_params ||=
      begin
        params.require(:aws_device_id)
        params.require(:device_name)
        params.permit(:aws_device_id, :device_name)
      end
  end
end
