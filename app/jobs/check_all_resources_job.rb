class CheckAllResourcesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Resource.all.each do |r|
      CheckForActivityJob.perform_later(r)
    end
  end

end
