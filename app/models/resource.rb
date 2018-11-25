require 'net/http'

class Resource < ApplicationRecord

  validates :object_id, presence: true
  validates :object_type, presence: true

  def create_event_if_changed
    response = request(object_id, true)
    response = request(object_id) if response.code == '405'
    process_response(response)
  end

  private

  def process_response(response)
    t = Time.now
    event_type_str = nil
    exists = !etag.nil?
    case response
    when Net::HTTPSuccess then
      response_etag = response.header['etag']
      unless response_etag
        response = request(object_id).response
        raise "Error requesting body for #{object_id}" unless response.code == '200'

        response_etag = Digest::MD5.hexdigest(response.body)
      end
      return if exists and response_etag == etag

      event_type_str = (exists)? 'Update' : 'Create'
      self.etag = response_etag
    when Net::HTTPGone, Net::HTTPNotFound then
      event_type_str = 'Delete'
      self.etag = nil
      self.object_last_update = Time.now
    else
      logger.info("Received unexpected response code #{response.code} for #{object_id}")
      return
    end

    self.object_last_update = t
    event = create_event(event_type_str)
    save
    event
  end

  def create_event(event_type_str, time = Time.now)
    raise 'Event type must not be nil' if event_type_str.nil?

    event_type = ActivityStreamsEventType.find_by_event_type(event_type_str)
    raise "Unknown event type #{event_type_str}" unless event_type

    event = ActivityStreamsEvent.new
    event.object_id = object_id
    event.object_type = object_type
    event.event_type = event_type
    event.end_time = time
    event.save
    event
  end

  def request(object_uri, head = false, depth = 0)
    raise 'Too many redirects' if depth > 5

    uri = URI.parse(object_uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.port == 443)
    response = if head
                 http.head(uri.path).response
               else
                 http.get(uri.path).response
               end
    case response
    when Net::HTTPSuccess then response
    when Net::HTTPMethodNotAllowed then response
    when Net::HTTPGone, Net::HTTPNotFound then response
    when Net::HTTPRedirection then request(response['location'], head, depth + 1)
    else
      response.error!
    end
  end

end
