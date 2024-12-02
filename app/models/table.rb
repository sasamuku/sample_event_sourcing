class Table
  include AggregateRoot
  class HasAlreadyBeenSynced < StandardError; end
  class HasNotBeenSynced < StandardError; end

  attr_reader :table_id
  attr_reader :name
  attr_reader :synced
  attr_reader :exists
  attr_reader :error

  def initialize(table_id: nil, name: nil)
    @synced = nil
    @exists = false
    @table_id = table_id
    @name = name
  end

  def create
    apply TableCreated.new(data: { table_id: table_id, name: name })
  end

  def confirm_created
    raise HasAlreadyBeenSynced if synced
    apply TableCreationConfirmed.new(data: { table_id: table_id })
  end

  def reject_created
    raise HasAlreadyBeenSynced if synced
    apply TableCreationRejected.new(data: { table_id: table_id })
  end

  def delete
    raise HasNotBeenSynced unless synced
    apply TableDeleted.new(data: { table_id: table_id })
  end

  def confirm_deleted
    raise HasAlreadyBeenSynced if synced
    apply TableDeletionConfirmed.new(data: { table_id: table_id })
  end

  def reject_deleted
    raise HasAlreadyBeenSynced if synced
    apply TableDeletionRejected.new(data: { table_id: table_id })
  end

  on TableCreated do |event|
    @table_id = event.data.fetch(:table_id)
    @name = event.data.fetch(:name)
    @synced = false
  end

  on TableCreationConfirmed do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @exists = true
  end

  on TableCreationRejected do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @exists = false
    @error = "Table creation rejected"
  end

  on TableDeleted do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = false
  end

  on TableDeletionConfirmed do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @exists = false
  end

  on TableDeletionRejected do |event|
    @table_id = event.data.fetch(:table_id)
    @synced = true
    @exists = true
    @error = "Table deletion rejected"
  end
end
