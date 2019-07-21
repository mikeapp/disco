# frozen_string_literal: true

class ActivityStreamController < ApplicationController

  def collection
    activity_stream = ActivityStream.new(request.base_url)
    render json: JSON.pretty_generate(activity_stream.to_h)
  end

  def page
    page_number = params[:page_number].to_i
    begin
      page = ActivityStream.new(request.base_url).page(page_number).to_h
      render json: page
    rescue ActiveRecord::RecordNotFound
      head 404, "content_type" => 'text/plain'
      return
    end
  end

  private

  def activity_stream_params
    params.permit(:page_number)
  end

end
