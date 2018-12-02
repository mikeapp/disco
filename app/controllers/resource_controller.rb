# frozen_string_literal: true

class ResourceController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :validate_credentials

  def create
    result_items = Array.new
    items = validate_items_param
    items.each do |item|
      id = item['id']
      type = item['type']
      raise "id and type required" unless id and type
      unless Resource.find_by_object_id(id)
        res = Resource.create(object_id: id, object_type: type)
        result_items.push({ 'id': id, 'type': type})
      end
    end
    render json: result_items
  end

  def refresh
    items = validate_items_param
    items.each do |item|
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
    items = JSON.parse(request.body.read.to_s)
    unless items and items.is_a?(Array)
      return head 400, 'content-type' => 'text/plain'
    end
    items
  end

  def basic_auth_allowed?
    pwd = basic_auth_password
    !(pwd.nil? or pwd.empty?)
  end

  def basic_auth_password
    Rails.application.config.basic_auth_password
  end

end
