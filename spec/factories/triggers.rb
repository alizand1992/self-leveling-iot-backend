FactoryBot.define do
  factory :trigger do
    aws_column { 'battery' }
    relationship { 'less than' }
    trigger_type { 'float' }
    value { '20.0' }
  end
end
