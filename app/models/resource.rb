require 'net/http'

class Resource < ApplicationRecord

  validates :object_id, presence: true
  validates :object_type, presence: true

  def create_event_if_changed
    response = request(object_id, http_etag, http_last_modified)
    process_response(response)
  end

  private

  def process_response(response)
    t = Time.now
    event_type_str = nil
    exists = http_etag || fixity_md5
    case response
    when Net::HTTPSuccess then
      md5 = Digest::MD5.hexdigest(response.body)
      return if md5 == fixity_md5
      puts response.to_hash
      self.http_etag = response.header['etag']
      res_last_modified = response.header['Last-Modified']
      self.http_last_modified = Time.rfc2822(res_last_modified) if res_last_modified
      self.fixity_md5 = md5
      event_type_str = (exists)? 'Update' : 'Create'
    when Net::HTTPGone, Net::HTTPNotFound then
      return nil if !exists
      event_type_str = 'Delete'
      self.http_etag = nil
      self.http_last_modified = nil
      self.fixity_md5 = nil
    when Net::HTTPNotModified
      logger.debug("#{object_id} Not Modified")
      return
    else
      logger.info("Received unexpected response code #{response.code} for #{object_id}")
      return
    end
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

  def request(object_uri, req_etag, req_last_modified, depth = 0)
    raise 'Too many redirects' if depth > 5

    uri = URI(object_uri)
    req = Net::HTTP::Get.new(uri)
    req['Accept'] = '*/*'
    req['Accept-Encoding'] = 'identity'
    req['If-Modified-Since'] = req_last_modified if req_last_modified
    req['If-None-Match'] = req_etag if req_etag
    response = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') {|http|
      http.request(req)
    }
    case response
    when Net::HTTPMethodNotAllowed, Net::HTTPSuccess, Net::HTTPGone, Net::HTTPNotFound, Net::HTTPNotModified then response
    when Net::HTTPRedirection then request(response['location'], req_etag, req_last_modified, depth + 1)
    else
      puts response.body
      response.error!
    end
  end

end
