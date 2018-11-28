class ActivityStreamsEvent < ApplicationRecord
  belongs_to :event_type, class_name: 'ActivityStreamsEventType'

  validates :object_type, presence: true
  validates :object_id, presence: true
  validates :event_type_id, presence: true
  validates :end_time, presence: true

end
