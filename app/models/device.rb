# frozen_string_literal: true

require 'net/http'

class Device < ApplicationRecord
  belongs_to :user, optional: true

  SYNC_ERROR = 'There was an error syncing devices'

  def self.sync_with_aws
    uri = URI.parse('https://2v0ejsryj6.execute-api.us-west-1.amazonaws.com/devices/all123')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uri.path)
    response = http.request(request)
    code = JSON.parse(response.code)
    raise Exception.new('There was an error syncing devices') if code != 200

    items = JSON.parse(response.body)

    ids = items.map { |item| item['id']['S'] }

    already_existing = self.where(aws_device_id: ids).pluck(:aws_device_id)
    new_ids = ids - already_existing

    devices = new_ids.map { |id| { aws_device_id: id } }

    self.create!(devices)
  end
end
