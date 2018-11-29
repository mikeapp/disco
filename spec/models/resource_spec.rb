require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Resource, type: :model do

  context 'validates' do
    it 'is not valid without object_id' do
      expect(Resource.create(object_type: 'Manifest')).to_not be_valid
    end

    it 'is not valid without object_type' do
      expect(Resource.create(object_id: 'http://example.org/1')).to_not be_valid
    end

    it 'is valid without fixity/etag' do
      expect(Resource.create(object_id: 'http://example.org/1',
                             object_type: 'Manifest')).to be_valid
    end
  end

  context 'creates events' do

    it 'emits a Create event based on etag value' do
      last_modified = Time.now
      resource = Resource.create(object_id: 'http://example.org/1',
                                 object_type: 'Manifest')
      stub_request(:get, 'http://example.org/1').to_return(headers: {etag: 'foo', last_modified: last_modified.httpdate})
      event = resource.create_event_if_changed
      expect(event.event_type.event_type).to eq('Create')
      expect(resource.http_etag).to eq('foo')
      expect(resource.http_last_modified).to eq(last_modified.httpdate)
    end

    it 'emits a Create event based on body MD5 value' do
      resource = Resource.create(object_id: 'http://example.org/2',
                                 object_type: 'Manifest')
      body_content = "random text value"
      body_md5 = Digest::MD5.hexdigest(body_content)
      stub_request(:get, 'http://example.org/2').to_return(status: 200, body: body_content)
      event = resource.create_event_if_changed
      expect(event.event_type.event_type).to eq('Create')
      expect(resource.http_etag).to be_nil
      expect(resource.fixity_md5).to eq(body_md5)
    end

    it 'responds correctly to HTTP 304 Not Modified' do
      last_modified = Time.now
      etag = "foo"
      resource = Resource.create(object_id: 'http://example.org/1',
                                 object_type: 'Manifest',
                                 http_etag: etag,
                                 http_last_modified: last_modified)
      stub_request(:get, 'http://example.org/1').to_return(status: 304, headers:{etag:'etag'}, body: "body")
      expect(resource.http_last_modified).to eq(last_modified)
      expect(resource.http_etag).to eq(etag)
      expect(resource.fixity_md5).to be_nil
    end

    it 'handles HTTP 405 Method not allowed' do
      resource = Resource.create(object_id: 'http://example.org/3',
                                 object_type: 'Manifest')
      body_content = "handles HTTP 405 Method not allowed"
      body_md5 = Digest::MD5.hexdigest(body_content)
      stub_request(:get, 'http://example.org/3').to_return(status: 405, body: body_content)
      event = resource.create_event_if_changed
      expect(event).to be_nil
      expect(resource.fixity_md5).to be_nil
      expect(resource.http_etag).to be_nil
      expect(resource.http_last_modified).to be_nil
    end

    it 'emits an Update event when etag has changed' do
      resource = Resource.create(object_id: 'http://example.org/1',
                                 object_type: 'Manifest',
                                 http_etag: 'bar')
      stub_request(:get, 'http://example.org/1').to_return(headers: {etag: 'foo'})
      event = resource.create_event_if_changed
      expect(event.event_type.event_type).to eq('Update')
      expect(resource.http_etag).to eq('foo')
    end

    it 'emits an Update event when body MD5 value has changed' do
      resource = Resource.create(object_id: 'http://example.org/2',
                                 object_type: 'Manifest',
                                 http_etag: 'bar')
      body_content = "random text value"
      body_md5 = Digest::MD5.hexdigest(body_content)
      stub_request(:get, 'http://example.org/2').to_return(status: 200, body: body_content)
      event = resource.create_event_if_changed
      expect(event.event_type.event_type).to eq('Update')
      expect(resource.fixity_md5).to eq(body_md5)
    end

    it 'emits a Delete event when resource returns 404 Not Found' do
      resource = Resource.create(object_id: 'http://example.org/2',
                                 object_type: 'Manifest',
                                 http_etag: 'bar')
      stub_request(:get, 'http://example.org/2').to_return(status: 404)
      event = resource.create_event_if_changed
      expect(event.event_type.event_type).to eq('Delete')
      expect(resource.http_etag).to be_nil
      expect(resource.fixity_md5).to be_nil
    end

    it 'emits a Delete event when resource returns 410 Gone' do
      resource = Resource.create(object_id: 'http://example.org/2',
                                 object_type: 'Manifest',
                                 http_etag: 'bar')
      stub_request(:get, 'http://example.org/2').to_return(status: 410)
      event = resource.create_event_if_changed
      expect(event.event_type.event_type).to eq('Delete')
      expect(resource.http_etag).to be_nil
      expect(resource.fixity_md5).to be_nil
    end

  end

end
