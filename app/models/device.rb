# frozen_string_literal: true

require 'net/http'

class Device < ApplicationRecord
  belongs_to :user, optional: true

  SYNC_ERROR = 'There was an error syncing devices'
  DEVICE_NOT_FOUND = 'Could not find a device with that ID.'
  DEVICES_ARE_REQUIRED = 'Devices are required to get the details'

  def self.sync_with_aws
    uri = URI.parse('https://2v0ejsryj6.execute-api.us-west-1.amazonaws.com/devices/all')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.path)
    response = http.request(request)
    code = JSON.parse(response.code)
    raise StandardError.new(SYNC_ERROR) if code != 200

    items = JSON.parse(JSON.parse(response.body)["body"])

    ids = items.map { |item| item['id']['S'] }

    already_existing = self.where(aws_device_id: ids).pluck(:aws_device_id)
    new_ids = ids - already_existing

    devices = new_ids.map { |id| { aws_device_id: id } }

    self.create!(devices)
  end

  def self.user_devices(user_id = nil)
    where(user_id: user_id).map do |device|
      {
        aws_device_id: device.aws_device_id,
        device_name: device.device_name,
        user_id: user_id,
      }
    end
  end

  def self.devices_with_details(devices)
    raise ArgumentError.new(DEVICES_ARE_REQUIRED) if devices.blank?

    device_ids = devices.map { |device| device[:aws_device_id] }

    uri = URI.parse('https://2v0ejsryj6.execute-api.us-west-1.amazonaws.com/devices/device-status')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.path)
    request.body = device_ids.to_json
    response = http.request(request)
    code = JSON.parse(response.code)
    raise StandardError.new(SYNC_ERROR) if code != 200

    device_details = JSON.parse(JSON.parse(response.body)["body"])["result"]

    devices.map do |device|
      status = device_details.select do |det|
        det["id"] == device[:aws_device_id]
      end.first
      device.merge!(status)
    end

    return devices
  end

  def self.issue_command(command)
    uri = URI.parse('https://2v0ejsryj6.execute-api.us-west-1.amazonaws.com/devices/level')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(uri.path)
    request.body = command.to_json
    response = http.request(request)
  end
end
