require 'rails_helper'

RSpec.describe ResourceController, type: :controller do

  context 'requests with bad password' do
    it 'should respond with 401 to a refresh request' do
      request.headers['Authorization'] = SecureRandom.uuid
      post :refresh
      expect(response.status).to eq(401)
    end

    it 'should respond with 401 to a create request' do
      request.headers['Authorization'] = SecureRandom.uuid
      post :create
      expect(response.status).to eq(401)
    end
  end

  context 'request with good password' do
    before(:each) do
      res = Resource.create(object_id: 'http://example.org/2', object_type: 'Manifest')
      @resource_id = 'http://example.org/1'
      @post_content = [
          { 'id': @resource_id,
            'type': 'Manifest' },
          { 'id': res.object_id,
            'type': res.object_type}
      ]
    end

    it 'should respond with 200 to a create request' do
      request.headers['Authorization'] = Rails.application.config.basic_auth_password
      post :create, body: @post_content.to_json, format: :json
      expect(response.status).to eq(200)
      expect(Resource.find_by_object_id(@resource_id)).not_to be_nil
      expect(response.body).not_to be_nil
      json = JSON.parse(response.body)
      expect(json).to be_a(Array)
      expect(json.size).to be(1)
      expect(json[0]['id']).to eq(@resource_id)
    end

    it 'should respond with 200 to a refresh request' do
      request.headers['Authorization'] = Rails.application.config.basic_auth_password
      post :refresh, body: @post_content.to_json, format: :json
      expect(response.status).to eq(200)
    end

  end
end
