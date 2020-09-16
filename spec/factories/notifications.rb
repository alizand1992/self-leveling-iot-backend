# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    user_id { create(:user).id }
    name { 'Low Battery' }
    description { 'Notify user when the battery gets below 20%.' }
  end
end
