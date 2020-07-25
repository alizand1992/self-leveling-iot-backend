# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :notification

  PENDING = 1
  SENT = 2
  FAILED = 3
end
