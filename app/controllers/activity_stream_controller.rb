# frozen_string_literal: true

class ActivityStreamController < ApplicationController
  PAGE_SIZE = 1000.0
  DISC_0_CONTEXT = 'http://iiif.io/api/discovery/0/context.json'

  def collection
    total = ActivityStreamsEvent.count
    pages = (total / PAGE_SIZE).ceil
    collection = {
      '@context': DISC_0_CONTEXT,
      'id': "#{request.base_url}/activity/all",
      'type': 'OrderedCollection',
      'totalItems': total
    }
    if total.positive?
      collection['first'] = {
        'id': "#{request.base_url}/activity/page/0",
        'type': 'OrderedCollectionPage'
      }
      collection['last'] = {
        'id': "#{request.base_url}/activity/page/#{pages - 1}",
        'type': 'OrderedCollectionPage'
      }
    end
    render json: JSON.pretty_generate(collection)
  end

  def page
    total = ActivityStreamsEvent.count
    page_number = params[:page_number].to_i
    offset = (PAGE_SIZE * page_number).to_i
    limit = PAGE_SIZE.to_i

    if total.zero? || offset > total
      head 404, "content_type" => 'text/plain'
      return
    end

    ordered_items = []
    page = {
      '@context': DISC_0_CONTEXT,
      'id': "#{request.base_url}/activity/page/#{page_number}",
      'type': 'OrderedCollectionPage',
      'startIndex': offset,
      'partOf': {
        'id': "#{request.base_url}/activity/all",
        'type': 'OrderedCollection'
      }
    }

    if page_number.positive?
      page['prev'] = {
        'id': "#{request.base_url}/activity/page/#{page_number - 1}",
        'type': 'OrderedCollectionPage'
      }
    end

    if (page_number + 1) * PAGE_SIZE < total
      page['next'] = {
        'id': "#{request.base_url}/activity/page/#{page_number + 1}",
        'type': 'OrderedCollectionPage'
      }
    end

    page['orderedItems'] = ordered_items

    events = ActivityStreamsEvent.order(:end_time).includes(:event_type).limit(limit).offset(offset)
    events.each do |event|
      ordered_items.append(
        'type': event.event_type.event_type,
        'object': {
          'id': event.object_id,
          'type': event.object_type
        },
        'endTime': event.created_at.iso8601
      )
    end

    render json: page
  end
end
