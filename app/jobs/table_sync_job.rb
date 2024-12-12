class TableSyncJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    begin
      event = Rails.configuration.event_store.read.event(event_id)

      table_id = event.data.fetch(:table_id)
      stream_name = "Table#{table_id}"
      repository = AggregateRoot::Repository.new
      table = repository.load(Table.new, stream_name)
      table_name = table.name.to_sym

      case event.event_type
      when "TableCreated"
        Sequel.connect(Byodb.url) do |db|
          db.create_table(table_name) do
            table.columns.values.each do |column|
              name = column.name.to_sym
              type = column.type.to_sym
              column.primary_key ? send(:primary_key, name) : send(:column, name, type)
            end
          end
        end
      when "TableChanged"
        Sequel.connect(Byodb.url) do |db|
          db.alter_table(table_name) do
            name = table.pending_column.keys.first.to_sym
            column = table.pending_column.values.first
            type = column&.type&.to_sym
            type ? send(:add_column, name, type) : send(:drop_column, name)
          end
        end
      when "TableDeleted"
        Sequel.connect(Byodb.url) do |db|
          db.drop_table(table_name)
        end
      end

      TableFeedbackJob.perform_later(event_id, "success")
    rescue => e
      Rails.logger.error e.message
      TableFeedbackJob.perform_later(event_id, "fail")
    end
  end
end
