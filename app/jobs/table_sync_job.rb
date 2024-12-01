class TableSyncJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    begin
      # Do something with the event
      # event = Rails.configuration.event_store.read.event(event_id)

      TableFeedbackJob.perform_later(event_id, "success")
    rescue => e
      puts "Error occurred: #{e.message}"
      TableFeedbackJob.perform_later(event_id, "fail")
    end
  end
end
