require 'rails_helper'

RSpec.describe ActivityStreamsEvent, type: :model do

  let(:event_type) { ActivityStreamsEventType.find_by_event_type('Create') }

  context 'validates' do
    it 'is not valid without object_id' do
      expect(ActivityStreamsEvent.create(object_type: 'Manifest',
                                         event_type: event_type,
                                         end_time: Time.now)).to_not be_valid
    end

    it 'is not valid without object_type' do
      expect(ActivityStreamsEvent.create(object_id: 'http://example.org/1',
                                         event_type: event_type,
                                         end_time: Time.now)).to_not be_valid
    end

    it 'is not valid without an event type' do
      expect(ActivityStreamsEvent.create(object_id: 'http://example.org/1',
                                         object_type: 'Manifest',
                                         end_time: Time.now)).to_not be_valid
    end

    it 'is not valid without an end time' do
      expect(ActivityStreamsEvent.create(object_id: 'http://example.org/1',
                                         object_type: 'Manifest',
                                         event_type: event_type)).to_not be_valid
    end
  end

  context 'with multiple events' do
    it 'sorts by end_time' do
      e1 = ActivityStreamsEvent.create(object_id: 'http://example.org/1',
                                       object_type: 'Manifest',
                                       event_type: event_type,
                                       end_time: Time.now)
      e2 = ActivityStreamsEvent.create(object_id: 'http://example.org/1',
                                       object_type: 'Manifest',
                                       event_type: event_type,
                                       end_time: Time.new(2002, 1, 1))
      expect(ActivityStreamsEvent.order(:end_time).first).to eq(e2)
      expect(ActivityStreamsEvent.order(:end_time).last).to eq(e1)
    end
  end

end
