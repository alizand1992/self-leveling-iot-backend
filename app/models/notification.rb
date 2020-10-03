# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user

  has_many :messages, dependent: :destroy
  has_many :triggers, dependent: :destroy

  def belongs_to_user(user)
    self.user_id == user.id
  end
end
