require 'rails_helper'

RSpec.describe ActivityStreamController, type: :controller do

  describe 'get OrderedCollection' do

    it 'empty collection has context, id, type, and totalItems' do
      get :collection
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json).to_not be_nil
      expect(json['@context']).to_not be_nil
      expect(json['id']).to_not be_nil
      expect(json['type']).to eq('OrderedCollection')
      expect(json['totalItems']).to be_an(Integer)
      expect(json['totalItems']).to eq(0)
      expect(json['first']).to be_nil
      expect(json['last']).to be_nil
    end

    it 'stream has the correct base url' do
      base_url = "https://as.example.com"
      allow(ENV).to receive(:[]).with("AS_BASE_URL").and_return(base_url)
      get :collection
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['id']).to start_with(base_url)
    end

    it 'full collection has correct page counts' do
      event_type = ActivityStreamsEventType.find_by_event_type('Create')
      (0...3001).each {|i|
        ActivityStreamsEvent.create(object_id: "http://example.org/#{i}",
                                    object_type: 'Manifest',
                                    event_type: event_type,
                                    end_time: Time.now)
      }

      get :collection
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json).to_not be_nil
      expect(json['@context']).to_not be_nil
      expect(json['id']).to_not be_nil
      expect(json['type']).to eq('OrderedCollection')
      expect(json['totalItems']).to be_an(Integer)
      expect(json['totalItems']).to eq(3001)
      expect(json['first']).to_not be_nil
      expect(json['first']['id']).to include("/activity/page/0")
      expect(json['first']['type']).to eq('OrderedCollectionPage')
      expect(json['last']).to_not be_nil
      expect(json['last']['id']).to include("/activity/page/3")
      expect(json['last']['type']).to eq('OrderedCollectionPage')
    end

  end

  describe 'get OrderedCollection' do

    it 'has correct page' do
      event_type = ActivityStreamsEventType.find_by_event_type('Create')
      (0...2020).each {|i|
        ActivityStreamsEvent.create(object_id: "http://example.org/#{i}",
                                    object_type: 'sc:Manifest',
                                    event_type: event_type,
                                    end_time: Time.now)
      }
      base_url = "https://as.example.com"
      allow(ENV).to receive(:[]).with("AS_BASE_URL").and_return(base_url)

      get :page, params: {page_number: 1}
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json).to_not be_nil
      expect(json['@context']).to_not be_nil
      expect(json['id']).to include('/activity/page/1')
      expect(json['id']).to start_with(base_url)
      expect(json['type']).to eq('OrderedCollectionPage')
      expect(json['startIndex']).to be_an(Integer)
      expect(json['startIndex']).to eq(1000)
      expect(json['prev']).to_not be_nil
      expect(json['prev']['id']).to include("/activity/page/0")
      expect(json['prev']['id']).to start_with(base_url)
      expect(json['prev']['type']).to eq('OrderedCollectionPage')
      expect(json['next']).to_not be_nil
      expect(json['next']['id']).to include("/activity/page/2")
      expect(json['next']['id']).to start_with(base_url)
      expect(json['next']['type']).to eq('OrderedCollectionPage')
      expect(json['partOf']).not_to be_nil
      expect(json['partOf']['id']).not_to be_nil
      expect(json['partOf']['type']).to eq('OrderedCollection')
      expect(json['orderedItems']).to be_an(Array)
      expect(json['orderedItems'].length).to eq(1000)

      get :page, params: {page_number: 2}
      expect(response.status).to eq(200)
      json = JSON.parse(response.body)
      expect(json['orderedItems']).to be_an(Array)
      expect(json['orderedItems'].length).to eq(20)

    end

  end
end
