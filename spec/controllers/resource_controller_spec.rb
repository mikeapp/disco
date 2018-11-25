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
      @resource_id = 'http://example.org/1'
      @post_content = { 'items': [{ 'id': @resource_id, 'type': 'Manifest' }] }
    end

    it 'should respond with 200 to a create request' do
      request.headers['Authorization'] = Rails.application.config.basic_auth_password
      post :create, params: @post_content
      expect(response.status).to eq(200)
      expect(Resource.find_by_object_id(@resource_id)).not_to be_nil
    end

    it 'should respond with 200 to a refresh request' do
      request.headers['Authorization'] = Rails.application.config.basic_auth_password
      post :refresh, params: @post_content
      expect(response.status).to eq(200)
    end

  end
end
