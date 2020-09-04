# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name { 'Smith' }
    email { 'john.smith@gmail.com' }
    password { 'password_123' }
  end
end
