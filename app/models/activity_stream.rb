class ActivityStream

  DISC_0_CONTEXT = 'http://iiif.io/api/discovery/0/context.json'

  def initialize(base_url, page_size = 1000)
    @total = ActivityStreamsEvent.count
    @base_url = base_url
    @page_size = page_size
  end

  def page(page_number)
    raise ActiveRecord::RecordNotFound if @total.zero? || @page_size * page_number > @total

    ActivityStreamPage.new(@total, page_number, @page_size, @base_url)
  end

  def to_h
    pages = (@total / @page_size.to_f).ceil
    activity_stream = {
        '@context': ActivityStream::DISC_0_CONTEXT,
        'id': "#{@base_url}/activity/all",
        'type': 'OrderedCollection',
        'totalItems': @total
    }
    if @total.positive?
      activity_stream['first'] = {
          'id': "#{@base_url}/activity/page/0",
          'type': 'OrderedCollectionPage'
      }
      activity_stream['last'] = {
          'id': "#{@base_url}/activity/page/#{pages - 1}",
          'type': 'OrderedCollectionPage'
      }
    end
    activity_stream
  end

end
