class TableSyncJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    begin
      event = Rails.configuration.event_store.read.event(event_id)

      case event.event_type
      when "TableCreated"
        name = event.data.fetch(:name).to_sym

        Sequel.connect(UserDb.url) do |db|
          db.create_table(name) do
            primary_key :id
            String :name
            DateTime :created_at
            DateTime :updated_at
          end
        end
      end

      TableFeedbackJob.perform_later(event_id, "success")
    rescue => e
      Rails.logger.error e.message
      TableFeedbackJob.perform_later(event_id, "fail")
    end
  end
end
