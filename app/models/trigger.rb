class Trigger < ApplicationRecord
  belongs_to :notification

  DOES_NOT_OWN_NOTIFICATION_MSG = 'The notification does not belong to this user'

  ATTRIBUTES = {
    battery: {
      text: 'battery',
      trigger_type: 'float',
      relationships: {
        less_than: 'less than',
        equal: 'equal to',
        more_than: 'more than',
      },
    },
    level_status: {
      text: 'level status',
      trigger_type: 'bool',
      relationships: {
        equal: 'is'
      },
      options: {
        false: 'not leveled',
        true: 'leveled',
      },
    },
    health_status: {
      text: 'device health status',
      trigger_type: 'bool',
      relationships: {
        equal: 'is'
      },
      options: {
        false: 'Malfunctioning',
        true: 'Good',
      },
    },
  }.freeze
end
