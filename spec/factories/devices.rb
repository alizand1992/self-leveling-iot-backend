FactoryBot.define do
  factory :device do
    aws_device_id { Random.uuid() }

    factory :unregistered_device do
      user_id { nil }
    end

    factory :registered_device do
      user_id { create(:user).id }
    end
  end
end
