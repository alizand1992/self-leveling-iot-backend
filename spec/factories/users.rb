# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name { 'Smith' }
    sequence(:email, 1000) { |n| "john.smith#{n}@gmail.com" }
    password { 'password_123' }
  end
end
