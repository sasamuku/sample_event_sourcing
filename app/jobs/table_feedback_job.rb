class TableFeedbackJob < ApplicationJob
  queue_as :default

  def perform(event_id, status)
    event = Rails.configuration.event_store.read.event(event_id)

    stream_name = "Table#{event.data.fetch(:table_id)}"
    repository = AggregateRoot::Repository.new

    case status
    when "success"
      repository.with_aggregate(Table.new, stream_name) do |table|
        table.confirm_created
      end
    when "fail"
      repository.with_aggregate(Table.new, stream_name) do |table|
        table.reject_created
      end
    end
  end
end
