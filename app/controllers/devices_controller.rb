class DevicesController < ApplicationController
  def sync
    Device.sync_with_aws
    render json: { success: :ok }, status: :ok
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end
end
