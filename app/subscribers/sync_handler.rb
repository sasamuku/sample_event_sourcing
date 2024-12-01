class SyncHandler
  def call(event)
    TableSyncJob.perform_later(event.event_id)
  end
end
