require 'net/http'

namespace :disco do
  desc 'Load YCBA manifests'
  task load_all_ycba_manifests: :environment do
    host = 'manifests.britishart.yale.edu'
    port = 443
    http = Net::HTTP.new(host, port)
    http.use_ssl = true
    (56600..100000).each do |i|
      path = "/manifest/#{i}"
      id = "https://#{host}#{path}"
      get = http.get(path)
      next unless get.response.code == '200'

      etag = get.response.header['etag']
      json = JSON.parse(get.response.body)
      object_id = json['@id'] || json['id']
      puts "#{object_id} is not #{id}" if object_id != id
      object_type = json['@type'] || json['type']
      next if Resource.find_by_object_id(id)

      t = Time.now
      resource = Resource.create(object_id: object_id,
                          etag: nil,
                          object_type: object_type,
                          object_last_update: t)
      CheckForActivityJob.perform_later(resource)
    end
  end

  desc 'Check all resources for new activity'
  task check_all_resources: :environment do
    CheckAllResourcesJob.perform_later
  end

  desc 'Add new resource to monitoring list'
  task :add_resource, %i[url resource_type] => :environment do |task, args|
    raise 'URL and type must be specified' if args[:url].nil? || args[:resource_type].nil?

    unless Resource.find_by_object_id(args[:url])
      r = Resource.create(object_id: args[:url], object_type: args[:resource_type])
      r.create_event_if_changed
    end
  end

  desc 'Check resource for new activity'
  task :check_resource, %i[url] => :environment do |task, args|
    raise 'URL must be specified' if args[:url].nil?

    r = Resource.find_by_object_id(args[:url])
    r&.create_event_if_changed
  end

end
