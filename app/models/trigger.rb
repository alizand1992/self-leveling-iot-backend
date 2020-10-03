class Trigger < ApplicationRecord
  belongs_to :notification

  DOES_NOT_OWN_NOTIFICATION_MSG = 'The notification does not belong to this user'
end
