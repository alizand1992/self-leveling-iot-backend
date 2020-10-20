FactoryBot.define do
  factory :device do
    factory :unregistered_device do
      aws_device_id { Random.uuid() }
    end
  end
end
