class CheckForActivityJob < ApplicationJob
  queue_as :default

  def perform(*args)
    args[0].create_event_if_changed
  end

end
