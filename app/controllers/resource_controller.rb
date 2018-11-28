# frozen_string_literal: true

class ResourceController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :validate_credentials, :validate_items_param

  def create
    result_items = Array.new
    params['items'].each do |item|
      raise "#{item} is not a Hash" unless item.is_a?(ActionController::Parameters)

      id = item['id']
      type = item['type']
      raise "id and type required" unless id and type
      unless Resource.find_by_object_id(id)
        res = Resource.create(object_id: id, object_type: type)
        result_items.push({ 'id': id, 'type': type})
      end
    end
    render json: { 'items': result_items }
  end

  def refresh
    params['items'].each do |item|
      raise "#{item} is not a Hash" unless item.is_a?(ActionController::Parameters)

      id = item['id']
      raise "id required" unless id

      res = Resource.find_by_object_id(id)
      CheckForActivityJob.perform_later(res) if res
    end
    head 200
  end

  private

  def validate_credentials
    unless basic_auth_allowed? and request.headers['Authorization'] == basic_auth_password
      head 401, 'content-type' => 'text/plain'
      return
    end
  end

  def validate_items_param
    list = params['items']
    return head 400, 'content-type' => 'text/plain' unless list and list.is_a?(Array)
  end

  def basic_auth_allowed?
    pwd = basic_auth_password
    !(pwd.nil? or pwd.empty?)
  end

  def basic_auth_password
    Rails.application.config.basic_auth_password
  end

end
