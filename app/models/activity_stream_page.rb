class ActivityStreamPage

  def initialize(total, page_number, page_size, base_url)
    @total = total
    @page_number = page_number
    @page_size = page_size
    @events = ActivityStreamsEvent.order(:end_time).includes(:event_type).limit(@page_size).offset(page_number * @page_size)
    @base_url = base_url
  end

  def to_h
    offset = @page_size * @page_number
    page = {
        '@context': ActivityStream::DISC_0_CONTEXT,
        'id': "#{@base_url}/activity/page/#{@page_number}",
        'type': 'OrderedCollectionPage',
        'startIndex': offset,
        'partOf': {
            'id': "#{@base_url}/activity/all",
            'type': 'OrderedCollection'
        }
    }

    if @page_number.positive?
      page['prev'] = {
          'id': "#{@base_url}/activity/page/#{@page_number - 1}",
          'type': 'OrderedCollectionPage'
      }
    end

    if (@page_number + 1) * @page_size < @total
      page['next'] = {
          'id': "#{@base_url}/activity/page/#{@page_number + 1}",
          'type': 'OrderedCollectionPage'
      }
    end

    page['orderedItems'] = []
    @events.each do |event|
      page['orderedItems'].append(
          'type': event.event_type.event_type,
          'object': {
              'id': event.object_id,
              'type': event.object_type
          },
          'endTime': event.created_at.iso8601
      )
    end
    page
  end

end
